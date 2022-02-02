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
    };

    method-basic square (X) {
        10 LET Y = 0
        20 LET Z = X
        30 LET Y = X + Y
        40 LET Z = Z - 1
        50 IF Z > 0 THEN 30
        60 RETURN Y
    };

    method-basic countdown (X) {
        10 PRINT X
        20 LET X = X - 1
        50 IF X > 0 THEN 10
        60 RETURN 1
    };

}

is Foo.foo, 99;
is Foo.square(5), 25;

done-testing;