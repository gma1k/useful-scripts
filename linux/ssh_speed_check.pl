# usage: ./ssh-speed.pl <pid-of-ssh>

my $pid = shift@ARGV;
my $tunnel_fd;

# list the fds of the process on TCP sockets
open my $lsof, '-|', qw (lsof -wnPa -i tcp -Fd -p), $pid;
while (<$lsof>) {
  if (/^f (\\d+)/) {
    # the first fd on a TCP socket is assumed to be that of the ssh connection
    $tunnel_fd = $1;
    last;
  }
}
close $lsof;
die \"can't identify tunnel fd\\n\" unless defined $tunnel_fd;

my %dir;
sub pv {
  open my $fh, '|-', \"sh\", \"-c\", q (exec pv \"-ctrabN$0\" 2>&1 > /dev/null), $_ [0];
  $fh->autoflush (1);
  return $fh;
}

open my $strace, '-|', qw (strace -q -s0 -e trace=read,write -e status=successful -a0 -o/dev/stdout -p), $pid;

$dir {\"1read\"} = pv \"outer IN\";
$dir {\"write\"} = pv \"inner IN\";
$dir {\"read\"} = pv \"inner OUT\";
$dir {\"1write\"} = pv \"outer OUT\";

while (<$strace>) {
  if (/^ (read|write)\\ ( (\\d+).*= (\\d+)/) {
    print { $dir { ($2 eq $tunnel_fd) . $1} } \".\" x $4;
  }
}
