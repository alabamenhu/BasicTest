unit role BASIC::Actions::Mixin;

# I'm not consistent about using this helper function
# but during this process, we don't have access to $/ via $<foo>
sub lk(Mu \h, \k) { h.hash.AT-KEY: k }

method BASIC_number  (Mu $/) { make RakuAST::IntLiteral($/.Str.Int)   }
method BASIC_var     (Mu $/) { make RakuAST::Var::Lexical.new($/.Str) }
method BASIC_parens  (Mu $/) { make lk($/,'BASIC_expr').made          }
method BASIC_op      (Mu $/) { make RakuAST::Infix.new($/.Str)        }
method BASIC_comp-op (Mu $/) { make RakuAST::Infix.new($/.Str)        }
method BASIC_thing   (Mu $/) {
    make .made with $/.hash<BASIC_number>;
    make .made with $/.hash<BASIC_var>;
    make .made with $/.hash<BASIC_expr>;
}

method BASIC_expr (Mu $/) {
    my $ast = lk($/,'BASIC_thing').made;
    for ^(lk($/,'BASIC_op')) -> $i {
        $ast = RakuAST::ApplyInfix.new(
            infix => lk($/,'BASIC_op').[$i].made,
            left  => $ast,
            right => lk($/,'BASIC_expr').[$i].made
        )
    }
    make $ast
}

method BASIC_cmd:print (Mu $/) {
    # say <thing>; $BASIC-INDEX++
    make RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(
            expression => RakuAST::Call::Name.new(
                name => RakuAST::Name.from-identifier('say'),
                args => RakuAST::ArgList.new( lk($/,'BASIC_thing').made )
            )
        ),
        RakuAST::Statement::Expression.new(
            expression => RakuAST::ApplyPostfix.new(
                operand => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                postfix => RakuAST::Postfix.new('++')
            )
        )
    )
}

method BASIC_cmd:assign (Mu $/) {
    # <var> = <expr>; $BASIC-INDEX++
    make RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(
            expression => RakuAST::ApplyInfix.new(
                left  => lk($/,'BASIC_var').made,
                right => lk($/,'BASIC_expr').made,
                infix => RakuAST::Infix.new('=')
            )
        ),
        RakuAST::Statement::Expression.new(
            expression => RakuAST::ApplyPostfix.new(
                operand => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                postfix => RakuAST::Postfix.new('++')
            )
        )
    );
}
method BASIC_cmd:goto (Mu $/) {
    # $BASIC-INDEX = %BASIC-INDEX{<line>};
    make RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(
            expression => RakuAST::ApplyInfix.new(
                left  => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::Var::Lexical.new('%BASIC-INDEX'),
                    postfix => RakuAST::Postcircumfix::HashIndex.new(
                        RakuAST::SemiList.new(
                            RakuAST::Statement::Expression.new(
                                # the Str -> Int -> Str canonicalizes the string for us
                                expression => RakuAST::StrLiteral.new($/.hash<line>.Str.Int.Str)
                            )
                        )
                    )
                ),
                infix => RakuAST::Infix.new('=')
            )
        )
    );
}

