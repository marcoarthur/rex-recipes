package Devel::Constants;
use Mojo::Base -strict;
use Mojo::File;
use Carp qw(carp croak);
use Syntax::Keyword::Try;

use constant {
    ssh_conf_file => "$ENV{HOME}/.ssh/config",
};

our $SERVERS = __PACKAGE__->servers; # all servers
our @DEV = grep { /\.dev$/ } @$SERVERS; # devel servers

sub servers {
    my @hosts = qw(localhost);

    try {
        my $file  = Mojo::File->new(ssh_conf_file);
        @hosts = map {my $h = [split /\s+/]; $h->[1]}
        grep {/^Host/ } split/\n/, $file->slurp;
    } catch ($e) {
        my $msg = sprintf "Error reading %s : %s", ssh_conf_file, $e;
        carp $msg;
    }

    return [@hosts];
}

1;
