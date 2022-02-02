# BasicTest

This is a test module to demonstrate how a foreign programming language 
can be integrated into Raku.  It is oriented primarily at developers of 
DSLs that can be usefully added to Raku's language braid, though nothing
is stopping anyone from using it to integrate a general purpose language.

It will be continually updated over time to provide interested developers
a sort of "best practices" guide.  Code is commented heavily in some places
to aid applicabilty to other projects.

Note that it requires RakuAST to be available: ensure your build of Rakudo
is from the `rakuast` branch.

## Current State

Currently, by mimicking this module, the following is possible:

   * Creating a new declarator with special meta methods  
   This may be useful for projects creating specialized container classes akin to `Grammar`
   * Creating a new method declarator that uses a custom language  
   In other words, between the braces, a totally different language
   
## Limitations

At the present moment, note the following limitations
 
   * It's not possible to create lexically-scoped methods
   * It's not possible to create subs using the sublanguage
   * Signatures are done via custom processing, and not via Raku's built in token (and presently, they aren't associated with lexical variables, though that will be fixed soon)
   * Multis are not yet supported (though it should be easy to support)
   * Traits are not yet supported
   
Some of these limitations may be easier to lift once RakuAST is more mature, 
others just require me to dedicate a bit more time to the module.


## History
  * **v0.1.0** Initial version
    * Basic method support
    * Basic declarator support
    
## Copyright and license
© 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0.

Feel free to steal any and all techniques you find here, but please submit a PR if you
are able to find an elegant way to work around any of the limitations, or if you
are able to accomplish any feature implemented in a hacky manner through an official means.