method BASIC_cmd:ifthen (Mu $/) {
    # if <left> cmp <right> { $BASIC-INDEX = %BASIC-INDEX{<line>} else { $BASIC-INDEX++ }
    make RakuAST::StatementList.new(
        RakuAST::Statement::If.new(
            condition => RakuAST::ApplyInfix.new(
                left => $/.hash<left>.made,
                right => $/.hash<right>.made,
                infix => $/.hash<BASIC_comp-op>.made
            ),
            then => RakuAST::Block.new(
                body => RakuAST::Blockoid.new(
                    RakuAST::StatementList.new(
                        RakuAST::Statement::Expression.new(
                            expression => RakuAST::ApplyInfix.new(
                                infix => RakuAST::Infix.new('='),
                                left  => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                                right => RakuAST::ApplyPostfix.new(
                                    operand => RakuAST::Var::Lexical.new('%BASIC-INDEX'),
                                    postfix => RakuAST::Postcircumfix::HashIndex.new(
                                        RakuAST::SemiList.new(
                                            RakuAST::Statement::Expression.new(
                                                # the Str -> Int -> Str canonicalizes the string for us
                                                expression => RakuAST::StrLiteral.new($/.hash<line>.Str.Int.Str)
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            ),
            else => RakuAST::Block.new(
                body => RakuAST::Blockoid.new(
                    RakuAST::StatementList.new(
                        RakuAST::Statement::Expression.new(
                            expression => RakuAST::ApplyPostfix.new(
                                operand => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                                postfix => RakuAST::Postfix.new('++')
                            )
                        )
                    )
                )
            )
        )
    );
}

method BASIC_cmd:return (Mu $/) {
    # return <thing>
    make RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(
            expression => RakuAST::Call::Name.new(
                name => RakuAST::Name.from-identifier('return'),
                args => RakuAST::ArgList.new(
                        lk($/,'BASIC_thing').made
                )
            )
        )
    )
}
method BASIC_line (Mu $/) {
    if lk($/,'BASIC_line-no') {
        # -> { <cmd> }
        make %(
            line-no => lk($/,'BASIC_line-no').made,
            code => RakuAST::PointyBlock.new(
                body => RakuAST::Blockoid.new(
                    lk($/,'BASIC_cmd').made
                )
            )
        )
    } else {
        make %(
            line-no => -1, #aka "blank line"
            code => { ; }
        )
    }
}
method BASIC_line-no (Mu $/) { make $/.Str.Int }
method BASIC (Mu $/) {
    my @statements;
    # declare variables that we found.  We these as terms in case they
    # lack a sigil (as is normal for BASIC).  Sneaky.
    # my <var> = my $;                                  (if not in signature)
    # my <var> = my $ = @BASIC-ARGUMENTS[<var-offset>]; (if in signature)
    @statements.push(RakuAST::Statement::Expression.new(
        expression =>RakuAST::VarDeclaration::Term.new(
            scope => 'my',
            name  => RakuAST::Name.from-identifier($_),
            initializer => RakuAST::Initializer::Assign.new(
                $_ !(elem) @*BASIC-SIGNATURE
                    ?? RakuAST::VarDeclaration::Anonymous.new(:sigil('$'), :scope('my'))
                    !! RakuAST::VarDeclaration::Anonymous.new(:sigil('$'), :scope('my'),
                           initializer => RakuAST::Initializer::Assign.new(
                                RakuAST::ApplyPostfix.new(
                                    operand => RakuAST::Var::Lexical.new('@BASIC-ARGUMENTS'),
                                    postfix => RakuAST::Postcircumfix::ArrayIndex.new(
                                        RakuAST::SemiList.new(
                                            RakuAST::IntLiteral.new(@*BASIC-SIGNATURE.first($_, :k))
                                        )
                                    )
                                )
                           )
                    )
            )
        )
    )) for %*BASIC-VARS.keys;

    # Generate the data for the two main variables we'll be using
    # First, a list of each code object
    # Second, an alternating list (for easy hash assignment) of line numbers to code indexes
    my $i = 0;
    my @basic-code-lines;
    my @basic-code-indices;
    for $/.hash.AT-KEY('BASIC_line') {
        if .made<line-no> >= 0 {
            @basic-code-lines.push: .made<code>;
            @basic-code-indices.push: RakuAST::StrLiteral(.made<line-no>.Str);
            @basic-code-indices.push: RakuAST::IntLiteral($i);
            $i++;
        }
    }

    # Declare the 'VM' variables in RAST
    @statements.push(
        # my %BASIC-INDEX = |@basic-code-indices
        RakuAST::Statement::Expression.new(
            expression => RakuAST::VarDeclaration::Simple.new(
                scope => 'my',
                name => '%BASIC-INDEX',
                initializer => RakuAST::Initializer::Assign.new(
                    RakuAST::ApplyListInfix.new(
                        infix => RakuAST::Infix.new(','),
                        operands => @basic-code-indices.list
                    )
                )
            )
        ),
        # my $BASIC-INDEX = 0
        RakuAST::Statement::Expression.new(
            expression => RakuAST::VarDeclaration::Simple.new(
                scope => 'my',
                name => '$BASIC-INDEX',
                initializer => RakuAST::Initializer::Assign.new(
                    RakuAST::IntLiteral(0)
                )
            )
        ),
        # my @BASIC-LINES = |@basic-code-lines
        RakuAST::Statement::Expression.new(
            expression => RakuAST::VarDeclaration::Simple.new(
                scope => 'my',
                name => '@BASIC-LINES',
                initializer => RakuAST::Initializer::Bind.new(
                    RakuAST::ApplyListInfix.new(
                        infix => RakuAST::Infix.new(','),
                        operands => @basic-code-lines.list
                    )
                )
            )
        ),
    );

    # Now with everything defined, we will begin the process of looping through the machines
    # while $BASIC-INDEX < X {
    #     @BASIC-LINES[$BASIC-INDEX].()
    # }
    # Each element of @basic-lines is a sub which will modify $BASIC-INDEX by incrementing
    # or in the case of IF / GOTO statements, by calling %BASIC-INDEX{code-line-ref}
    @statements.push: RakuAST::Statement::Loop::While.new(
        condition => RakuAST::Statement::Expression.new(
            expression => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$BASIC-INDEX'),
                right => RakuAST::IntLiteral.new(@basic-code-lines.elems),
                infix => RakuAST::Infix.new('<')
            )
        ),
        body => RakuAST::Block.new(
            body => RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    # @BASIC-LINES[$BASIC-INDEX].()
                    RakuAST::ApplyPostfix.new(
                        operand => RakuAST::ApplyPostfix.new(
                            operand => RakuAST::Var::Lexical.new('@BASIC-LINES'),
                            postfix => RakuAST::Postcircumfix::ArrayIndex.new(
                                RakuAST::SemiList.new(
                                    RakuAST::Var::Lexical.new('$BASIC-INDEX')
                                )
                            )
                        ),
                        postfix => RakuAST::Call::Term.new()
                    ),
                )
            )
        )
    );
    # Wrap it in a blockoid (though this should maybe be moved to the declarator side of things)
    make RakuAST::Blockoid.new(
            RakuAST::StatementList.new: |@statements
    )
}

method routine_declarator:sym<method-basic> (Mu $/) {
    use MONKEY-SEE-NO-EVAL;

    # Note: You can use .^add_method directly here.
    # I used ^add_basic since I'll eventually be doing some weird stuff,
    # but you'll also want to be ready to parse for multis, etc, which
    # this does not currently support (but soon hopefully!)
    $*PACKAGE.^add_basic:
        lk($/, 'name').Str,
        # method <name> (*@BASIC-ARGUMENTS) { <basic> }
        EVAL RakuAST::Method.new(
            name => RakuAST::Name.from-identifier(lk($/, 'name').Str),
            signature => RakuAST::Signature.new(
                parameters => (
                    RakuAST::Parameter.new(
                        target => RakuAST::ParameterTarget::Var.new('@BASIC-ARGUMENTS'),
                        slurpy => RakuAST::Parameter::Slurpy::Flattened
                    ),
                )
            ),
            body => lk($/, 'BASIC').made
        )
}