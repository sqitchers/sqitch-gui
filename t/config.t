#!/bin/env perl

use strict;
use warnings;
use Test::More tests => 9;
use Path::Class;

use App::Sqitch::GUI;

$ENV{HOME} = 't/home';          # set HOME for testing

ok my $gui  = App::Sqitch::GUI->new, 'New GUI';
ok my $ctrl = $gui->controller,      'New GUI controller';

my $config = $ctrl->config;

is $config->user_file, 't/home/.sqitch/sqitch.conf', 'Test user_file';

is_deeply $config->project_list, {}, 'No project list';
is $config->default_project_name, undef, 'No default repo name';
is $config->default_project_path, undef, 'No default repo path';

#ok($config->reload, 'reload configurations');

# User config file

my ( $name, $path ) = ( 'Test', 't/home/test-repo' );

ok $ctrl->config_edit_project( $name, $path ), 'Add test repo';
ok $ctrl->config_set_default($name), 'Set test repo as default';

# Also set as default in the config object
# ok( $config->default_project_name($name),      'Set default repo name' );
# ok( $config->default_project_path( dir $path), 'Set default repo path' );

# is( $config->default_project_name, $name, 'Check default repo name' );
# is( $config->default_project_path, $path, 'Check default repo path' );

# my $conf_list = { "project.${name}.path" => $path };
# is_deeply($config->project_list, $conf_list, 'Project list');

# Local config file

# $config->reload($config->default_project_path);
# $config->reload('t/home/.sqitch');

#p $config;

# Cleanup
ok $ctrl->config_remove_project( $name, $path, 1 ), 'Remove repo and default';
