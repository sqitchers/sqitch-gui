package App::Sqitch::GUI::Model::ProjectItem;

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    Int
    Str
    Dir
    Maybe
);

has 'item' => (
    is  => 'rw',
    isa => Maybe[Int],
);

has 'name' => (
    is  => 'rw',
    isa => Maybe[Str],
);

has 'path' => (
    is  => 'rw',
    isa => Maybe[Dir],
);

1;
