package App::Sqitch::GUI::Target;

# ABSTRACT: A Sqitch::Target Extension

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
);
use Path::Class qw(dir file);
use App::Sqitch::X qw(hurl);
use namespace::autoclean;

extends 'App::Sqitch::Target';

has 'top_dir' => (
    is       => 'rw',
    isa      => Dir,
    required => 1,
);

1;
