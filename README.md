# BasicTest

This is a test module to demonstrate how a foreign programming language 
can be integrated into Raku.  It is oriented primarily at developers of 
DSLs that can be usefully added to Raku's language braid, though nothing
is stopping anyone from using it to integrate a general purpose language.

It will be continually updated over time to provide interested developers
a sort of "best practices" guide.  Code is commented heavily in some places
to aid applicability to other projects.

Note that it requires RakuAST to be available: ensure your build of Rakudo
is from the `rakuast` branch.  At the present, make sure that you do **not**
set `RAKUDO_RAKUAST=1` in your `ENV`.

## Current State

Currently, by mimicking this module, the following is possible:

   * Creating a new declarator with special meta methods  
   This may be useful for projects creating specialized container classes akin to `Grammar`
   * Creating a new method declarator that uses a custom language  
   In other words, between the braces, a totally different language
   * Use multi methods for said declarator
   
## Limitations

At the present moment, note the following limitations
 
   * Lexically-scoped methods aren't possible in the sublanguage yet
   * Subs can't be created using the sublanguage
   * Traits are not yet supported
   * Signatures are done via custom processing, and not via Raku's built in token.  
   This isn't necessarily a bad thing: you may want to do signatures to mirror your sublang in some way.
   
Some of these limitations may be easier to lift once RakuAST is more mature, 
others just require me to dedicate a bit more time to the module.


## History
  * **v0.1.2** Multi support
    * Multi based on arity alone (it's basic, after all)
    * Improved code documentation
  * **v0.1.1** Signature support
    * Signatures now handle passed variables
  * **v0.1.0** Initial version
    * Basic method support
    * Basic declarator support
    
## Copyright and license
© 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0.

Feel free to steal any and all techniques you find here, but please submit a PR if you
are able to find an elegant way to work around any of the limitations, or if you
are able to accomplish any feature implemented in a hacky manner through an official means.