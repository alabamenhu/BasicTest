use BasicMeta;
use Basic;
use Test;

class-basic Foo {
    method-basic foo {
        10 LET A = 0
        20 LET A = A + 1
        30 IF A > 5 THEN 60
        50 GOTO 20
        60 LET A = 99
        70 RETURN A
    }
}

is Foo.foo, 99;

done-testing;