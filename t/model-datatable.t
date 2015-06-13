#
# Testing App::Sqitch::GUI::Model::ListDataTable
#

use strict;
use warnings;

use Test::More;

use lib qw( lib ../lib );

use App::Sqitch::GUI::Model::ListDataTable;

ok my $dt = App::Sqitch::GUI::Model::ListDataTable->new, 'new data table';

is $dt->get_item_count, 0, 'item count: no values';

ok $dt->set_value( 0, 0, 'Item' ), 'set value';

ok $dt->set_value( 0, 1, 'Data' ), 'set value';

is $dt->get_item_count, 1, 'item count: 1 value';

is $dt->get_value( 0, 0 ), 'Item', 'get value';

is $dt->get_value( 0, 1 ), 'Data', 'get value';

ok $dt->set_value( 1, 0, 'Item2' ), 'set value';

ok $dt->set_value( 1, 1, 'Data2' ), 'set value';

is_deeply $dt->get_data, [ [ "Item", "Data" ], [ "Item2", "Data2" ] ],
    'get data';

ok $dt->set_value( 2, 0, 'Item3' ), 'set value';

ok $dt->set_value( 2, 1, 'Data3' ), 'set value';

is $dt->get_item_count, 3, 'item count: 3 values';

done_testing;
