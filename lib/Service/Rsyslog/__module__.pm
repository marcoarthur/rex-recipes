package Service::Rsyslog;
use strictures 2;
use Devel::Constants;
use Carp qw(carp croak);
use Rex -base;
use DDP;

user 'root';
group development => @Devel::Constants::DEV;

# helper to define local net for eth0
sub local_net {
   my %server_info = get_system_information;
   my @ip = split /\./, $server_info{eth0_ip};
   my @mask = split /\./, $server_info{eth0_netmask};
   my @net;
   my $bits = 64;

   for my $i (0..3) {
      # why not & (bitwise) don't work here ?
      my $b = $mask[$i] && $ip[$i];
      $bits = $bits/2 if $b == 0;
      push @net, $b;
   }

   my $label = join ".", @net;
   $label .= "/$bits";
   return $label;
}

# install package
task install => sub {
   my @req = qw(rsyslog);
   pkg $_, ensure => 'latest' for @req;
};

desc "configure rsyslog server";
task configure_server => sub {
   needs Service::Rsyslog "install";
   my $opts = shift;
   my %vars = (
      allowed_net => ['127.0.0.1', local_net],
   );

   push @{ $vars{allowed_net} }, $opts->{allowed} if $opts->{allowed};

   file "/etc/rsyslog.conf",
   content        => template( "files/rsyslog.conf.tt2", vars => \%vars ),
   owner          => "root",
   group          => "root",
   mode           => 640,
   on_change      => sub { service rsyslog => "restart" },
   ;
};

desc "configure rsyslog client";
task configure_client => sub {
   my $opts = shift;
   my %vars;

   # set server
   croak "--server is mandatory to configure rsyslog as client" unless $opts->{server};
   $vars{server} = $opts->{server};

   # basic health check if client reach server
   my $cmd = sprintf "ping -c 1 %s", $vars{server};
   run ($cmd);
   
   # set protocol
   my $proto = $opts->{proto} || 'tcp'; # tcp by default
   croak "--proto is udp or tcp only" unless lc($proto) ne 'tcp' || lc($proto) ne 'udp';
   $vars{proto} = $proto eq 'tcp' ? '@@' : '@'; # protocol as rsyslog codifies
   my $contents = template( "files/rsyslog-client.conf.tt2", vars => \%vars );

   # write config file for client
   file "/etc/rsyslog.conf",
   content     => $contents,
   owner       => "root",
   group       => "root",
   mode        => 640,
   on_change   => sub { service rsyslog => "restart" },
   ;

};


1;

__END__

=pod

=head1 NAME

Service::Rsyslog - setup a rsyslog service (daemon).

=head1 DESCRIPTION

We just install latest rsyslog daemon and configure it properly.

=head1 USAGE

 include qw/Service::Rsyslog/;

 task your_task => sub {
    Service::Rsyslog::install();
    Service::Rsyslog::configure_server($opt);
    Service::Rsyslog::configure_client($opt);
 };

=head1 TASKS

=over 4

=item install()

Install latest rsyslogd.

=item configure_server($opt)

Configure rsyslog daemon. Options, hashref $opt, include:

=over

--allowed: e.g, 192.168.1.0/32 will allow rsyslog to receive senders from this net.

=back

=item configure_client($opt)

Configure rsyslog daemon to be client. Options:

=over

--server: server name or ip address of server.

--proto: [tcp | udp] protocol to use for connection.

=back

=back

=cut
