/* description: Parses a shipping DSL. */

/* lexical grammar */
%lex
%%

\s+                                               /* skip whitespace */
(\Λ|\∧|\&)(?=((\s)*[^\s]))                           return 'AND'
(V|v|\∨|\|)(?=((\s)*[^\s\|\<]))                      return 'OR'



(\→|\-\>)                                            return 'THEN'
(\↔|(\<\-\>))                                        return 'EQUIVALENT'
((\s)*(\|)*)*(\<\<)                                  return 'SUPPOSED_END'

\¬\¬(?=((\s)*\(\d))                                  return 'DOUBLE_NOT'
\¬(?!(\¬(\s)*\(\d))                                  return 'NOT'
I(?=((\s)*([\→\↔Λ∧&Vv\∨\¬]|(\<\-\>)|(\-\>))(\s)*\((\s)*[0-9]))  return 'I'
E(?=((\s)*([\→\↔Λ∧&Vv\∨\¬]|(\<\-\>)|(\-\>))(\s)*\((\s)*[0-9]))  return 'E'
R(?=((\s)*\((\s)*[0-9]))                                        return 'R'

'EFSQ'(?=((\s)*\((\s)*[0-9]))                        return 'EFSQ'

'premisa'                                            return 'PREMISA'
'supuesto'                                           return 'SUPUESTO'
'⊥'                                                  return 'CONTRADICTION'
'∀'                                                  return 'FORALL'
'∃'                                                  return 'Exist'
'('                                                  return '('
')'                                                  return ')'
','                                                  return ','
(\.|\:)(\s)*(\|)*                                    return 'SEPARATOR'

((\|)+(\s)*)+                                        return 'END'
'-'                                                  return '-'

[0-9]+                                               return 'NUMERIC'
[a-uw-z]([0-9]*)                                     return 'ELEMENT'
[A-UW-Z]([0-9]*)                                     return 'APPLICATION'
<<EOF>>                                              return 'EOF'
%                                                    return 'INVALID'

/lex

%left EXIST FORALL EQUIVALENT THEN AND OR
%left UNEGATION


%start start

/* declarations */

%{

    function merge(a, b) {
        if (!Array.isArray(a)) {
            a = [a];
        }
        a.push(b);
        return a;
    }

    function mkArray(a) {
        if (!Array.isArray(a)) {
            a = [a];
        }
        return a;
    }

    function line(index, expression) {
        expression.index = parseInt(index);
        return expression;
    }

    function assertion(expression, rule) {
        return {
          type:      'ASSERTION',
          expression: expression,
          rule:       rule
        };
    }

    function premise(expression) {
        return {
          type:      'PREMISE',
          expression: expression
        };
    }

    function supposed(expression) {
        return {
          type:      'SUPPOSED',
          expression: expression
        };
    }

    function binary(itype, content, left, right) {
        return {
          type:     'BINARY',
          left:      left,
          right:     right,
          connector: {
            type: itype,
            content: content
          }
        };
    }

    function close_exp(expression) {
        return {
          type:      'CLOSE_EXP',
          expression: expression
        };
    }

    function nagation(content, expression) {
        return {
          type:      'NEGATION',
          content:    content,
          expression: expression
        };
    }

    function exist(element, expression) {
        return {
          type:      'EXIST',
          element:    element,
          expression: expression
        };
    }

    function forall(element, expression) {
        return {
          type:      'FORALL',
          element:    element,
          expression: expression
        };
    }

    function contradiction(text) {
        return {
          type:   'CONTRADICTION',
          content: text
        };
    }

    function element(text) {
        return {
          type:      'ELEMENT',
          identifier: text
        };
    }

    function application(text, elements) {
        return {
          type:      'APPLICATION',
          identifier: text,
          elements:   elements
        };
    }

    function ref_array(references) {
        parsed = []
        var index;
        for(index = 0; index < references.length; index++){
          parsed.push(parseInt(references[index]));
        }

        return {
          type:    'ARRAY',
          indices: parsed
        };
    }
    function ref_range(first, last) {
        return {
          type:  'RANGE',
          first: parseInt(first),
          last:  parseInt(last)
        };
    }
    function double_not(references) {
        return {
          action:    'DOUBLE_NOT',
          references: references
        };
    }
    function efsq(references) {
        return {
          action:    'EFSQ',
          references: references
        };
    }
    function repeat(references) {
        return {
          action:    'REPEAT',
          references: references
        };
    }
    function action_rule(action, connector, references) {
        return {
          action:     action,
          connector:  connector,
          references: references
        };
    }

%}

%% /* language grammar */

start          : NUMERIC SEPARATOR line END EOF
                 {return line($1, $3);}
               | NUMERIC SEPARATOR line EOF
                 {return line($1, $3);}
               | SUPPOSED_END END EOF
                 {return {type:'SUPPOSED_END'};}
               | SUPPOSED_END EOF
                 {return {type:'SUPPOSED_END'};}
               ;

multi_or       : multi_or OR | multi_or ;

line           : expression rule
                 {$$ = assertion($1, $2);}
               | expression PREMISA
                 {$$ = premise($1);}
               | expression SUPUESTO
                 {$$ = supposed($1);}
               ;

rule           : rule_action connector close_ref
                 {$$ = action_rule($1, $2, $3);}
               | rule_action NOT close_ref
                 {$$ = action_rule($1, {type: "NEGATION", content: $2}, $3);}
               | DOUBLE_NOT close_ref
                 {$$ = double_not($2);}
               | EFSQ close_ref
                 {$$ = efsq($2);}
               | 'R' close_ref
                 {$$ = repeat($2);}
               ;

connector      : AND
                 {$$ = {type: "CONJUNCTION", content: $1};}
               | OR
                 {$$ = {type: "DISJUNCTION", content: $1};}
               | THEN
                 {$$ = {type: "CONDITIONAL", content: $1};}
               | EQUIVALENT
                 {$$ = {type: "BICONDITIONAL", content: $1};}
               ;

close_ref      : '(' references ')'
                 {$$ = $2;}
               ;

references     : ref_array
                 {$$ = ref_array($1);}
               | ref_range
                 {$$ = $1;}
               ;

ref_array      : ref_array ',' NUMERIC
                 {$$ = merge($1, $3);}
               | NUMERIC
                 {$$ = mkArray($1);}
               ;

ref_range      : NUMERIC '-' NUMERIC
                 {$$ = ref_range($1, $3);}
               ;

rule_action    : 'I'
                 {$$ = $1;}
               | 'E'
                 {$$ = $1;}
               ;

elements       : ELEMENT
                 {$$ = mkArray(element($1));}
               | elements ELEMENT
                 {$$ = merge($1, element($2));}
               ;

expression     : ELEMENT
                 {$$ = element($1);}
               | CONTRADICTION
                 {$$ = contradiction($1);}
               | APPLICATION elements
                 {$$ = application($1, $2);}
               | FORALL ELEMENT expression
                 {$$ = forall(element($2), $3);}
               | EXIST ELEMENT expression
                 {$$ = exist(element($2), $3);}
               | expression EQUIVALENT expression
                 {$$ = binary("BICONDITIONAL", $2, $1, $3);}
               | expression THEN expression
                 {$$ = binary("CONDITIONAL", $2, $1, $3);}
               | expression AND expression
                 {$$ = binary("CONJUNCTION", $2, $1, $3);}
               | expression OR expression
                 {$$ = binary("DISJUNCTION", $2, $1, $3);}
               | NOT expression %prec UNEGATION
                 {$$ = nagation($1, $2);}
               | '(' expression ')'
                 {$$ = close_exp($2);}
               ;












%%
