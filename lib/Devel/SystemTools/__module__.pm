package Devel::SystemTools;
use strictures 2;

use Rex -base;
use Data::Dumper;
use Devel::Constants;

user 'root';
group development => @Devel::Constants::DEV;

desc "install development debian packages";
task install_devel_pkgs => sub {
    my @pkgs = qw(todotxt-cli coreutils moreutils bsdutils bsdextrautils git rsync ripgrep);
    update_system;
    pkg $_, ensure => 'present' for @pkgs;
};

desc "configure devel environment";
task configure_devel => sub {
    # configure git
    upload  "files/git/gitconfig", 
    "~/.gitconfig";

    # TODO:configure shell
};

desc "cron jobs entries";
task cron_update => sub {
    my @crons = cron list => "root";
    print Dumper(\@crons);
};

desc "system logs diagnostics";
task logs => sub {
    my $args = shift;
    my $help =<<~EOH;
    "%s" options:
    --log=[sockets | units | actives | last_hour | failed]. Default last_hour
    EOH

    if ($args->{help}) {
        say sprintf $help, 'task log';
        return;
    }

    my %logs;
    my $opt = "--no-pager";
    $logs{sockets}      = [run "systemctl $opt list-sockets"];
    $logs{units}        = [run "systemctl $opt list-unit-files"];
    $logs{actives}      = [run "systemctl $opt list-units"];
    $logs{last_hour}    = [run "journalctl -r $opt --since '1 hour ago'"];
    $logs{failed}       = [run "systemctl $opt --failed"];

    my $log = $logs{$args->{log} || 'last_hour'};
    local $" = "\n";
    say "@$log";
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
