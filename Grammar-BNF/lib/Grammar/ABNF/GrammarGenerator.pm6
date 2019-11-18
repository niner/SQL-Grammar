class Grammar::ABNF::GrammarGenerator {

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

        my $result = "grammar $*name \{\n";

        use MONKEY-SEE-NO-EVAL;
        # Note: $*name can come from .parse above or from Slang::BNF
        my @rules = 'direct_select_statement__multiple_rows';
        $result ~= 'token TOP { <' ~ @rules[0] ~ "> }\n";
        my %done;
        while @rules {
            my $rule-name = @rules.shift;
            my $rule = %*rules{$rule-name};
            next unless $rule;
            next if %done{$rule-name};
            %done{$rule-name} = True;
            @rules.append(%*rule-dependencies{$rule-name}.grep: { not %done{$_} });
            $result ~= "$rule\n";
        }
        #`[
        for @*ruleorder -> $rule-name {
            my $rule = %*rules{$rule-name};
            $result ~= "token $rule-name \{ $rule \}\n";
            my $r = EVAL 'token { ' ~ $rule ~ ' }';
            $r.set_name($rule-name);
            $grmr.^add_method($rule-name, $r);
        }
        ]

        $result ~= "\}\n";

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
            my $is-rule =
                any($/<elements><alternation><bnf-concatenation>)<repetition>.elems != 1
            ;
            $is-rule = False if $rulename eq 'identifier_body';
	    %*rules{$rulename} = "{$is-rule ?? 'rule' !! 'token'} $rulename \{ $ruleval \}";
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
        make join(" || ", $/<bnf-concatenation>[]».made)
    }

    method bnf-concatenation($/) {
        my @made;
        my $skip = False;
        for $/<repetition>.list.kv -> $i, $repetition {
            if $skip {
                $skip = False;
                next;
            }
            if $repetition<element><rulename>.defined
                && $i < $/<repetition>.list.elems - 1
                && $/<repetition>[$i + 1]<element><option>
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>.elems == 1
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>.list.elems == 1
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>[0]<element><group>.defined
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>[0]<element><group><alternation><bnf-concatenation>.elems == 1
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>[0]<element><group><alternation><bnf-concatenation>[0]<repetition>.elems == 2
                && $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>[0]<element><group><alternation><bnf-concatenation>[0]<repetition>[1]<element><rulename> eq $repetition<element><rulename>
            {
                note $/<repetition>[$i + 1];
                @made.push: $repetition<element>.made ~ '+ % ' ~ $/<repetition>[$i + 1]<element><option><alternation><bnf-concatenation>[0]<repetition>[0]<element><group><alternation><bnf-concatenation>[0]<repetition>[0].made; #FIXME separator missing
                $skip = True;
            }
            else {
                @made.push: $repetition.made;
            }
        }
        make @made.join: ' ';
    }

    method repetition($/) {
        if $/<repeat>.defined {
            make "[ " ~ $/<element>.made ~ " ]{$*in-option ?? '*' !! '+'}";
        }
        else {
            make $/<element>.made;
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
        make $/<alternation><bnf-concatenation>.elems == 1
                && $/<alternation><bnf-concatenation>[0]<repetition>.elems == 1
                && $/<alternation><bnf-concatenation>[0]<repetition>[0]<repeat>.defined
            ?? $/<alternation>.made
            !! "[ " ~ $/<alternation>.made ~ " ]?";
    }

    method char-val($/) {
        # Don't EVAL metachars.  I do not curently trust /$foo/ as it still
        # needs work IIRC.  Later we should be able to do something like:
        #
        # my $f = $/[0]; make rx:ratchet/$f/;
        #
        # So here is the brute force interim solution.
        #
	# The .ords may get deprecated with NFG, and synthetic-leak-refusal
        # would cause trouble here.  Really we need to use the encoding
        # of the source and re-encode it.  But it will be 8-bit for most uses,
        # so deal with it later.
#        make "[ " ~
#             (~$/[0].comb.map({ "<[" ~
#                                ($_.uc,$_.lc).map({$_.ords}).fmt('\x%x', ' ')
#                                ~ "]>"
#                              }).join)
#              ~ " ]";
        return make '\w' if $/.Str eq '\w';
        return make '\s' if $/.Str eq '\s';
        return make '\n' if $/.Str eq '\n';
        make $/[0] eq "'" ?? $/.Str !! "'" ~ ($/[0] // $/[1] // $/[2]) ~ "'";
    }

    method num-val($/) {
        # Only one of these will exist
        make $/<bin-val dec-val hex-val>.first(*.defined).made;
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
