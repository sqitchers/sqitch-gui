#
# Test the
#
use 5.010;
use strict;
use warnings;
use Test::More;
use Path::Class qw(dir file);

use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Model;

$ENV{HOME} = dir('t', 'home')->stringify;   # set HOME for testing

# protect against user's environment variables (from Sqitch)
delete @ENV{qw( SQITCH_CONFIG SQITCH_USER_CONFIG SQITCH_SYSTEM_CONFIG )};

ok my $conf = App::Sqitch::GUI::Config->new, 'new config instance';
isa_ok $conf, 'App::Sqitch::GUI::Config', 'GUI::Config';

my ( $name, $path ) = ( 'flipr', dir( 't', 'home', 'flipr' ) );

is $conf->default_project_name, $name, 'default project name';
is $conf->default_project_path, $path->stringify, 'default project path';

ok my $model = App::Sqitch::GUI::Model->new( config => $conf ),
    'new model instance';
isa_ok $model, 'App::Sqitch::GUI::Model', 'GUI::Model';

for my $rec ( $model->projects ) {
    my ($name, $attrib) = @{$rec};
    ok $name, "project '$name'";
    is ref $attrib, 'HASH', 'project attributes';
}

isa_ok $model->project_list_data, 'App::Sqitch::GUI::Model::ListDataTable',
    'Project ListDataTable';
isa_ok $model->plan_list_data, 'App::Sqitch::GUI::Model::ListDataTable',
    'Plan ListDataTable';

is ref $model->project_dlg_list_meta_data, 'ARRAY', 'project dlg list metadata';
is ref $model->project_list_meta_data, 'ARRAY', 'project list metadata';
is ref $model->plan_list_meta_data, 'ARRAY', 'plan list metadata';

( $name, $path ) = ( 'flipr', dir( 't', 'home', 'intro' ) );

ok $conf->default_project_name($name), 'set default project name';
ok $conf->default_project_path($path), 'set default project path';

is $conf->default_project_name, $name, 'default project name';
is $conf->default_project_path, $path->stringify, 'default project path';

done_testing;
