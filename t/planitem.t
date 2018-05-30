#
# Testing App::Sqitch::GUI::Model::PlanItem
#

use strict;
use warnings;

use Test::More;
use lib qw( lib ../lib );

use Path::Class;
use App::Sqitch::GUI::Model::PlanItem;

ok my $plan = App::Sqitch::GUI::Model::PlanItem->new,
    'new plan item';

is $plan->item, undef, 'plan item';
is $plan->name, undef, 'plan name';
is $plan->change_id, undef, 'change id';

ok !$plan->item(0), 'set plan item';
ok $plan->name('appschema'), 'set plan name';

is $plan->item, 0, 'plan item';
is $plan->name, 'appschema', 'plan name';
is $plan->change_id, undef, 'change id';

ok $plan->item(1), 'set plan item';
ok $plan->name('users'), 'set plan name';
ok $plan->change_id('8d77c5f588b60bc0f2efcda6369df5cb0177521d'), 'set change id';

is $plan->item, 1, 'plan item';
is $plan->name, 'users', 'plan name';
is $plan->change_id, '8d77c5f588b60bc0f2efcda6369df5cb0177521d', 'change id';

done_testing;
