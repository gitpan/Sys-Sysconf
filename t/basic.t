use Sys::Sysconf qw(sysconf _SC_VERSION);
$| = 1;
print "1..1\n";
print sysconf(_SC_VERSION),"\n";
print "not " if (sysconf(_SC_VERSION) < 198808);
print "ok 1\n";
