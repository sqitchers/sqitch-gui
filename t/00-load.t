#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::Sqitch::GUI' ) || print "Bail out!\n";
}

diag( "Testing App::Sqitch::GUI $App::Sqitch::GUI::VERSION, Perl $], $^X" );
