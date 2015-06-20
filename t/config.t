use strict;
use warnings;
use Test::More;
use Path::Class;

use App::Sqitch::GUI::Config;

$ENV{HOME} = 't/home';    # set HOME for testing

ok my $conf = App::Sqitch::GUI::Config->new, 'new config instance';

is $conf->user_file, 't/home/.sqitch/sqitch.conf', 'user config file';
is $conf->local_file, '/home/flipr/sqitch.conf', 'local config file';

my ( $name, $path ) = ( 'flipr', '/home/flipr' );

my $conf_href = { "project.${name}.path" => $path };

is_deeply $conf->_conf_projects_list, $conf_href, 'projects config';
is_deeply $conf->project_list, { $name => $path }, 'projects list';

is $conf->default_project_name, $name, 'default repo name';
is $conf->default_project_path, $path, 'default repo path';

# Inspired from:
# http://perltricks.com/article/178/2015/6/17/Separate-data-and-behavior-with-table-driven-testing
# Thanks!
my @data = (
    [ ( 'unknown',  'Unknown' ) ],
    [ ( 'pg',       'PostgreSQL' ) ],
    [ ( 'mysql',    'MySQL' ) ],
    [ ( 'sqlite',   'SQLite' ) ],
    [ ( 'oracle',   'Oracle' ) ],
    [ ( 'firebird', 'Firebird' ) ],
);
foreach my $row ( @data ) {
    is $conf->get_engine_name($row->[0]), $row->[1],
        "engine name: $row->[1]";
}

# Not used, yet
# $conf->get_engine_from_name
# $conf->has_repo_name
# $conf->has_repo_path

is $conf->project_list_cnt, 1, 'project count';

like $conf->icon_path, qr/share.+icons/, 'get the icons path';

done_testing;
