package Devel::SystemTools;
use strictures 2;

use Rex -base;
use Data::Dumper;

user 'root';
group development => 'perl.dev', 'js.dev';

desc "install development debian packages";
task install_devel_pkgs => sub {
    my @pkgs = qw(todotxt-cli coreutils moreutils bsdutils bsdextrautils git rsync ripgrep);
    update_system;
    pkg $_, ensure => 'present' for @pkgs;
};

desc "configure devel environment";
task configure_devel => sub {
    # configure git
    upload  "./lib/Devel/SystemTools/files/git/gitconfig", 
            "~/.gitconfig";

    # TODO:configure shell
    #
};

desc "cron jobs entries";
task cron_update => sub {
    my @crons = cron list => "root";
    print Dumper(\@crons);
};

1;

__END__

=pod

=head1 NAME

Devel::SystemTools

=head1 DESCRIPTION

Install tools to the debian system that makes system and perl development easier.

=head1 TASKS

=over 4

=item todo

Bash tools like todo.sh, and some other configurations

=item

=back

=cut
