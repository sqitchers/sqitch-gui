#!/bin/env perl

use strict;
use warnings;
use Test::More tests => 21;
use File::HomeDir;
use Path::Class;
use File::Spec;

# use App::Sqitch;
# use App::Sqitch::GUI::Config;
use App::Sqitch::GUI;

my $CLASS;
BEGIN {
    #plan( skip_all => 'Not ready!' );

    $CLASS = 'App::Sqitch::GUI::Config';
    use_ok($CLASS) or die;
}

#-- Use my test configurations

my $test_file = File::Spec->catfile(qw(t test.conf));
$ENV{SQITCH_USER_CONFIG} = $test_file,

isa_ok( my $config = $CLASS->new( confname => $test_file ),
    $CLASS, 'New config object' );

is($config->confname, 't/test.conf', 'confname should be "t/test.conf"');

diag scalar $config->dump, "\n";

ok( $config->can($_), "Testing if can $_" )
    for qw(repo_default_name repo_default_path repo_conf_list repo_list);

is $config->user_file, $test_file,
    'Should preferably get SQITCH_USER_CONFIG file from user_file';

#-- Initialize the app

ok(my $gui = App::Sqitch::GUI->new, 'New GUI');
ok(my $controller = $gui->controller, 'New GUI controller');

my ($name, $path) = ('Test','t/test-repo');

ok $controller->config_add_repo($name, $path), 'Add test repo';

ok($config->reload, 'reload configurations');
diag $config;
diag$controller->config;
# ok($controller->config_reload(), 'reload configurations');
diag scalar $config->dump, "\n";

my $conf_list = { "repository.${name}.path" => $path };

is_deeply($config->repo_conf_list, $conf_list, 'Repository list');

is($config->has_repo_name($name), 1, "has_repo_name $name");
is($config->has_repo_path($path), 1, "has_repo_path $path");

ok($controller->config_set_default($name), 'Set default test repo');

ok($config->reload, 'reload configurations');
diag scalar $config->dump, "\n";

is($config->repo_default_name, $name, 'Default repository name');
is($config->repo_default_path, $path, 'Default repository path');

ok( $controller->config_remove_repo( $name, $path, 1 ),
    'Remove repo and default' );

ok($config->reload, 'reload configurations');
diag scalar $config->dump, "\n";
