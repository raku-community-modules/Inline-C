p6-Inline-C
===========

# these days on irc.freenode.net/#perl6
23:29:59 - jnthn: FROGGS: Note that you can programatically apply the is native trait also by calling trait_mod:<is>(...) directly
23:31:11 - jnthn: So I'd guess the inline trait can just wrap the sub. On the first call it does callsame, and the sub returns the C code (so it just contains a quote).
                  It goes off and compiles this into some temporary library, then applies the native trait to the sub, which again wraps it with the native calling stuff.

# this is how it should look (and work) like in the end:

#!/usr/bin/perl6

use soft; # for now
use Inline;

my sub a_plus_b( Int $a, Int $b ) is inline('C') returns Int {'
	DLLEXPORT int a_plus_b (int a, int b) {
		return a + b;
	}
'}