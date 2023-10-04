part of 'dtext_grammar.dart';

Parser url() =>
    char('<').optional() &
    (string('http://') | string('https://')) &
    pattern('a-zA-Z0-9./-_,?=&;%:+').plus().flatten() &
    char('>').optional();
