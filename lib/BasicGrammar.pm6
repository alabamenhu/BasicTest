unit role BASIC::Grammar::Mixin;

# helper function, because $/ can't be accessed with $<foo> here
sub lk(Mu \match, \token) {
    match.hash.AT-KEY(token)
}

token routine_declarator:sym<method-basic> {
    :my $*LINE_NO := {
        use QAST:from<NQP>; # allows access to HLL::Compiler, not strictly necessary though
        HLL::Compiler.lineof(self.orig(), self.from(), :cache(1))
    };
    :my @*BASIC-SIGNATURE;
    # What we want to parse is this format: method-basic foo (A, B) { <code> }
    <sym> <.end_keyword> <.ws>            # method-basic
    $<name> = <[a..zA..Z]>+               #              foo
    <.ws>                                 #
    ['('                                  #                  (
        [ <.ws>                           #
          $<var>=<[a..zA..Z]>+            #                   A  B
         {@*BASIC-SIGNATURE.push:         #
              $/.hash<var>.tail.Str }     #
          <.ws>                           #
        ]* %% ','                         #                    ,
    ')']?                                 #                       )
    <.ws>                                 #
    '{'                                   #                         {
    <BASIC>                               #                           <code>
    '}'                                   #                                  }
    <?ENDSTMT>
    # As noted elsewhere, a fully correct parse would actually use <nibble>
    # with the quote_lang set to BASIC but at the moment I can't figure out
    # how to do that, but this seems to work just fine.
    #
    # Notice that the signature is parsed extremely basically, rather than
    # using Raku's built in signature.  You may wish to use a custom signature
    # in order to more closely mirror signatures from your language.
    #
    # The <?ENDSTMT> allows the final } to end a line
}

token BASIC {
    # some of these maybe should be moved to the declarator section
    :my $*BASIC-LINE-NO = 0;
    :my %*BASIC-VARS;
    [
        <.ws> <BASIC_line>
    ]+ % "\n"
    <.ws> <before '}'>
}

# Some of these terms may have overlapped with built in.  Because we're mixing in
# we want to be careful not to accidentally override any of MAIN's tokens, so
# I prefix all of them.  It makes stuff look uglier, but it's safer until
# we can avoid needing mixins.
token BASIC_number  { <[0..9]>+ }
token BASIC_var     { '$'? $<varname>=[<.ident>+] {%*BASIC-VARS{$/.Str}=True #`[for setup] } }
token BASIC_parens  { \h* '(' \h* <BASIC_expr> \h* ')' \h* }
token BASIC_op      { <[+*/-]> }
token BASIC_comp-op { '==' | '>' | '<' }

token BASIC_thing   { <BASIC_number>  |   <BASIC_var>  |  <BASIC_parens>  }
token BASIC_expr    { <BASIC_thing>  [\h* <BASIC_op>  \h* <BASIC_expr>]*  }
token BASIC_line    { <BASIC_line-no> \h+ <BASIC_cmd>  |  <before "\n">   }

proto token BASIC_cmd { * }
token BASIC_cmd:print  {  'PRINT'  \h+ <BASIC_thing> }
token BASIC_cmd:goto   {  'GOTO'   \h+ $<line>=<[0..9]>+ }
token BASIC_cmd:return {  'RETURN' \h+ <BASIC_thing> }
token BASIC_cmd:assign { ['LET'    \h+]? <BASIC_var> \h* '=' \h* <BASIC_expr> }
token BASIC_cmd:ifthen {  'IF'     \h+ <left=BASIC_expr> \h* <BASIC_comp-op> \h* <right=BASIC_expr> \h+ 'THEN' \h+ $<line>=<[0..9]>+ }
token BASIC_line-no {
    $<line-no>=<[0..9]>+
    {
        die "Non-sequential line number {lk($/,'line-no').Int} in BASIC code found. \n"
          ~ "Expected a value greater than $*BASIC-LINE-NO."
            if lk($/,'line-no').Int < $*BASIC-LINE-NO;
        $*BASIC-LINE-NO = lk($/,'line-no').Int
    }
}


