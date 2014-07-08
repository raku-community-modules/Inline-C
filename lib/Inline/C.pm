
role Inline::C[Routine $r, Str $language, Str $code];

use NativeCall;

has int $!setup;
has $!code = "#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif
$code";
has $!libname;
has $!dll;

method postcircumfix:<( )>(Mu \args) {
    unless $!setup {
        $!setup      = 1;
        my $basename = IO::Spec.catfile( $*TMPDIR, 'inline' );
        $!libname    = $basename ~ "_" ~ $r.name;
        $!libname    = $basename ~ 1000.rand.Int while $!libname.IO.e;
        my $cfg      = $*VM.config;
        my $o        = $cfg<obj> // $cfg<o>;
        $!dll        = $cfg<dll> ?? $!libname.path.directory ~ '/' ~ $!libname.path.basename.fmt($cfg<dll>) !! $!libname ~ $cfg<load_ext>;
        my $ccout    = $cfg<ccout> // $cfg<cc_o_out>;
        my $ccshared = $cfg<ccshared> // $cfg<cc_shared>;
        my $cflags   = $cfg<cflags> // $cfg<ccflags>;
        my $ldshared = $cfg<ldshared> // $cfg<ld_load_flags>;
        my $ldlibs   = $cfg<ldlibs> // $cfg<libs>;
        my $ldout    = $cfg<ldout> // $cfg<ld_out>;

        "$!libname.c".IO.spurt: $!code;

        shell "$cfg<cc> -c $ccshared $ccout$!libname$o $cflags -xc $!libname.c";
        shell "$cfg<ld> $ldshared $cfg<ldflags> $ldlibs $ldout$!dll $!libname$o";
    }
    
    &trait_mod:<is>($r, native => $!dll);
    $r(|args);
}
