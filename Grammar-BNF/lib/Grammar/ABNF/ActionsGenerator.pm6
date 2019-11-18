#use Data::Dump::Tree;
use Data::Dump;
class Grammar::ABNF::ActionsGenerator {
    my sub rule-name-to-param-name($rule-name) {
        my %numbers = 0 => 'zero', 1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five', 6 => 'siz', 7 => 'seven', 8 => 'eight', 9 => 'nine', 15 => 'fifteen', 18 => 'eighteen', 77 => 'seventyseven';
        $rule-name.Str.subst(/\W/, '-', :g).subst(/\d+/, {%numbers{$_}}, :g);
    }

    my sub gather-deps(Str:D $rule) {
        %*done{$rule} = Set.new;
        %*done{$rule} = [∪] %*rule-dependencies{$rule}
            .grep({defined $_ and $_ ne $rule})
            .map({%*done{$_}:exists ?? %*done{$_} !! gather-deps($_) ∪ Set.new($_) })
    }

    my sub guts($/) {
        my %deps;
        my %*done;
        for %*rule-dependencies.keys {
            %deps{$_} = gather-deps($_);
        }
        note "$_.key(): $_.value().elems()" for %deps.pairs.sort(*.value.elems);

        my $result = "class $*name \{\n";

        use MONKEY-SEE-NO-EVAL;
        # Note: $*name can come from .parse above or from Slang::BNF
        my $grmr := Metamodel::GrammarHOW.new_type(:name($*name));
        my @rules = 'direct_select_statement__multiple_rows';
        $result ~= 'method TOP($/) { make $<' ~ @rules[0] ~ '> }' ~ "\n";
        my %done;
        while @rules {
            my $rule-name = @rules.shift;
            my $rule = %*rules{$rule-name};
            next unless $rule;
            next if %done{$rule-name};
            %done{$rule-name} = True;
            #dd %*rule-dependencies{$rule-name};
            @rules.append(%*rule-dependencies{$rule-name}.grep: { not %done{$_} });
            #note "token $rule-name \{ $rule \}";
            $result ~= "$rule\n";
        }
        #`[
        for @*ruleorder -> $rule-name {
            my $rule = %*rules{$rule-name};
            note "token $rule-name \{ $rule \}";
            my $r = EVAL 'token { ' ~ $rule ~ ' }';
            $r.set_name($rule-name);
        }
        ]

        $result ~= "\}\n";
        $result = @*classes.map({
            "../SQL-Statement/lib/SQL/Statement/$_.pm6".IO.e ?? "use SQL::Statement::$_;" !! "class SQL::Statement::$_ \{\}"
        }).join("\n") ~ "\n$result";
        make $result;
    }

    method TOP($/) {
        make guts($/);
    }

    method main_syntax($/) {
        make guts($/);
    }

    method rule($/) {
        my $rulename = $/<rulename>.made;
        my $ruleval = $/<elements><alternation>.made;
        if (%*rules{$rulename}:exists) {
            if $/<defined-as> eq '=' {
                X.Redeclaration.new(:symbol($rulename)
                                    :what('Regex')
                                    :postfix('in ABNF definitions')).throw;
            }
	    %*rules{$rulename} ~= " | $ruleval";
        }
        else {
            push @*ruleorder, $rulename;
            %*rule-dependencies{$rulename} = [
                @*current-rule-dependencies.unique.grep: { $_ ne $rulename }
            ];
            my $is-rule = (
                any($/<elements><alternation><bnf-concatenation>)<repetition>.elems != 1
                or $rulename eq 'identifier_body'
            );
            my $package_name = $rulename.split('_').map(*.tc).join;
            my $bnf-concatenation = $/<elements><alternation><bnf-concatenation>.list.first: {$_<repetition>.elems};
            if $bnf-concatenation {
                my @params;
                @*classes.push: $package_name;
                for $bnf-concatenation<repetition>.list.grep({$_<element><rulename>}) -> $repetition {
                    my $param = rule-name-to-param-name($repetition<element><rulename><name>);
                    @params.push: $param => $repetition.made;
                }
                %*rules{$rulename} = qq:to/END/;
                method $rulename\({'$/'}) \{
                    make SQL::Statement::{$package_name}.new({@params.map(-> $param {"$param.key() => $param.value()"}).join(', ')})
                \}
                END
            }
            else {
                %*rules{$rulename} = "method $rulename\({'$/'}) \{ $ruleval \}";
            }
        }
    }

    method rulename($/) {
        my $n = ~$/<name>;
        $n = $n.lc;
        # Try to paper over the fact that perl6 rulenames cannot contain
        # a hyphen followed by a decimal or at the end.
        $n = $<name>.Str.subst(/\W/, '_', :g);
        #$n = $n.split(/ \- <.before [ \d | $ ]> /).join("_");
        @*current-rule-dependencies.push: $n;
        make $n;
    }

    method alternation($/) {
        make 'make $/.values[0].ast';
    }

    method bnf-concatenation($/) {
        make join(" ", $/<repetition>[]».made)
    }

    method repetition($/) {
        if $/<repeat>.defined {
            make '[$/' ~ $/<element>.made ~ '.map: $_.made ]';
        }
        else {
            make '$/' ~ $/<element>.made ~ '.made';
        }
    }

    method element($/) {
        # Only one of these will exist
        if $/<rulename> {
            # Try to paper over the fact that perl6 rulenames cannot contain
            # a hyphen followed by a decimal or at the end.
            my $rn =
                ~$/<rulename>.made.split(/\-<.before [ \d | $ ]>/).join("_");
            make "<$rn>";
	}
        else {
            make $/<group option char-val
                    num-val prose-val>.first(*.defined).made;
        }
    }

    method group($/) {
        make "[ " ~ $/<alternation>.made ~ " ]";
    }

    method option($/) {
        make "[ " ~ $/<alternation>.made ~ " ]?";
    }

    method char-val($/) {
        make 'make $/.Str';
    }

    method num-val($/) {
        make 'make $/.Str';
    }

    # For all the num-vals, the RFC does not put limits on the number of
    # digits nor the codepoint values (You can use ABNF on unicode if you
    # really want to, if you adjust the "core rules" in B.1.)  We could
    # just shove the strings back into the perl6 regexps, but instead we
    # write it in a way that is convenient to customize/sanitize.
    my sub numval ($m, &rad2num) {
        if $m<val> {
            join(" ", "[", $m<val>[].map({ rad2num(~$_).fmt('\\x%x') }), "]")
        }
        else {
            sprintf('<[\\x%x..\\x%x]>', $m<min max>.map: { rad2num(~$_) })
        }
    }

    method bin-val($/) {
        make numval($/, { :2($^n) });
    }

    method dec-val($/) {
        make numval($/, { :10($^n) });
    }

    method hex-val($/) {
        make numval($/, { :16($^n) });
    }

    method prose-val($/) {
        make qq:to<EOCODE>;
        \{X::NYI.new(:feature(｢$/[0]｣.fmt(Q:to<ERR>) ~ 'Such a mixin')).throw\}
            This ABNF Grammar requires you to mix in custom code to do
            the following:
                %s
            ...which you may have to write yourself.
            ERR
        EOCODE
    }
}
