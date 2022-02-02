class Metamodel::BasicClassHOW is Metamodel::ClassHOW {
    has %!basic;
    #method add_binex(Mu \type, $name, $code_obj) {
    method add_basic(Mu \type, $name, $code-obj) {
        %!basic{$name} = $code-obj;
    }

    method compose( Mu \obj ){
        self.add_method: obj, .key, .value
            for %!basic;
        callsame();
    }
}

my package EXPORTHOW {
    package DECLARE {
        constant class-basic = Metamodel::BasicClassHOW;
    }
}
