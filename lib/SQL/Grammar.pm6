use v6.c;

unit grammar SQL::Grammar:ver<0.0.1>:auth<cpan:nine>;

token TOP { <direct_select_statement__multiple_rows> }
token direct_select_statement__multiple_rows { <cursor_specification> }
rule cursor_specification { <query_expression> [ <order_by_clause> ]? [ <updatability_clause> ]? }
rule query_expression { [ <with_clause> ]? <query_expression_body> }
rule order_by_clause { 'ORDER' 'BY' <sort_specification_list> }
rule updatability_clause { 'FOR' [ 'READ' 'ONLY' || 'UPDATE' [ 'OF' <column_name_list> ]? ] }
rule with_clause { 'WITH' [ 'RECURSIVE' ]? <with_list> }
token query_expression_body { <non_join_query_expression> || <joined_table> }
rule sort_specification_list { <sort_specification> [ [[ [ <comma> <sort_specification> ] ]* ] ]? }
rule column_name_list { <column_name> [ [[ [ <comma> <column_name> ] ]* ] ]? }
rule with_list { <with_list_element> [ [[ [ <comma> <with_list_element> ] ]* ] ]? }
token non_join_query_expression { <non_join_query_term> || <query_expression_body> 'UNION' [ 'ALL' || 'DISTINCT' ]? [ <corresponding_spec> ]? <query_term> || <query_expression_body> 'EXCEPT' [ 'ALL' || 'DISTINCT' ]? [ <corresponding_spec> ]? <query_term> }
token joined_table { <cross_join> || <qualified_join> || <natural_join> || <union_join> }
rule sort_specification { <sort_key> [ <ordering_specification> ]? [ <null_ordering> ]? }
token comma { ',' }
token column_name { <identifier> }
rule with_list_element { <query_name> [ <left_paren> <with_column_list> <right_paren> ]? 'AS' <left_paren> <query_expression> <right_paren> [ <search_or_cycle_clause> ]? }
token non_join_query_term { <non_join_query_primary> || <query_term> 'INTERSECT' [ 'ALL' || 'DISTINCT' ]? [ <corresponding_spec> ]? <query_primary> }
rule corresponding_spec { 'CORRESPONDING' [ 'BY' <left_paren> <corresponding_column_list> <right_paren> ]? }
token query_term { <non_join_query_term> || <joined_table> }
rule cross_join { <table_reference> 'CROSS' 'JOIN' <table_primary> }
rule qualified_join { <table_reference> [ <join_type> ]? 'JOIN' <table_reference> <join_specification> }
rule natural_join { <table_reference> 'NATURAL' [ <join_type> ]? 'JOIN' <table_primary> }
rule union_join { <table_reference> 'UNION' 'JOIN' <table_primary> }
token sort_key { <value_expression> }
token ordering_specification { 'ASC' || 'DESC' }
rule null_ordering { 'NULLS' 'FIRST' || 'NULLS' 'LAST' }
token identifier { <actual_identifier> }
token query_name { <identifier> }
token left_paren { '(' }
token with_column_list { <column_name_list> }
token right_paren { ')' }
token search_or_cycle_clause { <search_clause> || <cycle_clause> || <search_clause> <cycle_clause> }
token non_join_query_primary { <simple_table> || <left_paren> <non_join_query_expression> <right_paren> }
token query_primary { <non_join_query_primary> || <joined_table> }
token corresponding_column_list { <column_name_list> }
rule table_reference { <table_primary_or_joined_table> [ <sample_clause> ]? }
rule table_primary { <table_or_query_name> [ [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? ]? || <derived_table> [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? || <lateral_derived_table> [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? || <collection_derived_table> [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? || <table_function_derived_table> [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? || <only_spec> [ [ 'AS' ]? <correlation_name> [ <left_paren> <derived_column_list> <right_paren> ]? ]? || <left_paren> <joined_table> <right_paren> }
token join_type { 'INNER' || <outer_join_type> [ 'OUTER' ]? }
token join_specification { <join_condition> || <named_columns_join> }
token value_expression { <common_value_expression> || <boolean_value_expression> || <row_value_expression> }
token actual_identifier { <regular_identifier> || <delimited_identifier> }
rule search_clause { 'SEARCH' <recursive_search_order> 'SET' <sequence_column> }
rule cycle_clause { 'CYCLE' <cycle_column_list> 'SET' <cycle_mark_column> 'TO' <cycle_mark_value> 'DEFAULT' <non_cycle_mark_value> 'USING' <path_column> }
token simple_table { <query_specification> || <table_value_constructor> || <explicit_table> }
token table_primary_or_joined_table { <table_primary> || <joined_table> }
rule sample_clause { 'TABLESAMPLE' <sample_method> <left_paren> <sample_percentage> <right_paren> [ <repeatable_clause> ]? }
token table_or_query_name { <table_name> || <query_name> }
token correlation_name { <identifier> }
token derived_column_list { <column_name_list> }
token derived_table { <table_subquery> }
rule lateral_derived_table { 'LATERAL' <table_subquery> }
rule collection_derived_table { 'UNNEST' <left_paren> <collection_value_expression> <right_paren> [ 'WITH' 'ORDINALITY' ]? }
rule table_function_derived_table { 'TABLE' <left_paren> <collection_value_expression> <right_paren> }
rule only_spec { 'ONLY' <left_paren> <table_or_query_name> <right_paren> }
token outer_join_type { 'LEFT' || 'RIGHT' || 'FULL' }
rule join_condition { 'ON' <search_condition> }
rule named_columns_join { 'USING' <left_paren> <join_column_list> <right_paren> }
token common_value_expression { <numeric_value_expression> || <string_value_expression> || <datetime_value_expression> || <interval_value_expression> || <user_defined_type_value_expression> || <reference_value_expression> || <collection_value_expression> }
token boolean_value_expression { <boolean_term> || <boolean_value_expression> 'OR' <boolean_term> }
token row_value_expression { <row_value_special_case> || <explicit_row_value_constructor> }
token regular_identifier { <identifier_body> }
rule delimited_identifier { <double_quote> <delimited_identifier_body> <double_quote> }
rule recursive_search_order { 'DEPTH' 'FIRST' 'BY' <sort_specification_list> || 'BREADTH' 'FIRST' 'BY' <sort_specification_list> }
token sequence_column { <column_name> }
rule cycle_column_list { <cycle_column> [ [[ [ <comma> <cycle_column> ] ]* ] ]? }
token cycle_mark_column { <column_name> }
token cycle_mark_value { <value_expression> }
token non_cycle_mark_value { <value_expression> }
token path_column { <column_name> }
rule query_specification { 'SELECT' [ <set_quantifier> ]? <select_list> <table_expression> }
rule table_value_constructor { 'VALUES' <row_value_expression_list> }
rule explicit_table { 'TABLE' <table_or_query_name> }
token sample_method { 'BERNOULLI' || 'SYSTEM' }
token sample_percentage { <numeric_value_expression> }
rule repeatable_clause { 'REPEATABLE' <left_paren> <repeat_argument> <right_paren> }
token table_name { <local_or_schema_qualified_name> }
token table_subquery { <subquery> }
token collection_value_expression { <array_value_expression> || <multiset_value_expression> }
token search_condition { <boolean_value_expression> }
token join_column_list { <column_name_list> }
token numeric_value_expression { <term> || <numeric_value_expression> <plus_sign> <term> || <numeric_value_expression> <minus_sign> <term> }
token string_value_expression { <character_value_expression> || <blob_value_expression> }
token datetime_value_expression { <datetime_term> || <interval_value_expression> <plus_sign> <datetime_term> || <datetime_value_expression> <plus_sign> <interval_term> || <datetime_value_expression> <minus_sign> <interval_term> }
token interval_value_expression { <interval_term> || <interval_value_expression_1> <plus_sign> <interval_term_1> || <interval_value_expression_1> <minus_sign> <interval_term_1> || <left_paren> <datetime_value_expression> <minus_sign> <datetime_term> <right_paren> <interval_qualifier> }
token user_defined_type_value_expression { <value_expression_primary> }
token reference_value_expression { <value_expression_primary> }
token boolean_term { <boolean_factor> || <boolean_term> 'AND' <boolean_factor> }
token row_value_special_case { <nonparenthesized_value_expression_primary> }
token explicit_row_value_constructor { <left_paren> <row_value_constructor_element> <comma> <row_value_constructor_element_list> <right_paren> || 'ROW' <left_paren> <row_value_constructor_element_list> <right_paren> || <row_subquery> }
token identifier_body { <identifier_start> [ [[ <identifier_part> ]* ] ]? }
token double_quote { '"' }
token delimited_identifier_body { [[ <delimited_identifier_part> ]+ ] }
token cycle_column { <column_name> }
token set_quantifier { 'DISTINCT' || 'ALL' }
token select_list { <asterisk> || <select_sublist> [ [[ [ <comma> <select_sublist> ] ]* ] ]? }
rule table_expression { <from_clause> [ <where_clause> ]? [ <group_by_clause> ]? [ <having_clause> ]? [ <window_clause> ]? }
rule row_value_expression_list { <table_row_value_expression> [ [[ [ <comma> <table_row_value_expression> ] ]* ] ]? }
token repeat_argument { <numeric_value_expression> }
rule local_or_schema_qualified_name { [ <local_or_schema_qualifier> <period> ]? <qualified_identifier> }
rule subquery { <left_paren> <query_expression> <right_paren> }
token array_value_expression { <array_concatenation> || <array_factor> }
token multiset_value_expression { <multiset_term> || <multiset_value_expression> 'MULTISET' 'UNION' [ 'ALL' || 'DISTINCT' ]? <multiset_term> || <multiset_value_expression> 'MULTISET' 'EXCEPT' [ 'ALL' || 'DISTINCT' ]? <multiset_term> }
token term { <factor> || <term> <asterisk> <factor> || <term> <solidus> <factor> }
token plus_sign { '+' }
token minus_sign { '-' }
token character_value_expression { <concatenation> || <character_factor> }
token blob_value_expression { <blob_concatenation> || <blob_factor> }
token datetime_term { <datetime_factor> }
token interval_term { <interval_factor> || <interval_term_2> <asterisk> <factor> || <interval_term_2> <solidus> <factor> || <term> <asterisk> <interval_factor> }
token interval_value_expression_1 { <interval_value_expression> }
token interval_term_1 { <interval_term> }
token interval_qualifier { <start_field> 'TO' <end_field> || <single_datetime_field> }
token value_expression_primary { <parenthesized_value_expression> || <nonparenthesized_value_expression_primary> }
rule boolean_factor { [ 'NOT' ]? <boolean_test> }
token nonparenthesized_value_expression_primary { <unsigned_value_specification> || <column_reference> || <set_function_specification> || <window_function> || <scalar_subquery> || <case_expression> || <cast_specification> || <field_reference> || <subtype_treatment> || <method_invocation> || <static_method_invocation> || <new_specification> || <attribute_or_method_reference> || <reference_resolution> || <collection_value_constructor> || <array_element_reference> || <multiset_element_reference> || <routine_invocation> || <next_value_expression> }
token row_value_constructor_element { <value_expression> }
rule row_value_constructor_element_list { <row_value_constructor_element> [ [[ [ <comma> <row_value_constructor_element> ] ]* ] ]? }
token row_subquery { <subquery> }
token identifier_start { \w }
token identifier_part { <identifier_start> || <identifier_extend> }
token delimited_identifier_part { <nondoublequote_character> || <doublequote_symbol> }
token asterisk { '*' }
token select_sublist { <derived_column> || <qualified_asterisk> }
rule from_clause { 'FROM' <table_reference_list> }
rule where_clause { 'WHERE' <search_condition> }
rule group_by_clause { 'GROUP' 'BY' [ <set_quantifier> ]? <grouping_element_list> }
rule having_clause { 'HAVING' <search_condition> }
rule window_clause { 'WINDOW' <window_definition_list> }
token table_row_value_expression { <row_value_special_case> || <row_value_constructor> }
token local_or_schema_qualifier { <schema_name> || 'MODULE' }
token period { '.' }
token qualified_identifier { <identifier> }
rule array_concatenation { <array_value_expression_1> <concatenation_operator> <array_factor> }
token array_factor { <value_expression_primary> }
token multiset_term { <multiset_primary> || <multiset_term> 'MULTISET' 'INTERSECT' [ 'ALL' || 'DISTINCT' ]? <multiset_primary> }
rule factor { [ <sign> ]? <numeric_primary> }
token solidus { '/' }
rule concatenation { <character_value_expression> <concatenation_operator> <character_factor> }
rule character_factor { <character_primary> [ <collate_clause> ]? }
rule blob_concatenation { <blob_value_expression> <concatenation_operator> <blob_factor> }
token blob_factor { <blob_primary> }
rule datetime_factor { <datetime_primary> [ <time_zone> ]? }
rule interval_factor { [ <sign> ]? <interval_primary> }
token interval_term_2 { <interval_term> }
rule start_field { <non_second_primary_datetime_field> [ <left_paren> <interval_leading_field_precision> <right_paren> ]? }
token end_field { <non_second_primary_datetime_field> || 'SECOND' [ <left_paren> <interval_fractional_seconds_precision> <right_paren> ]? }
rule single_datetime_field { <non_second_primary_datetime_field> [ <left_paren> <interval_leading_field_precision> <right_paren> ]? || 'SECOND' [ <left_paren> <interval_leading_field_precision> [ <comma> <interval_fractional_seconds_precision> ]? <right_paren> ]? }
rule parenthesized_value_expression { <left_paren> <value_expression> <right_paren> }
rule boolean_test { <boolean_primary> [ 'IS' [ 'NOT' ]? <truth_value> ]? }
token unsigned_value_specification { <unsigned_literal> || <general_value_specification> }
token column_reference { <basic_identifier_chain> || 'MODULE' <period> <qualified_identifier> <period> <column_name> }
token set_function_specification { <aggregate_function> || <grouping_operation> }
rule window_function { <window_function_type> 'OVER' <window_name_or_specification> }
token scalar_subquery { <subquery> }
token case_expression { <case_abbreviation> || <case_specification> }
rule cast_specification { 'CAST' <left_paren> <cast_operand> 'AS' <cast_target> <right_paren> }
rule field_reference { <value_expression_primary> <period> <field_name> }
rule subtype_treatment { 'TREAT' <left_paren> <subtype_operand> 'AS' <target_subtype> <right_paren> }
token method_invocation { <direct_invocation> || <generalized_invocation> }
rule static_method_invocation { <path_resolved_user_defined_type_name> <double_colon> <method_name> [ <SQL_argument_list> ]? }
rule new_specification { 'NEW' <routine_invocation> }
rule attribute_or_method_reference { <value_expression_primary> <dereference_operator> <qualified_identifier> [ <SQL_argument_list> ]? }
rule reference_resolution { 'DEREF' <left_paren> <reference_value_expression> <right_paren> }
token collection_value_constructor { <array_value_constructor> || <multiset_value_constructor> }
rule array_element_reference { <array_value_expression> <left_bracket_or_trigraph> <numeric_value_expression> <right_bracket_or_trigraph> }
rule multiset_element_reference { 'ELEMENT' <left_paren> <multiset_value_expression> <right_paren> }
rule routine_invocation { <routine_name> <SQL_argument_list> }
rule next_value_expression { 'NEXT' 'VALUE' 'FOR' <sequence_generator_name> }
token identifier_extend { \w }
token nondoublequote_character { \w }
rule doublequote_symbol { <double_quote> <double_quote> }
rule derived_column { <value_expression> [ <as_clause> ]? }
token qualified_asterisk { <asterisked_identifier_chain> <period> <asterisk> || <all_fields_reference> }
rule table_reference_list { <table_reference> [ [[ [ <comma> <table_reference> ] ]* ] ]? }
rule grouping_element_list { <grouping_element> [ [[ [ <comma> <grouping_element> ] ]* ] ]? }
rule window_definition_list { <window_definition> [ [[ [ <comma> <window_definition> ] ]* ] ]? }
token row_value_constructor { <common_value_expression> || <boolean_value_expression> || <explicit_row_value_constructor> }
rule schema_name { [ <catalog_name> <period> ]? <unqualified_schema_name> }
token array_value_expression_1 { <array_value_expression> }
rule concatenation_operator { <vertical_bar> <vertical_bar> }
token multiset_primary { <multiset_value_function> || <value_expression_primary> }
token sign { <plus_sign> || <minus_sign> }
token numeric_primary { <value_expression_primary> || <numeric_value_function> }
token character_primary { <value_expression_primary> || <string_value_function> }
rule collate_clause { 'COLLATE' <collation_name> }
token blob_primary { <value_expression_primary> || <string_value_function> }
token datetime_primary { <value_expression_primary> || <datetime_value_function> }
rule time_zone { 'AT' <time_zone_specifier> }
token interval_primary { <value_expression_primary> [ <interval_qualifier> ]? || <interval_value_function> }
token non_second_primary_datetime_field { 'YEAR' || 'MONTH' || 'DAY' || 'HOUR' || 'MINUTE' }
token interval_leading_field_precision { <unsigned_integer> }
token interval_fractional_seconds_precision { <unsigned_integer> }
token boolean_primary { <predicate> || <boolean_predicand> }
token truth_value { 'TRUE' || 'FALSE' || 'UNKNOWN' }
token unsigned_literal { <unsigned_numeric_literal> || <general_literal> }
token general_value_specification { <host_parameter_specification> || <SQL_parameter_reference> || <dynamic_parameter_specification> || <embedded_variable_specification> || <current_collation_specification> || 'CURRENT_DEFAULT_TRANSFORM_GROUP' || 'CURRENT_PATH' || 'CURRENT_ROLE' || 'CURRENT_TRANSFORM_GROUP_FOR_TYPE' <path_resolved_user_defined_type_name> || 'CURRENT_USER' || 'SESSION_USER' || 'SYSTEM_USER' || 'USER' || 'VALUE' }
token basic_identifier_chain { <identifier_chain> }
rule aggregate_function { 'COUNT' <left_paren> <asterisk> <right_paren> [ <filter_clause> ]? || <general_set_function> [ <filter_clause> ]? || <binary_set_function> [ <filter_clause> ]? || <ordered_set_function> [ <filter_clause> ]? }
rule grouping_operation { 'GROUPING' <left_paren> <column_reference> [ [[ [ <comma> <column_reference> ] ]* ] ]? <right_paren> }
token window_function_type { <rank_function_type> <left_paren> <right_paren> || 'ROW_NUMBER' <left_paren> <right_paren> || <aggregate_function> }
token window_name_or_specification { <window_name> || <in_line_window_specification> }
rule case_abbreviation { 'NULLIF' <left_paren> <value_expression> <comma> <value_expression> <right_paren> || 'COALESCE' <left_paren> <value_expression> [[ [ <comma> <value_expression> ] ]+ ] <right_paren> }
token case_specification { <simple_case> || <searched_case> }
token cast_operand { <value_expression> || <implicitly_typed_value_specification> }
token cast_target { <domain_name> || <data_type> }
token field_name { <identifier> }
token subtype_operand { <value_expression> }
token target_subtype { <path_resolved_user_defined_type_name> || <reference_type> }
rule direct_invocation { <value_expression_primary> <period> <method_name> [ <SQL_argument_list> ]? }
rule generalized_invocation { <left_paren> <value_expression_primary> 'AS' <data_type> <right_paren> <period> <method_name> [ <SQL_argument_list> ]? }
token path_resolved_user_defined_type_name { <user_defined_type_name> }
rule double_colon { <colon> <colon> }
token method_name { <identifier> }
rule SQL_argument_list { <left_paren> [ <SQL_argument> [ [[ [ <comma> <SQL_argument> ] ]* ] ]? ]? <right_paren> }
token dereference_operator { <right_arrow> }
token array_value_constructor { <array_value_constructor_by_enumeration> || <array_value_constructor_by_query> }
token multiset_value_constructor { <multiset_value_constructor_by_enumeration> || <multiset_value_constructor_by_query> || <table_value_constructor_by_query> }
token left_bracket_or_trigraph { <left_bracket> || <left_bracket_trigraph> }
token right_bracket_or_trigraph { <right_bracket> || <right_bracket_trigraph> }
rule routine_name { [ <schema_name> <period> ]? <qualified_identifier> }
token sequence_generator_name { <schema_qualified_name> }
rule as_clause { [ 'AS' ]? <column_name> }
rule asterisked_identifier_chain { <asterisked_identifier> [ [[ [ <period> <asterisked_identifier> ] ]* ] ]? }
rule all_fields_reference { <value_expression_primary> <period> <asterisk> [ 'AS' <left_paren> <all_fields_column_name_list> <right_paren> ]? }
token grouping_element { <ordinary_grouping_set> || <rollup_list> || <cube_list> || <grouping_sets_specification> || <empty_grouping_set> }
rule window_definition { <new_window_name> 'AS' <window_specification> }
token catalog_name { <identifier> }
token unqualified_schema_name { <identifier> }
token vertical_bar { '|' }
token multiset_value_function { <multiset_set_function> }
token numeric_value_function { <position_expression> || <extract_expression> || <length_expression> || <cardinality_expression> || <absolute_value_expression> || <modulus_expression> || <natural_logarithm> || <exponential_function> || <power_function> || <square_root> || <floor_function> || <ceiling_function> || <width_bucket_function> }
token string_value_function { <character_value_function> || <blob_value_function> }
token collation_name { <schema_qualified_name> }
token datetime_value_function { <current_date_value_function> || <current_time_value_function> || <current_timestamp_value_function> || <current_local_time_value_function> || <current_local_timestamp_value_function> }
token time_zone_specifier { 'LOCAL' || 'TIME' 'ZONE' <interval_primary> }
token interval_value_function { <interval_absolute_value_function> }
token unsigned_integer { [[ <digit> ]+ ] }
token predicate { <comparison_predicate> || <between_predicate> || <in_predicate> || <like_predicate> || <similar_predicate> || <null_predicate> || <quantified_comparison_predicate> || <exists_predicate> || <unique_predicate> || <normalized_predicate> || <match_predicate> || <overlaps_predicate> || <distinct_predicate> || <member_predicate> || <submultiset_predicate> || <set_predicate> || <type_predicate> }
token boolean_predicand { <parenthesized_boolean_value_expression> || <nonparenthesized_value_expression_primary> }
token unsigned_numeric_literal { <exact_numeric_literal> || <approximate_numeric_literal> }
token general_literal { <character_string_literal> || <national_character_string_literal> || <Unicode_character_string_literal> || <binary_string_literal> || <datetime_literal> || <interval_literal> || <boolean_literal> }
rule host_parameter_specification { <host_parameter_name> [ <indicator_parameter> ]? }
token SQL_parameter_reference { <basic_identifier_chain> }
token dynamic_parameter_specification { <question_mark> }
rule embedded_variable_specification { <embedded_variable_name> [ <indicator_variable> ]? }
rule current_collation_specification { 'CURRENT_COLLATION' <left_paren> <string_value_expression> <right_paren> }
rule identifier_chain { <identifier> [ [[ [ <period> <identifier> ] ]* ] ]? }
rule filter_clause { 'FILTER' <left_paren> 'WHERE' <search_condition> <right_paren> }
rule general_set_function { <set_function_type> <left_paren> [ <set_quantifier> ]? <value_expression> <right_paren> }
rule binary_set_function { <binary_set_function_type> <left_paren> <dependent_variable_expression> <comma> <independent_variable_expression> <right_paren> }
token ordered_set_function { <hypothetical_set_function> || <inverse_distribution_function> }
token rank_function_type { 'RANK' || 'DENSE_RANK' || 'PERCENT_RANK' || 'CUME_DIST' }
token window_name { <identifier> }
token in_line_window_specification { <window_specification> }
rule simple_case { 'CASE' <case_operand> [[ <simple_when_clause> ]+ ] [ <else_clause> ]? 'END' }
rule searched_case { 'CASE' [[ <searched_when_clause> ]+ ] [ <else_clause> ]? 'END' }
token implicitly_typed_value_specification { <null_specification> || <empty_specification> }
token domain_name { <schema_qualified_name> }
token data_type { <predefined_type> || <row_type> || <path_resolved_user_defined_type_name> || <reference_type> || <collection_type> }
rule reference_type { 'REF' <left_paren> <referenced_type> <right_paren> [ <scope_clause> ]? }
token user_defined_type_name { <schema_qualified_type_name> }
token colon { ':' }
token SQL_argument { <value_expression> || <generalized_expression> || <target_specification> }
rule right_arrow { <minus_sign> <greater_than_operator> }
rule array_value_constructor_by_enumeration { 'ARRAY' <left_bracket_or_trigraph> <array_element_list> <right_bracket_or_trigraph> }
rule array_value_constructor_by_query { 'ARRAY' <left_paren> <query_expression> [ <order_by_clause> ]? <right_paren> }
rule multiset_value_constructor_by_enumeration { 'MULTISET' <left_bracket_or_trigraph> <multiset_element_list> <right_bracket_or_trigraph> }
rule multiset_value_constructor_by_query { 'MULTISET' <left_paren> <query_expression> <right_paren> }
rule table_value_constructor_by_query { 'TABLE' <left_paren> <query_expression> <right_paren> }
token left_bracket { '[' }
token left_bracket_trigraph { '??(' }
token right_bracket { ']' }
token right_bracket_trigraph { '??)' }
rule schema_qualified_name { [ <schema_name> <period> ]? <qualified_identifier> }
token asterisked_identifier { <identifier> }
token all_fields_column_name_list { <column_name_list> }
token ordinary_grouping_set { <grouping_column_reference> || <left_paren> <grouping_column_reference_list> <right_paren> }
rule rollup_list { 'ROLLUP' <left_paren> <ordinary_grouping_set_list> <right_paren> }
rule cube_list { 'CUBE' <left_paren> <ordinary_grouping_set_list> <right_paren> }
rule grouping_sets_specification { 'GROUPING' 'SETS' <left_paren> <grouping_set_list> <right_paren> }
rule empty_grouping_set { <left_paren> <right_paren> }
token new_window_name { <window_name> }
rule window_specification { <left_paren> <window_specification_details> <right_paren> }
rule multiset_set_function { 'SET' <left_paren> <multiset_value_expression> <right_paren> }
token position_expression { <string_position_expression> || <blob_position_expression> }
rule extract_expression { 'EXTRACT' <left_paren> <extract_field> 'FROM' <extract_source> <right_paren> }
token length_expression { <char_length_expression> || <octet_length_expression> }
rule cardinality_expression { 'CARDINALITY' <left_paren> <collection_value_expression> <right_paren> }
rule absolute_value_expression { 'ABS' <left_paren> <numeric_value_expression> <right_paren> }
rule modulus_expression { 'MOD' <left_paren> <numeric_value_expression_dividend> <comma> <numeric_value_expression_divisor> <right_paren> }
rule natural_logarithm { 'LN' <left_paren> <numeric_value_expression> <right_paren> }
rule exponential_function { 'EXP' <left_paren> <numeric_value_expression> <right_paren> }
rule power_function { 'POWER' <left_paren> <numeric_value_expression_base> <comma> <numeric_value_expression_exponent> <right_paren> }
rule square_root { 'SQRT' <left_paren> <numeric_value_expression> <right_paren> }
rule floor_function { 'FLOOR' <left_paren> <numeric_value_expression> <right_paren> }
rule ceiling_function { [ 'CEIL' || 'CEILING' ] <left_paren> <numeric_value_expression> <right_paren> }
rule width_bucket_function { 'WIDTH_BUCKET' <left_paren> <width_bucket_operand> <comma> <width_bucket_bound_1> <comma> <width_bucket_bound_2> <comma> <width_bucket_count> <right_paren> }
token character_value_function { <character_substring_function> || <regular_expression_substring_function> || <fold> || <transcoding> || <character_transliteration> || <trim_function> || <character_overlay_function> || <normalize_function> || <specific_type_method> }
token blob_value_function { <blob_substring_function> || <blob_trim_function> || <blob_overlay_function> }
token current_date_value_function { 'CURRENT_DATE' }
rule current_time_value_function { 'CURRENT_TIME' [ <left_paren> <time_precision> <right_paren> ]? }
rule current_timestamp_value_function { 'CURRENT_TIMESTAMP' [ <left_paren> <timestamp_precision> <right_paren> ]? }
rule current_local_time_value_function { 'LOCALTIME' [ <left_paren> <time_precision> <right_paren> ]? }
rule current_local_timestamp_value_function { 'LOCALTIMESTAMP' [ <left_paren> <timestamp_precision> <right_paren> ]? }
rule interval_absolute_value_function { 'ABS' <left_paren> <interval_value_expression> <right_paren> }
token digit { '0' || '1' || '2' || '3' || '4' || '5' || '6' || '7' || '8' || '9' }
rule comparison_predicate { <row_value_predicand> <comparison_predicate_part_2> }
rule between_predicate { <row_value_predicand> <between_predicate_part_2> }
rule in_predicate { <row_value_predicand> <in_predicate_part_2> }
token like_predicate { <character_like_predicate> || <octet_like_predicate> }
rule similar_predicate { <row_value_predicand> <similar_predicate_part_2> }
rule null_predicate { <row_value_predicand> <null_predicate_part_2> }
rule quantified_comparison_predicate { <row_value_predicand> <quantified_comparison_predicate_part_2> }
rule exists_predicate { 'EXISTS' <table_subquery> }
rule unique_predicate { 'UNIQUE' <table_subquery> }
rule normalized_predicate { <string_value_expression> 'IS' [ 'NOT' ]? 'NORMALIZED' }
rule match_predicate { <row_value_predicand> <match_predicate_part_2> }
rule overlaps_predicate { <overlaps_predicate_part_1> <overlaps_predicate_part_2> }
rule distinct_predicate { <row_value_predicand_3> <distinct_predicate_part_2> }
rule member_predicate { <row_value_predicand> <member_predicate_part_2> }
rule submultiset_predicate { <row_value_predicand> <submultiset_predicate_part_2> }
rule set_predicate { <row_value_predicand> <set_predicate_part_2> }
rule type_predicate { <row_value_predicand> <type_predicate_part_2> }
rule parenthesized_boolean_value_expression { <left_paren> <boolean_value_expression> <right_paren> }
rule exact_numeric_literal { <unsigned_integer> [ <period> [ <unsigned_integer> ]? ]? || <period> <unsigned_integer> }
rule approximate_numeric_literal { <mantissa> 'E' <exponent> }
rule character_string_literal { [ <introducer> <character_set_specification> ]? <quote> [ [[ <character_representation> ]* ] ]? <quote> [ [[ [ <separator> <quote> [ [[ <character_representation> ]* ] ]? <quote> ] ]* ] ]? }
rule national_character_string_literal { 'N' <quote> [ [[ <character_representation> ]* ] ]? <quote> [ [[ [ <separator> <quote> [ [[ <character_representation> ]* ] ]? <quote> ] ]* ] ]? }
rule Unicode_character_string_literal { [ <introducer> <character_set_specification> ]? 'U' <ampersand> <quote> [ [[ <Unicode_representation> ]* ] ]? <quote> [ [[ [ <separator> <quote> [ [[ <Unicode_representation> ]* ] ]? <quote> ] ]* ] ]? [ 'ESCAPE' <escape_character> ]? }
rule binary_string_literal { 'X' <quote> [ [[ [ <hexit> <hexit> ] ]* ] ]? <quote> [ [[ [ <separator> <quote> [ [[ [ <hexit> <hexit> ] ]* ] ]? <quote> ] ]* ] ]? [ 'ESCAPE' <escape_character> ]? }
token datetime_literal { <date_literal> || <time_literal> || <timestamp_literal> }
rule interval_literal { 'INTERVAL' [ <sign> ]? <interval_string> <interval_qualifier> }
token boolean_literal { 'TRUE' || 'FALSE' || 'UNKNOWN' }
rule host_parameter_name { <colon> <identifier> }
rule indicator_parameter { [ 'INDICATOR' ]? <host_parameter_name> }
token question_mark { '?' }
rule embedded_variable_name { <colon> <host_identifier> }
rule indicator_variable { [ 'INDICATOR' ]? <embedded_variable_name> }
token set_function_type { <computational_operation> }
token binary_set_function_type { 'COVAR_POP' || 'COVAR_SAMP' || 'CORR' || 'REGR_SLOPE' || 'REGR_INTERCEPT' || 'REGR_COUNT' || 'REGR_R2' || 'REGR_AVGX' || 'REGR_AVGY' || 'REGR_SXX' || 'REGR_SYY' || 'REGR_SXY' }
token dependent_variable_expression { <numeric_value_expression> }
token independent_variable_expression { <numeric_value_expression> }
rule hypothetical_set_function { <rank_function_type> <left_paren> <hypothetical_set_function_value_expression_list> <right_paren> <within_group_specification> }
rule inverse_distribution_function { <inverse_distribution_function_type> <left_paren> <inverse_distribution_function_argument> <right_paren> <within_group_specification> }
token case_operand { <row_value_predicand> || <overlaps_predicate> }
rule simple_when_clause { 'WHEN' <when_operand> 'THEN' <result> }
rule else_clause { 'ELSE' <result> }
rule searched_when_clause { 'WHEN' <search_condition> 'THEN' <result> }
token null_specification { 'NULL' }
rule empty_specification { 'ARRAY' <left_bracket_or_trigraph> <right_bracket_or_trigraph> || 'MULTISET' <left_bracket_or_trigraph> <right_bracket_or_trigraph> }
token predefined_type { <character_string_type> [ 'CHARACTER' 'SET' <character_set_specification> ]? [ <collate_clause> ]? || <national_character_string_type> [ <collate_clause> ]? || <binary_large_object_string_type> || <numeric_type> || <boolean_type> || <datetime_type> || <interval_type> }
rule row_type { 'ROW' <row_type_body> }
token collection_type { <array_type> || <multiset_type> }
token referenced_type { <path_resolved_user_defined_type_name> }
rule scope_clause { 'SCOPE' <table_name> }
rule schema_qualified_type_name { [ <schema_name> <period> ]? <qualified_identifier> }
rule generalized_expression { <value_expression> 'AS' <path_resolved_user_defined_type_name> }
token target_specification { <host_parameter_specification> || <SQL_parameter_reference> || <column_reference> || <target_array_element_specification> || <dynamic_parameter_specification> || <embedded_variable_specification> }
token greater_than_operator { '>' }
rule array_element_list { <array_element> [ [[ [ <comma> <array_element> ] ]* ] ]? }
rule multiset_element_list { <multiset_element> [ [ <comma> <multiset_element> ] ]? }
rule grouping_column_reference { <column_reference> [ <collate_clause> ]? }
rule grouping_column_reference_list { <grouping_column_reference> [ [[ [ <comma> <grouping_column_reference> ] ]* ] ]? }
rule ordinary_grouping_set_list { <ordinary_grouping_set> [ [[ [ <comma> <ordinary_grouping_set> ] ]* ] ]? }
rule grouping_set_list { <grouping_set> [ [[ [ <comma> <grouping_set> ] ]* ] ]? }
rule window_specification_details { [ <existing_window_name> ]? [ <window_partition_clause> ]? [ <window_order_clause> ]? [ <window_frame_clause> ]? }
rule string_position_expression { 'POSITION' <left_paren> <string_value_expression> 'IN' <string_value_expression> [ 'USING' <char_length_units> ]? <right_paren> }
rule blob_position_expression { 'POSITION' <left_paren> <blob_value_expression> 'IN' <blob_value_expression> <right_paren> }
token extract_field { <primary_datetime_field> || <time_zone_field> }
token extract_source { <datetime_value_expression> || <interval_value_expression> }
rule char_length_expression { [ 'CHAR_LENGTH' || 'CHARACTER_LENGTH' ] <left_paren> <string_value_expression> [ 'USING' <char_length_units> ]? <right_paren> }
rule octet_length_expression { 'OCTET_LENGTH' <left_paren> <string_value_expression> <right_paren> }
token numeric_value_expression_dividend { <numeric_value_expression> }
token numeric_value_expression_divisor { <numeric_value_expression> }
token numeric_value_expression_base { <numeric_value_expression> }
token numeric_value_expression_exponent { <numeric_value_expression> }
token width_bucket_operand { <numeric_value_expression> }
token width_bucket_bound_1 { <numeric_value_expression> }
token width_bucket_bound_2 { <numeric_value_expression> }
token width_bucket_count { <numeric_value_expression> }
rule character_substring_function { 'SUBSTRING' <left_paren> <character_value_expression> 'FROM' <start_position> [ 'FOR' <string_length> ]? [ 'USING' <char_length_units> ]? <right_paren> }
rule regular_expression_substring_function { 'SUBSTRING' <left_paren> <character_value_expression> 'SIMILAR' <character_value_expression> 'ESCAPE' <escape_character> <right_paren> }
rule fold { [ 'UPPER' || 'LOWER' ] <left_paren> <character_value_expression> <right_paren> }
rule transcoding { 'CONVERT' <left_paren> <character_value_expression> 'USING' <transcoding_name> <right_paren> }
rule character_transliteration { 'TRANSLATE' <left_paren> <character_value_expression> 'USING' <transliteration_name> <right_paren> }
rule trim_function { 'TRIM' <left_paren> <trim_operands> <right_paren> }
rule character_overlay_function { 'OVERLAY' <left_paren> <character_value_expression> 'PLACING' <character_value_expression> 'FROM' <start_position> [ 'FOR' <string_length> ]? [ 'USING' <char_length_units> ]? <right_paren> }
rule normalize_function { 'NORMALIZE' <left_paren> <character_value_expression> <right_paren> }
rule specific_type_method { <user_defined_type_value_expression> <period> 'SPECIFICTYPE' }
rule blob_substring_function { 'SUBSTRING' <left_paren> <blob_value_expression> 'FROM' <start_position> [ 'FOR' <string_length> ]? <right_paren> }
rule blob_trim_function { 'TRIM' <left_paren> <blob_trim_operands> <right_paren> }
rule blob_overlay_function { 'OVERLAY' <left_paren> <blob_value_expression> 'PLACING' <blob_value_expression> 'FROM' <start_position> [ 'FOR' <string_length> ]? <right_paren> }
token time_precision { <time_fractional_seconds_precision> }
token timestamp_precision { <time_fractional_seconds_precision> }
token row_value_predicand { <row_value_special_case> || <row_value_constructor_predicand> }
rule comparison_predicate_part_2 { <comp_op> <row_value_predicand> }
rule between_predicate_part_2 { [ 'NOT' ]? 'BETWEEN' [ 'ASYMMETRIC' || 'SYMMETRIC' ]? <row_value_predicand> 'AND' <row_value_predicand> }
rule in_predicate_part_2 { [ 'NOT' ]? 'IN' <in_predicate_value> }
rule character_like_predicate { <row_value_predicand> <character_like_predicate_part_2> }
rule octet_like_predicate { <row_value_predicand> <octet_like_predicate_part_2> }
rule similar_predicate_part_2 { [ 'NOT' ]? 'SIMILAR' 'TO' <similar_pattern> [ 'ESCAPE' <escape_character> ]? }
rule null_predicate_part_2 { 'IS' [ 'NOT' ]? 'NULL' }
rule quantified_comparison_predicate_part_2 { <comp_op> <quantifier> <table_subquery> }
rule match_predicate_part_2 { 'MATCH' [ 'UNIQUE' ]? [ 'SIMPLE' || 'PARTIAL' || 'FULL' ]? <table_subquery> }
token overlaps_predicate_part_1 { <row_value_predicand_1> }
rule overlaps_predicate_part_2 { 'OVERLAPS' <row_value_predicand_2> }
token row_value_predicand_3 { <row_value_predicand> }
rule distinct_predicate_part_2 { 'IS' 'DISTINCT' 'FROM' <row_value_predicand_4> }
rule member_predicate_part_2 { [ 'NOT' ]? 'MEMBER' [ 'OF' ]? <multiset_value_expression> }
rule submultiset_predicate_part_2 { [ 'NOT' ]? 'SUBMULTISET' [ 'OF' ]? <multiset_value_expression> }
rule set_predicate_part_2 { 'IS' [ 'NOT' ]? 'A' 'SET' }
rule type_predicate_part_2 { 'IS' [ 'NOT' ]? 'OF' <left_paren> <type_list> <right_paren> }
token mantissa { <exact_numeric_literal> }
token exponent { <signed_integer> }
token introducer { <underscore> }
token character_set_specification { <standard_character_set_name> || <implementation_defined_character_set_name> || <user_defined_character_set_name> }
token quote { "'" }
token character_representation { <nonquote_character> || <quote_symbol> }
token separator { [[ [ <comment> || <white_space> ] ]+ ] }
token ampersand { '&' }
token Unicode_representation { <character_representation> || <Unicode_escape_value> }
token escape_character { <character_value_expression> }
token hexit { <digit> || 'A' || 'B' || 'C' || 'D' || 'E' || 'F' || 'a' || 'b' || 'c' || 'd' || 'e' || 'f' }
rule date_literal { 'DATE' <date_string> }
rule time_literal { 'TIME' <time_string> }
rule timestamp_literal { 'TIMESTAMP' <timestamp_string> }
rule interval_string { <quote> <unquoted_interval_string> <quote> }
token host_identifier { <Ada_host_identifier> || <C_host_identifier> || <COBOL_host_identifier> || <Fortran_host_identifier> || <MUMPS_host_identifier> || <Pascal_host_identifier> || <PL_I_host_identifier> }
token computational_operation { 'AVG' || 'MAX' || 'MIN' || 'SUM' || 'EVERY' || 'ANY' || 'SOME' || 'COUNT' || 'STDDEV_POP' || 'STDDEV_SAMP' || 'VAR_SAMP' || 'VAR_POP' || 'COLLECT' || 'FUSION' || 'INTERSECTION' }
rule hypothetical_set_function_value_expression_list { <value_expression> [ [[ [ <comma> <value_expression> ] ]* ] ]? }
rule within_group_specification { 'WITHIN' 'GROUP' <left_paren> 'ORDER' 'BY' <sort_specification_list> <right_paren> }
token inverse_distribution_function_type { 'PERCENTILE_CONT' || 'PERCENTILE_DISC' }
token inverse_distribution_function_argument { <numeric_value_expression> }
token when_operand { <row_value_predicand> || <comparison_predicate_part_2> || <between_predicate_part_2> || <in_predicate_part_2> || <character_like_predicate_part_2> || <octet_like_predicate_part_2> || <similar_predicate_part_2> || <null_predicate_part_2> || <quantified_comparison_predicate_part_2> || <match_predicate_part_2> || <overlaps_predicate_part_2> || <distinct_predicate_part_2> || <member_predicate_part_2> || <submultiset_predicate_part_2> || <set_predicate_part_2> || <type_predicate_part_2> }
token result { <result_expression> || 'NULL' }
rule character_string_type { 'CHARACTER' [ <left_paren> <length> <right_paren> ]? || 'CHAR' [ <left_paren> <length> <right_paren> ]? || 'CHARACTER' 'VARYING' <left_paren> <length> <right_paren> || 'CHAR' 'VARYING' <left_paren> <length> <right_paren> || 'VARCHAR' <left_paren> <length> <right_paren> || 'CHARACTER' 'LARGE' 'OBJECT' [ <left_paren> <large_object_length> <right_paren> ]? || 'CHAR' 'LARGE' 'OBJECT' [ <left_paren> <large_object_length> <right_paren> ]? || 'CLOB' [ <left_paren> <large_object_length> <right_paren> ]? }
rule national_character_string_type { 'NATIONAL' 'CHARACTER' [ <left_paren> <length> <right_paren> ]? || 'NATIONAL' 'CHAR' [ <left_paren> <length> <right_paren> ]? || 'NCHAR' [ <left_paren> <length> <right_paren> ]? || 'NATIONAL' 'CHARACTER' 'VARYING' <left_paren> <length> <right_paren> || 'NATIONAL' 'CHAR' 'VARYING' <left_paren> <length> <right_paren> || 'NCHAR' 'VARYING' <left_paren> <length> <right_paren> || 'NATIONAL' 'CHARACTER' 'LARGE' 'OBJECT' [ <left_paren> <large_object_length> <right_paren> ]? || 'NCHAR' 'LARGE' 'OBJECT' [ <left_paren> <large_object_length> <right_paren> ]? || 'NCLOB' [ <left_paren> <large_object_length> <right_paren> ]? }
rule binary_large_object_string_type { 'BINARY' 'LARGE' 'OBJECT' [ <left_paren> <large_object_length> <right_paren> ]? || 'BLOB' [ <left_paren> <large_object_length> <right_paren> ]? }
token numeric_type { <exact_numeric_type> || <approximate_numeric_type> }
token boolean_type { 'BOOLEAN' }
token datetime_type { 'DATE' || 'TIME' [ <left_paren> <time_precision> <right_paren> ]? [ <with_or_without_time_zone> ]? || 'TIMESTAMP' [ <left_paren> <timestamp_precision> <right_paren> ]? [ <with_or_without_time_zone> ]? }
rule interval_type { 'INTERVAL' <interval_qualifier> }
rule row_type_body { <left_paren> <field_definition> [ [[ [ <comma> <field_definition> ] ]* ] ]? <right_paren> }
rule array_type { <data_type> 'ARRAY' [ <left_bracket_or_trigraph> <unsigned_integer> <right_bracket_or_trigraph> ]? }
rule multiset_type { <data_type> 'MULTISET' }
rule target_array_element_specification { <target_array_reference> <left_bracket_or_trigraph> <simple_value_specification> <right_bracket_or_trigraph> }
token array_element { <value_expression> }
token multiset_element { <value_expression> }
token grouping_set { <ordinary_grouping_set> || <rollup_list> || <cube_list> || <grouping_sets_specification> || <empty_grouping_set> }
token existing_window_name { <window_name> }
rule window_partition_clause { 'PARTITION' 'BY' <window_partition_column_reference_list> }
rule window_order_clause { 'ORDER' 'BY' <sort_specification_list> }
rule window_frame_clause { <window_frame_units> <window_frame_extent> [ <window_frame_exclusion> ]? }
token char_length_units { 'CHARACTERS' || 'CODE_UNITS' || 'OCTETS' }
token primary_datetime_field { <non_second_primary_datetime_field> || 'SECOND' }
token time_zone_field { 'TIMEZONE_HOUR' || 'TIMEZONE_MINUTE' }
token start_position { <numeric_value_expression> }
token string_length { <numeric_value_expression> }
token transcoding_name { <schema_qualified_name> }
token transliteration_name { <schema_qualified_name> }
rule trim_operands { [ [ <trim_specification> ]? [ <trim_character> ]? 'FROM' ]? <trim_source> }
rule blob_trim_operands { [ [ <trim_specification> ]? [ <trim_octet> ]? 'FROM' ]? <blob_trim_source> }
token time_fractional_seconds_precision { <unsigned_integer> }
token row_value_constructor_predicand { <common_value_expression> || <boolean_predicand> || <explicit_row_value_constructor> }
token comp_op { <equals_operator> || <not_equals_operator> || <less_than_operator> || <greater_than_operator> || <less_than_or_equals_operator> || <greater_than_or_equals_operator> }
token in_predicate_value { <table_subquery> || <left_paren> <in_value_list> <right_paren> }
rule character_like_predicate_part_2 { [ 'NOT' ]? 'LIKE' <character_pattern> [ 'ESCAPE' <escape_character> ]? }
rule octet_like_predicate_part_2 { [ 'NOT' ]? 'LIKE' <octet_pattern> [ 'ESCAPE' <escape_octet> ]? }
token similar_pattern { <character_value_expression> }
token quantifier { <all> || <some> }
token row_value_predicand_1 { <row_value_predicand> }
token row_value_predicand_2 { <row_value_predicand> }
token row_value_predicand_4 { <row_value_predicand> }
rule type_list { <user_defined_type_specification> [ [[ [ <comma> <user_defined_type_specification> ] ]* ] ]? }
rule signed_integer { [ <sign> ]? <unsigned_integer> }
token underscore { '_' }
token standard_character_set_name { <character_set_name> }
token implementation_defined_character_set_name { <character_set_name> }
token user_defined_character_set_name { <character_set_name> }
token nonquote_character { \w }
rule quote_symbol { <quote> <quote> }
token comment { <simple_comment> || <bracketed_comment> }
token Unicode_escape_value { <Unicode_4_digit_escape_value> || <Unicode_6_digit_escape_value> || <Unicode_character_escape_value> }
rule date_string { <quote> <unquoted_date_string> <quote> }
rule time_string { <quote> <unquoted_time_string> <quote> }
rule timestamp_string { <quote> <unquoted_timestamp_string> <quote> }
rule unquoted_interval_string { [ <sign> ]? [ <year_month_literal> || <day_time_literal> ] }
token Ada_host_identifier { \w }
token C_host_identifier { \w }
token COBOL_host_identifier { \w }
token Fortran_host_identifier { \w }
token MUMPS_host_identifier { \w }
token Pascal_host_identifier { \w }
token PL_I_host_identifier { \w }
token result_expression { <value_expression> }
token length { <unsigned_integer> }
rule large_object_length { <unsigned_integer> [ <multiplier> ]? [ <char_length_units> ]? || <large_object_length_token> [ <char_length_units> ]? }
token exact_numeric_type { 'NUMERIC' [ <left_paren> <precision> [ <comma> <scale> ]? <right_paren> ]? || 'DECIMAL' [ <left_paren> <precision> [ <comma> <scale> ]? <right_paren> ]? || 'DEC' [ <left_paren> <precision> [ <comma> <scale> ]? <right_paren> ]? || 'SMALLINT' || 'INTEGER' || 'INT' || 'BIGINT' }
token approximate_numeric_type { 'FLOAT' [ <left_paren> <precision> <right_paren> ]? || 'REAL' || 'DOUBLE' 'PRECISION' }
rule with_or_without_time_zone { 'WITH' 'TIME' 'ZONE' || 'WITHOUT' 'TIME' 'ZONE' }
rule field_definition { <field_name> <data_type> [ <reference_scope_check> ]? }
token target_array_reference { <SQL_parameter_reference> || <column_reference> }
token simple_value_specification { <literal> || <host_parameter_name> || <SQL_parameter_reference> || <embedded_variable_name> }
rule window_partition_column_reference_list { <window_partition_column_reference> [ [[ [ <comma> <window_partition_column_reference> ] ]* ] ]? }
token window_frame_units { 'ROWS' || 'RANGE' }
token window_frame_extent { <window_frame_start> || <window_frame_between> }
rule window_frame_exclusion { 'EXCLUDE' 'CURRENT' 'ROW' || 'EXCLUDE' 'GROUP' || 'EXCLUDE' 'TIES' || 'EXCLUDE' 'NO' 'OTHERS' }
token trim_specification { 'LEADING' || 'TRAILING' || 'BOTH' }
token trim_character { <character_value_expression> }
token trim_source { <character_value_expression> }
token trim_octet { <blob_value_expression> }
token blob_trim_source { <blob_value_expression> }
token equals_operator { '=' }
rule not_equals_operator { <less_than_operator> <greater_than_operator> }
token less_than_operator { '<' }
rule less_than_or_equals_operator { <less_than_operator> <equals_operator> }
rule greater_than_or_equals_operator { <greater_than_operator> <equals_operator> }
rule in_value_list { <row_value_expression> [ [[ [ <comma> <row_value_expression> ] ]* ] ]? }
token character_pattern { <character_value_expression> }
token octet_pattern { <blob_value_expression> }
token escape_octet { <blob_value_expression> }
token all { 'ALL' }
token some { 'SOME' || 'ANY' }
token user_defined_type_specification { <inclusive_user_defined_type_specification> || <exclusive_user_defined_type_specification> }
rule character_set_name { [ <schema_name> <period> ]? <SQL_language_identifier> }
rule simple_comment { <simple_comment_introducer> [ [[ <comment_character> ]* ] ]? <newline> }
rule bracketed_comment { <bracketed_comment_introducer> <bracketed_comment_contents> <bracketed_comment_terminator> }
rule Unicode_4_digit_escape_value { <Unicode_escape_character> <hexit> <hexit> <hexit> <hexit> }
rule Unicode_6_digit_escape_value { <Unicode_escape_character> <plus_sign> <hexit> <hexit> <hexit> <hexit> <hexit> <hexit> }
rule Unicode_character_escape_value { <Unicode_escape_character> <Unicode_escape_character> }
token unquoted_date_string { <date_value> }
rule unquoted_time_string { <time_value> [ <time_zone_interval> ]? }
rule unquoted_timestamp_string { <unquoted_date_string> <space> <unquoted_time_string> }
token year_month_literal { <years_value> || [ <years_value> <minus_sign> ]? <months_value> }
token day_time_literal { <day_time_interval> || <time_interval> }
token multiplier { 'K' || 'M' || 'G' }
rule large_object_length_token { [[ <digit> ]+ ] <multiplier> }
token precision { <unsigned_integer> }
token scale { <unsigned_integer> }
rule reference_scope_check { 'REFERENCES' 'ARE' [ 'NOT' ]? 'CHECKED' [ 'ON' 'DELETE' <reference_scope_check_action> ]? }
token literal { <signed_numeric_literal> || <general_literal> }
rule window_partition_column_reference { <column_reference> [ <collate_clause> ]? }
token window_frame_start { 'UNBOUNDED' 'PRECEDING' || <window_frame_preceding> || 'CURRENT' 'ROW' }
rule window_frame_between { 'BETWEEN' <window_frame_bound_1> 'AND' <window_frame_bound_2> }
token inclusive_user_defined_type_specification { <path_resolved_user_defined_type_name> }
rule exclusive_user_defined_type_specification { 'ONLY' <path_resolved_user_defined_type_name> }
rule SQL_language_identifier { <SQL_language_identifier_start> [ [[ [ <underscore> || <SQL_language_identifier_part> ] ]* ] ]? }
rule simple_comment_introducer { <minus_sign> <minus_sign> [ [[ <minus_sign> ]* ] ]? }
token comment_character { <nonquote_character> || <quote> }
token newline { \n }
rule bracketed_comment_introducer { <slash> <asterisk> }
token bracketed_comment_contents { [ [[ [ <comment_character> || <separator> ] ]* ] ]? }
rule bracketed_comment_terminator { <asterisk> <slash> }
rule Unicode_escape_character { '\w(15-18' 'above).' }
rule date_value { <years_value> <minus_sign> <months_value> <minus_sign> <days_value> }
rule time_value { <hours_value> <colon> <minutes_value> <colon> <seconds_value> }
rule time_zone_interval { <sign> <hours_value> <colon> <minutes_value> }
token space { ' ' }
token years_value { <datetime_value> }
token months_value { <datetime_value> }
rule day_time_interval { <days_value> [ <space> <hours_value> [ <colon> <minutes_value> [ <colon> <seconds_value> ]? ]? ]? }
token time_interval { <hours_value> [ <colon> <minutes_value> [ <colon> <seconds_value> ]? ]? || <minutes_value> [ <colon> <seconds_value> ]? || <seconds_value> }
token reference_scope_check_action { <referential_action> }
rule signed_numeric_literal { [ <sign> ]? <unsigned_numeric_literal> }
rule window_frame_preceding { <unsigned_value_specification> 'PRECEDING' }
token window_frame_bound_1 { <window_frame_bound> }
token window_frame_bound_2 { <window_frame_bound> }
token SQL_language_identifier_start { <simple_Latin_letter> }
token SQL_language_identifier_part { <simple_Latin_letter> || <digit> }
token days_value { <datetime_value> }
token hours_value { <datetime_value> }
token minutes_value { <datetime_value> }
rule seconds_value { <seconds_integer_value> [ <period> [ <seconds_fraction> ]? ]? }
token datetime_value { <unsigned_integer> }
token referential_action { 'CASCADE' || 'SET' 'NULL' || 'SET' 'DEFAULT' || 'RESTRICT' || 'NO' 'ACTION' }
token window_frame_bound { <window_frame_start> || 'UNBOUNDED' 'FOLLOWING' || <window_frame_following> }
token simple_Latin_letter { <simple_Latin_upper_case_letter> || <simple_Latin_lower_case_letter> }
token seconds_integer_value { <unsigned_integer> }
token seconds_fraction { <unsigned_integer> }
rule window_frame_following { <unsigned_value_specification> 'FOLLOWING' }
token simple_Latin_upper_case_letter { 'A' || 'B' || 'C' || 'D' || 'E' || 'F' || 'G' || 'H' || 'I' || 'J' || 'K' || 'L' || 'M' || 'N' || 'O' || 'P' || 'Q' || 'R' || 'S' || 'T' || 'U' || 'V' || 'W' || 'X' || 'Y' || 'Z' }
token simple_Latin_lower_case_letter { 'a' || 'b' || 'c' || 'd' || 'e' || 'f' || 'g' || 'h' || 'i' || 'j' || 'k' || 'l' || 'm' || 'n' || 'o' || 'p' || 'q' || 'r' || 's' || 't' || 'u' || 'v' || 'w' || 'x' || 'y' || 'z' }

=begin pod

=head1 NAME

SQL::Grammar - blah blah blah

=head1 SYNOPSIS

=begin code :lang<perl6>

use SQL::Grammar;

=end code

=head1 DESCRIPTION

SQL::Grammar is ...

=head1 AUTHOR

Stefan Seifert <nine@detonation.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Stefan Seifert

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
