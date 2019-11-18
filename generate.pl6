use lib 'Grammar-BNF';

use Grammar::ABNF;
use Grammar::ABNF::GrammarGenerator;
use Grammar::ABNF::ActionsGenerator;
grammar Grammar::BNF {
    token TOP {
        \s* <rule>+ \s*
    }

    # Apparently when used for slang we need a lowercase top rule?
    token main_syntax {
        <TOP>
    }

    token rule {
        <opt-ws> <rule-name> <opt-ws> '::=' <opt-ws> <expression> <line-end>
    }

    token opt-ws {
        \h*
    }

    token rule-name {
        # If we want something other than legal perl 6 identifiers,
        # we would have to implement a FALLBACK.  BNF "specifications"
        # diverge on what is a legal rule name but most expectations are
        # covered by legal Perl 6 identifiers.  Care should be taken to
        # shield from evaluation of metacharacters on a Perl 6 level.
        '<' [ <[\w\-\'\s\:\/]> ]+ '>'
    }

    token expression {
        <list> +% [\s* '|' <opt-ws>]
    }

    token line-end {
        [ <opt-ws> \n ]+
    }

    token list {
        <term> +% <opt-ws>
    }

    token term {
        <rule-name> || <option> | <literal>
    }

    token option {
        "[" <opt-ws> <expression> <opt-ws> "]"
    }

    token literal {
        '"' <-["]>* '"' | "'" <-[']>* "'" | <-[\s\|]>+
    }
}

class Grammar::BNF::To::Perl6 {
    has $.name;

    method TOP($/) {
        make "grammar $.name \{\n{ $<rule>».ast.join: "\n" }\n\}";
    }

    method rule-name($/) {
        make $/.Str.subst(/\W/, '_', :g)
    }

    method rule($/) {
        make qq:to/RULE/;
                token { $<rule-name>.ast } \{
                    { $<expression>.ast }
                \}
            RULE
    }

    method expression($/) {
        make $<list>».ast.join: '|'
    }

    method list($/) {
        make $<term>».ast.join: ' '
    }

    method term($/) {
        make $<rule-name> ?? '<' ~ $<rule-name>.ast ~ '>' !! $/.values[0].ast;
    }

    method option($/) {
        make '[ ' ~ $<expression>.ast ~ ' ]?'
    }

    method literal($/) {
        my $str = $/.Str;
        $str = "'$str'" unless $str.starts-with('"') and $str.ends-with('"') or $str.starts-with("'") and $str.ends-with("'");
        make $str
    }
}

multi sub MAIN(Bool :$grammar!) {
    Grammar::ABNF::Slang.parsefile(
        'sql-2003-2.clean.bnf'.IO,
        :actions(Grammar::ABNF::GrammarGenerator.new),
        :name<SQL::Grammar>,
    ).made.say;
}
multi sub MAIN(Bool :$actions!) {
    Grammar::ABNF::Slang.parsefile(
        'sql-2003-2.clean.bnf'.IO,
        :actions(Grammar::ABNF::ActionsGenerator.new),
        :name('SQL::Grammar::Actions'),
    ).made.say;
}
#my $grammar = Grammar::ABNF.parsefile('sql-2003-2.clean.bnf'.IO, :actions(Grammar::BNF::To::Perl6.new(:name<SQL::Grammar>))).made;
#EVAL $grammar;
