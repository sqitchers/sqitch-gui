#
# Testing App::Sqitch::GUI::Model::ProjectItem
#

use strict;
use warnings;

use Test::More;
use lib qw( lib ../lib );

use Path::Class;
use App::Sqitch::GUI::Model::ProjectItem;

ok my $project = App::Sqitch::GUI::Model::ProjectItem->new,
    'new project item';

is $project->item, undef, 'project item';
is $project->name, undef, 'project name';
is $project->path, undef, 'project path';

my $test_path = dir( 't', 'home', 'test-repo' );
my $test2path = dir( 't', 'home', 'another-repo' );

ok !$project->item(0), 'set project item';
ok $project->name('flipr'), 'set project name';
ok $project->path($test_path), 'set project path';

is $project->item, 0, 'project item';
is $project->name, 'flipr', 'project name';
is $project->path, $test_path->stringify, 'project path';

ok $project->item(1), 'set project item';
ok $project->name('flipr2'), 'set project name';
ok $project->path($test2path), 'set project path';

is $project->item, 1, 'project item';
is $project->name, 'flipr2', 'project name';
is $project->path, $test2path->stringify, 'project path';

done_testing;
