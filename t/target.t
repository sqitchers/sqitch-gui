use strict;
use warnings;
use Test::More;
use Test::Exception;
use Path::Class qw(dir file);

use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Sqitch;

my $CLASS;
BEGIN {
    $CLASS = 'App::Sqitch::GUI::Target';
    use_ok $CLASS or die;
}

##############################################################################
# Load a target and test the basics.


$ENV{HOME} = dir('t', 'home')->stringify;   # set HOME for testing

# protect against user's environment variables (from Sqitch)
delete @ENV{qw( SQITCH_CONFIG SQITCH_USER_CONFIG SQITCH_SYSTEM_CONFIG )};

ok my $config = App::Sqitch::GUI::Config->new, 'new config instance';
# ok $config->current_project_path( dir( 't', 'home', 'flipr' ) ),
#     'set current path';

ok my $sqitch = App::Sqitch::GUI::Sqitch->new(
    options => { engine => 'sqlite' },
    config  => $config,
), 'Load a sqitch sqitch object';

isa_ok my $target = $CLASS->new(sqitch => $sqitch), $CLASS;

can_ok $target, qw(
    new
    name
    target
    uri
    sqitch
    engine
    registry
    client
    plan_file
    plan
    top_dir
    deploy_dir
    revert_dir
    verify_dir
    extension
);

# Look at default values.
is $target->name, 'db:sqlite:', 'Name should be "db:sqlite:"';
is $target->target, $target->name, 'Target should be alias for name';
is $target->uri, URI::db->new('db:sqlite:'), 'URI should be "db:sqlite:"';
is $target->sqitch, $sqitch, 'Sqitch should be as passed';
is $target->engine_key, 'sqlite', 'Engine key should be "sqlite"';
isa_ok $target->engine, 'App::Sqitch::Engine::sqlite', 'Engine';
is $target->registry, $target->engine->default_registry,
    'Should have default registry';
my $client = $target->engine->default_client;
$client .= '.exe' if $^O eq 'MSWin32' && $client !~ /[.](?:exe|bat)$/;
is $target->client, $client, 'Should have default client';

#is $target->top_dir, dir( 't', 'home', 'flipr' ), 'Should have custom top_dir';
throws_ok { $target->top_dir, dir( 't', 'home', 'flipr' ) } qr/^Missing required arguments:/,
    'Should get error for missing params';

is $target->deploy_dir, $target->top_dir->subdir('deploy'),
    'Should have default deploy_dir';
is $target->revert_dir, $target->top_dir->subdir('revert'),
    'Should have default revert_dir';
is $target->verify_dir, $target->top_dir->subdir('verify'),
    'Should have default verify_dir';
is $target->extension, 'sql', 'Should have default extension';
is $target->plan_file, $target->top_dir->file('sqitch.plan')->cleanup,
    'Should have default plan file';
isa_ok $target->plan, 'App::Sqitch::Plan', 'Should get plan';
is $target->plan->file, $target->plan_file,
    'Plan file should be copied from Target';
my $uri = $target->uri;
is $target->dsn, $uri->dbi_dsn, 'DSN should be from URI';
is $target->username, $uri->user, 'Username should be from URI';
is $target->password, $uri->password, 'Password should be from URI';

do {
    isa_ok my $target = $CLASS->new(sqitch => $sqitch), $CLASS;
    local $ENV{SQITCH_PASSWORD} = 'S3cre7s';
    is $target->password, $ENV{SQITCH_PASSWORD},
        'Password should be from environment variable';
};

done_testing;
