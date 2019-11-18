use lib 'Grammar-BNF';

use Grammar::ABNF;
use Grammar::ABNF::GrammarGenerator;
use Grammar::ABNF::ActionsGenerator;
use Grammar::ABNF::AST;

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
multi sub MAIN(Bool :$ast!) {
    dd Grammar::ABNF::Slang.parsefile(
        'sql-2003-2.clean.bnf'.IO,
        :actions(Grammar::ABNF::AST.new),
        :name('SQL::Grammar::Actions'),
    ).made;
}
