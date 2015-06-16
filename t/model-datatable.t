#
# Testing App::Sqitch::GUI::Model::ListDataTable
#

use strict;
use warnings;

use Test::Most;

use lib qw( lib ../lib );

use App::Sqitch::GUI::Model::ListDataTable;

ok my $dt = App::Sqitch::GUI::Model::ListDataTable->new, 'new data table';

is $dt->get_item_count, 0, 'item count: no values';

ok $dt->add_row('Item1', 'Data1'), 'add row 1';
is $dt->get_item_count, 1, 'item count: 1 value';
is $dt->get_value( 0, 0 ), 'Item1', 'get value';
is $dt->get_value( 0, 1 ), 'Data1', 'get value';

ok $dt->add_row('Item2', 'Data2'), 'add row 2';
is $dt->get_item_count, 2, 'item count: 2 value';
is $dt->get_value( 1, 0 ), 'Item2', 'get value';
is $dt->get_value( 1, 1 ), 'Data2', 'get value';

ok $dt->add_row('Item3', 'Data3'), 'add row 2';
is $dt->get_item_count, 3, 'item count: 3 values';
is $dt->get_value( 2, 0 ), 'Item3', 'get value';
is $dt->get_value( 2, 1 ), 'Data3', 'get value';

ok $dt->set_value( 2, 0, 'Item3e'), 'change value';
ok $dt->set_value( 2, 1, 'Data3e'), 'change value';
is $dt->get_value( 2, 0 ), 'Item3e', 'get value';
is $dt->get_value( 2, 1 ), 'Data3e', 'get value';
is $dt->get_item_count, 3, 'item count: 3 values';
#diag $dt->get_data_as_string;

ok $dt->remove_row(1), 'remove row 1';
is $dt->get_item_count, 2, 'item count: 2 values';
#diag $dt->get_data_as_string;

# Change entire col 0 to "Item"
ok $dt->set_col(0, 'Item'), 'Set col 0 to "Item"';
is $dt->get_value( 0, 0 ), 'Item', 'get value';
is $dt->get_value( 1, 0 ), 'Item', 'get value';

# Change entire col 0 to "Item1, Item3"
ok $dt->set_col(0, ['Item1', 'Item3']), 'Set col 0 to "Item"';
is $dt->get_value( 0, 0 ), 'Item1', 'get value';
is $dt->get_value( 1, 0 ), 'Item3', 'get value';
#diag $dt->get_data_as_string;

# Test for failure:
throws_ok { $dt->get_value( 2, 0 ) }
    qr/\Qno such row/,
    'Should get an exception for an inexistent row - get_value';

throws_ok { $dt->set_value( 2, 0 ) }
    qr/\Qno such row/,
    'Should get an exception for an inexistent row - set_value';

done_testing;
