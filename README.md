Inline-C
===========

**ARCHIVED**
This module was experimental and without significant maintenance for 7 years.  It looks like it currently can serve as a source of inspiration for module developers of inlined code of other languages.  But it has served its purpose, and no further development of this module will be attempted.
**ARCHIVED**


USAGE
-----

    use Inline;
    
    my sub a_plus_b( Int $a, Int $b ) is inline('C') returns Int {'
        DLLEXPORT int a_plus_b (int a, int b) {
            return a + b;
        }
    '}
