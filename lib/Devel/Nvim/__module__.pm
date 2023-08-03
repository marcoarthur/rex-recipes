##no critic
package Devel::Nvim;
## critic

use strictures 2;
use Carp qw(croak);
use Rex -base;

user 'root';

croak "Need to run it under project's root" unless -d "./lib";

sub setup_nvim {
    my $url = 'https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz';

    download $url,'/tmp/nvim.tar.gz';
    extract '/tmp/nvim.tar.gz', to => '/tmp';

    run 'move nvim binary to /usr/bin',
    command => 'cp $(find -name nvim | grep bin) /usr/bin',
    cwd => '/tmp',
    auto_die => TRUE;

    run 'move nvim shared libs',
    command => 'cp -r nvim-linux64/share/nvim /usr/share',
    cwd => '/tmp',
    auto_die => TRUE;

    # save nvim config files
    file "~/.config/nvim/init.vim",
    source => 'lib/Devel/Nvim/files/init.vim';

    file "~/.vimrc",
    source => 'lib/Devel/Nvim/files/vimrc.vim';

    # install nvm (nodejs)
    my $nvm_v = "v0.39.3";
    my $nvm_script = "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_v/install.sh";
    my $cmd = "curl -o- $nvm_script | bash";

    run 'intall latest nvm',
    command => $cmd,
    unless => "nvm --version",
    auto_die => TRUE;

    # install nodejs
    my $node_v = "v18.17.0";
    run "install nodejs version $node_v",
    command => "nvm install $node_v",
    auto_die => TRUE;

    # install vim-plug package manager
    my $plug = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim';
    download $plug, "~/.vim/autoload/plug.vim";

    # install nvim packages
    run 'setup vim packages',
    command => 'nvim -c PlugInstall -c quitall',
    auto_die => TRUE;

    # config nvim plugins
    run 'Config plugins',
    command => 'nvim -c CocInstall\ coc-perl -c quitall',
    auto_die => TRUE;
    
    return 1;
}

desc 'install nvim editor';
task 'install_nvim', group => 'development', 
sub { 

    run "update debian", command => "apt update", auto_die => TRUE;

    # upgrade
    update_system
    on_change => sub {
        for my $pkg (@_) {
            say "$_: " . $pkg->{lc $_} for qw( Name Version Action );
        }
    };

    my @conflict = qw(nodejs neovim);
    pkg $_, ensure => "absent" for @conflict;

    my @prereqs = qw(curl git ripgrep byobu universal-ctags build-essential libssl-dev);
    pkg $_, ensure => "present" for @prereqs;
    setup_nvim;
};


1;


__END__

=pod

=head1 NAME

Devel::Nvim  tasks to setup nvim editor.

=head1 DESCRIPTION

This install the latest nvim together with config files, plugins and tools to
setup a complete environment needed.

=head1 USAGE

Just include and use.

    include qw/Devel::Nvim/;

    task yourtask => sub {
       Devel::Nvim::install_nvim();
    };

=head1 TASKS

=over 4

=item install_nvim

to install latest nvim editor and flavoured configuration and toolset.

=back

=cut
