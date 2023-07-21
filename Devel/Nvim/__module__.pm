##no critic
package Devel::Nvim;
##use critic

use strictures 2;
use Rex -base;

user 'root';

sub setup_nvim {
    my $url = 'https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz';

    run 'get nvim from git',
        command => "curl -o nvim.tar.gz -L $url",
        cwd => '/tmp',
        unless => 'test -e nvim.tar.gz',
        auto_die => TRUE;

    run 'unpack nvim',
        command => 'tar -xvzf nvim.tar.gz',
        cwd => '/tmp',
        unless => 'test -d nvim-linux64',
        auto_die => TRUE;

    run 'move binary to path',
        command => 'cp $(find -name nvim | grep bin) /usr/bin',
        cwd => '/tmp',
        auto_die => TRUE;

    run 'move the shared libs',
        command => 'cp -r nvim-linux64/share/nvim /usr/share',
        cwd => '/tmp',
        auto_die => TRUE;
    
    # save config files
    file "~/.config/nvim/init.vim",
        source => './Devel/files/init.vim';
    file "~/.vimrc",
        source => './Devel/files/vimrc.vim';

    # install nvm
    my $nvm_v = "v0.39.3";
    run 'intall latest node.js',
        command => "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_v/install.sh | bash",
        unless => "nvm --version",
        auto_die => TRUE;


    # install nodejs
    my $node_v = "v18.17.0";

    run 'install nodejs',
        command => "nvm install $node_v",
        auto_die => TRUE;

    # install vim-plug
    my $plug = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim';
    run 'install plug-vim',
        command => "curl -fLo ~/.vim/autoload/plug.vim --create-dirs $plug",
        unless => "test -e ~/.vim/autoload/plug.vim",
        auto_die => TRUE;

    # install plug packages
    run 'setup vim packages',
        command => 'nvim -c PlugInstall -c quitall',
        auto_die => TRUE;


    # config plugins
    run 'Config plugins',
        command => 'nvim -c CocInstall\ coc-perl -c quitall',
        auto_die => TRUE;
}

desc 'install latest nvim editor';
task 'install_nvim', group => 'development', 
sub { 

    run "update first",
        command => "apt update",
        auto_die => TRUE;

    # upgrade
    update_system
    on_change => sub {
        my (@modified_packages) = @_;
        for my $pkg (@modified_packages) {
            say "Name: $pkg->{name}";
            say "Version: $pkg->{version}";
            say "Action: $pkg->{action}";
        }
    };

    my @conflict = qw(nodejs neovim);
    pkg $_, ensure => "absent" for @conflict;
    my @prereqs = qw(curl git ripgrep byobu
    universal-ctags build-essential libssl-dev);
    pkg $_, ensure => "present" for @prereqs;
    setup_nvim;
};


1;


__END__

=pod

=head1 NAME

Devel::Nvim  tasks to setup nvim editor.

=head1 DESCRIPTION

This install the latest nvim together with config files, plugins and tools to setup a complete environment needed.

=head1 USAGE

Just include and use.

    include qw/Devel::Nvim/;

    task yourtask => sub {
       Devel::Nvim::install_nvim();
    };

=head1 TASKS

=over 4

=item install_nvim

to install latest nvim editor

=back

=cut
