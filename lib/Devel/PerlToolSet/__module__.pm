## no critic
package Devel::PerlToolSet;
## critic
use strictures 2;

use Rex -base;

user 'root';
group development => 'perl.dev', 'js.dev';

our $brew = "~/perl5/perlbrew/bin/perlbrew";
our $cpm = "~/perl5/perlbrew/bin/cpm";
our $cpanm = "~/perl5/perlbrew/bin/cpanm";

desc "install perlbrew";
task perlbrew => sub {
   # update
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

   my @conflict = qw( perlbrew );
   pkg $_, ensure => "absent" for @conflict;

   my @prereqs = qw(build-essential libssl-dev);
   pkg $_, ensure => "present" for @prereqs;

   run 'install perlbrew',
   command => 'curl -L https://install.perlbrew.pl | bash',
   unless  => "$brew --version",
   auto_die => TRUE;

   run 'run perlbrew init',
   command => "$brew init",
   unless => "$brew --version",
   auto_die => TRUE;

   append_if_no_such_line '~/.profile',
   line => 'source ~/perl5/perlbrew/etc/bashrc',
   on_change => sub {
      say "perlbrew initialized";
   };

};

desc "install cpanm and cpm";
task cpanm => sub {

   run 'install cpanm',
   command => "$brew install-cpanm",
   unless => "$cpanm --version",
   auto_die => TRUE;

   run 'install cpm',
   command => "$brew install-cpm",
   unless => "$cpm --version",
   auto_die => TRUE;
};

desc "install developer toolkit";
task devtool => sub {
   my @dev = qw(
   Carton Devel::MAT Devel::REPL  App::Yath
   Devel::Trace Devel::Cover Devel::NYTProf
   Perl::LanguageServer Perl::Tidy
   Perl::Critic
   );
   my @prereqs = qw(perl-doc libanyevent-perl libio-aio-perl);
   pkg $_, ensure => "present" for @prereqs;
   my $modules = join " ", @dev;

   run "install modules",
   command => "$cpm install -g $modules",
   auto_die => TRUE;
};

desc "install frameworks";
task kits => sub {
   my @kits = qw(
   Mojolicious DBI DBIx::Class Object::Pad
   Moo Moose Type::Tiny
   IO::Async AnyEvent FFI::Platypus
   );

   # some package need C headers to compile
   my @prereqs =
   qw(
      libnet-ssleay-perl openssl libssl-dev liblz-dev 
      pkgconf libyaml-dev
   );

   pkg $_, ensure => "present" for @prereqs;

   run "install devel kits",
   command => "$cpm install -g @kits",
   auto_die => TRUE;

   my @plugins = 
   map { "Devel::REPL::Plugin::$_" }
   qw(
   FancyPrompt         Packages            B::Concise
   Colors              FindVariable        Peek
   Commands            History             PPI
   Completion          Interrupt           ReadLineHistory
   LexEnv              Refresh
   DDC                 MultiLine::PPI      ShowClass
   DDS                 Nopaste             Timing
   DumpHistory         OutputCache         Turtles
   CompletionDriver::Keywords
   CompletionDriver::LexEnv
   CompletionDriver::Methods
   CompletionDriver::Globals
   CompletionDriver::INC
   );
   
   run "install repl plugins",
   command => "$cpm install -g @plugins",
   auto_die => TRUE;

   # REPL configuration
   file "~/.re.pl/repl.rc",
   source => "./lib/Devel/PerlToolSet/files/repl.rc";

};

my @tasks = map 
{ "Devel:PerlToolSet:$_" } qw(perlbrew cpanm devtool kits);

desc "batch install everything";
batch install_all => (@tasks);
1;

=pod

=head1 NAME

Devel::PerlToolSet - Install toolset for perl development

=head1 DESCRIPTION

This will install latest cpanm, cpm, perlbrew, carton, and
main develpoment modules such as Mojolicious and toolkit
such as profilers, repl(s), etc...

=head1 USAGE

 include qw/Devel::PerlToolSet/;

 task yourtask => sub {
    Devel::PerlToolSet::install_all;
 };

=head1 TASKS

=over 4

=item perlbrew

install latest perlbrew.

=item cpanm

install latest cpanm and cpm.

=back

=cut
