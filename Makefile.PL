use ExtUtils::MakeMaker;
use Config;

# Authors:
#
#	Nick Ing-Simmons	<nik@tiuk.ti.com>
# 	Jarkko Hietaniemi	<jhi@iki.fi>

require 5.002;

my $inc = $Config{'usrinc'};
my $sys;
my $unistd;

foreach $h ("$inc/sys/unistd.h", "$inc/unistd.h")
 {
  $unistd = $h, last if (-r $h);
 }

die "No <unistd.h> on this system" unless (-r $unistd);

open(INC,$unistd) || die "Cannot open $unistd: $!";
while (<INC>)
 {
  $sc{$1} = $2 if (/^\s*#\s*define\s+(_SC\w+)\s+(\w+)/);
 }
close(INC);
print "Writing Sysconf.pm\n";
open(PM,">Sysconf.pm");
print PM <<'END'
package Sys::Sysconf;
use Exporter ();
use POSIX qw(sysconf);
@ISA = qw(Exporter);
END
;
my $str = '@EXPORT_OK = qw(';
my $tab = length($str);
foreach ('sysconf',sort keys %sc)
 {
  if (length($str)+length($_)+1 > 70)
   {
    print PM "$str\n";
    $str = ' ' x $tab;
   }
  $str .= " $_";
 }

print PM <<END;
$str);

# Prototypes.

END

foreach (sort keys %sc)
 {
  printf(PM "%-50s # %5d\n", "sub $_ ();", $sc{$_});
 }

print PM <<'END';

# Definitions.

END
  
foreach (sort { $sc{$a} <=> $sc{$b} } keys %sc)
 {
  printf(PM "%-50s { %5s }\n", "sub $_ ()", $sc{$_});
 }

print PM <<'END';

1;
__END__
END


my $arch = $Config{'archname'};

print PM <<"END"

=head1 NAME

Sys::Sysconf - Access to all $arch sysconf() values.

=head1 SYNOPSIS

   use Sys::Sysconf qw(sysconf _SC_XXXXX);
   my \$val = sysconf(_SC_XXXXX);

=head1 DESCRIPTION

Makefile.PL has scanned E<lt>sys/unistd.hE<gt> for constants of the form

   /#define _SC\\w+ \\d+/

The constants defined for $arch are:

=over 4

END
;

foreach (sort keys %sc)
 {
  print PM "=item $_\n\n";
 }

print PM <<"END"

=back 4

=cut 

END
;
close(PM);

WriteMakefile(
    'NAME'     => 'Sys::Sysconf',
    'clean' => {FILES => "Sysconf.pm"},
    'linkext' => { LINKTYPE => ''},
    'dist'     => { COMPRESS => 'gzip -f9', SUFFIX => '.gz' },
    'VERSION'  => '0.03'
);

package MY;

sub post_initialize
{
 my ($self) = @_;
 foreach (keys %{$self->{'PM'}})
  {
   $self->{PM}->{$_} = $self->catfile('$(INST_ARCHLIBDIR)',$_);
  }
}
