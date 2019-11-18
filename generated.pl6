use SQL::Grammar;
use SQL::Grammar::Actions;

say SQL::Grammar.parse(
    'SELECT * FROM (SELECT * FROM customers) AS c',
    :actions(SQL::Grammar::Actions),
).ast;
