use lib 'Grammar-BNF';

use Grammar::BNF;

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

use MONKEY-SEE-NO-EVAL;
my $grammar = Grammar::BNF.parsefile('sql-2003-2.clean.bnf'.IO, :actions(Grammar::BNF::To::Perl6.new(:name<SQL::Grammar>))).made;
say $grammar;
EVAL $grammar;
