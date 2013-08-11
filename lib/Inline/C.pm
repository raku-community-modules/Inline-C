
role Inline::C[Routine $r, Str $language, Str $code];

use NativeCall :internals;

my class native_callsite is repr('NativeCall') { }

has int $!setup;
has $!code = "#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif
$code";
has $!libname;
has native_callsite $!call is box_target;

method postcircumfix:<( )>($args) {
    unless $!setup {
        $!setup      = 1;
        my $basename = IO::Spec.catfile( $*TMPDIR, 'inline' );
        $!libname    = $basename ~ "_" ~ $r.name;
        $!libname    = $basename ~ 1000.rand while $!libname.IO.e;
        my $o        = $*VM<config><o>;
        my $so       = $*VM<config><load_ext>;
        if my $CC = open( "$*VM<config><cc> -c $*VM<config><cc_shared> $*VM<config><cc_o_out>$!libname$o $*VM<config><ccflags> -xc -", :w, :p ) or warn $! {
            $CC.print( $!code );
            $CC.close;
            my $l_line = "$*VM<config><ld> $*VM<config><ld_load_flags> $*VM<config><ldflags> " ~
                         "$*VM<config><libs> $*VM<config><ld_out>$!libname$so $!libname$o";
            shell($l_line);
        }
    }
    my Mu $arg_info := param_list_for($r.signature);
    my str $conv = self.?native_call_convention || '';
    my $realname = 
        !$!libname.DEFINITE   ?? "" !!
        $!libname ~~ /\.\w+$/ ?? $!libname !!
                                "$!libname$*VM<config><load_ext>";
    nqp::buildnativecall(self,
        nqp::unbox_s($realname),    # library name
        nqp::unbox_s($r.name),      # symbol to call
        nqp::unbox_s($conv),        # calling convention
        $arg_info,
        return_hash_for($r.signature));
    nqp::nativecall(nqp::decont(map_return_type($r.returns)), self,
        nqp::getattr(nqp::decont($args), Capture, '$!list'))
}
