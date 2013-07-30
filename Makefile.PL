use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'App-Sqitch-GUI';
all_from 'lib/App/Sqitch/GUI.pm';
author   q{Stefan Suciu <stefbv@s2i2.ro>};
license  'gpl';

perl_version 5.010001;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#App-Sqitch-GUI',
   license    => 'http://www.gnu.org/licenses/gpl-2.0.html',
   #repository => 'git://github.com/Stefan Suciu/App-Sqitch-GUI.git',
   #bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Sqitch-GUI',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires(
    'App::Sqitch'        => '0.973',
    'Wx'                 => '0.970101',
    'Wx::Perl::ListCtrl' => '0.03',
    'Wx::STC'            => '0.01',
    'MooseX::NonMoose'   => '0.22',
);

#install_as_cpan;
#auto_install;

#install_share 'share';
install_script 'bin/sqitch-gui';

WriteAll;
