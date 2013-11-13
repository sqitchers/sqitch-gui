#!/bin/env perl

use strict;
use warnings;
use Test::More;
use File::HomeDir;
use Path::Class;
use File::Spec;

# use App::Sqitch;
# use App::Sqitch::GUI::Config;
# use Data::Printer;
use App::Sqitch::GUI;

my $CLASS;
BEGIN {
    plan( skip_all => 'Not ready!' );

    $CLASS = 'App::Sqitch::GUI::Config';
    use_ok $CLASS or die;
}

my $test_file = File::Spec->catfile(qw(t test.conf));
$ENV{SQITCH_USER_CONFIG} = $test_file,

isa_ok my $config = $CLASS->new, $CLASS, 'New config object';
is $config->confname, 'test.conf', 'confname should be "test.conf"';
diag scalar $config->dump, "\n";
ok $config->can($_), "Testing if can $_" for qw(repo_default_name repo_default_path repo_conf_list repo_list config_file);
is $config->user_file, $test_file,
    'Should preferably get SQITCH_USER_CONFIG file from user_file';

my $gui = App::Sqitch::GUI->new;
my $controller = $gui->controller;

my ($name, $path) = ('Test','t/test-repo');

ok $controller->config_add_repo($name, $path), 'Add test repo';

# ReRead CONFIG? How?
#isa_ok $config = $CLASS->new, $CLASS, 'New config object';
# $controller->config->DESTROY;

diag scalar $config->dump, "\n";
# p $config->repo_conf_list;
is_deeply $config->repo_conf_list, undef, 'Repository list';

is $config->has_repo_name($name), 1, "has_repo_name $name";
is $config->has_repo_path($path), 1, "has_repo_path $path";

ok $controller->config_set_default($name), 'Set default test repo';
is $config->repo_default_name, $name, 'Default repository name';
is $config->repo_default_path, $path, 'Default repository path';

ok $controller->config_remove_repo($name, $path, 1), 'Remove repo and default';
