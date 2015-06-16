#
# Testing App::Sqitch::GUI::Model::ProjectItem
#

use strict;
use warnings;

use Test::More;
use lib qw( lib ../lib );

use Path::Class;
use App::Sqitch::GUI::Model::ProjectItem;

ok my $current = App::Sqitch::GUI::Model::ProjectItem->new,
    'new current item';

is $current->item, undef, 'current item';
is $current->name, undef, 'current name';
is $current->path, undef, 'current path';

my $test_path = dir( 't', 'home', 'test-repo' );
my $test2path = dir( 't', 'home', 'another-repo' );

ok !$current->item(0), 'set current item';
ok $current->name('flipr'), 'set current name';
ok $current->path($test_path), 'set current path';

is $current->item, 0, 'current item';
is $current->name, 'flipr', 'current name';
is $current->path, $test_path->stringify, 'current path';

ok $current->item(1), 'set current item';
ok $current->name('flipr2'), 'set current name';
ok $current->path($test2path), 'set current path';

is $current->item, 1, 'current item';
is $current->name, 'flipr2', 'current name';
is $current->path, $test2path->stringify, 'current path';

done_testing;
