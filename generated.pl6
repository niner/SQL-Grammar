use SQL::Grammar;

say SQL::Grammar.parse('SELECT * FROM (SELECT * FROM customers) AS c');
