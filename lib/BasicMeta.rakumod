class Metamodel::BasicClassHOW is Metamodel::ClassHOW {
    has       %!basic;
    has Array %!multi-basic;

    # If you just want basic support, this can be done in the actions method
    # The meta approach is only needed if you want to do some kind of specialized
    # processing/handling between now and composition.
    multi method add_basic(Mu \type, $name, $code-obj) {
        %!basic{$name} = $code-obj;
    }
    multi method add_multi_basic(Mu \type, $name, $code-obj) {
        %!multi-basic{$name}.push: $code-obj;
    }


    method compose( Mu \obj ){

        # Add simple methods
        self.add_method: obj, .key, .value
            for %!basic;

        # Add the multi methods
        for %!multi-basic.kv -> \name, @multis {
            self.add_multi_method: obj, name, $_
                for @multis;
        }

        # Finish composition through main metaclass
        callsame();
    }
}

my package EXPORTHOW {
    package DECLARE {
        constant class-basic = Metamodel::BasicClassHOW;
    }
}
