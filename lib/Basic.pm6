sub EXPORT(|) {
    use BasicGrammar;
    use BasicActions;

    $*LANG.define_slang:
            'MAIN',
            $*LANG.slang_grammar('MAIN').^mixin(BASIC::Grammar::Mixin),
            $*LANG.slang_actions('MAIN').^mixin(BASIC::Actions::Mixin);
    Map.new
}
