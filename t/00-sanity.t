use BasicMeta;
use Basic;
use Test;

class-basic Foo {

    multi method-basic mm {
        10 RETURN 0
    }
    multi method-basic mm(A) {
        10 LET B = A + 1
        20 RETURN B
    }
    multi method-basic mm(A, B) {
        10 LET C = A + B
        20 RETURN C
    }

     method-basic foo {
        10 LET A = 0
        20 LET A = A + 1
        30 IF A > 5 THEN 60
        50 GOTO 20
        60 LET A = 99
        70 RETURN A
    }

    method-basic square (X) {
        10 LET Y = 0
        20 LET Z = X
        30 LET Y = X + Y
        40 LET Z = Z - 1
        50 IF Z > 0 THEN 30
        60 RETURN Y
    }

    method-basic countdown (X) {
        10 PRINT X
        20 LET X = X - 1
        50 IF X > 0 THEN 10
        60 RETURN 1
    };

}

is Foo.foo, 99;
is Foo.square(5), 25;
is Foo.mm, 0;
is Foo.mm(1), 2;
is Foo.mm(1000), 1001;
is Foo.mm(5,4), 9;
is Foo.mm(100,-50), 50;

done-testing;