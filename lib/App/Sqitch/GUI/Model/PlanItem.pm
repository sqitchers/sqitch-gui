package App::Sqitch::GUI::Model::PlanItem;

# ABSTRACT: Plan Item model

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    Int
    Str
    Maybe
);

has 'item' => (
    is      => 'rw',
    isa     => Maybe[Int],
);

has 'name' => (
    is  => 'rw',
    isa => Maybe[Str],
);

has 'change_id' => (
    is  => 'rw',
    isa => Maybe[Str],
);

1;
