package App::Sqitch::GUI::Sqitch;

use Moose;
use namespace::autoclean;

extends 'App::Sqitch';

sub emit {
    shift;
    Wx::LogMessage(@_);
}

sub emit_literal {
    shift;
    Wx::LogMessage(@_);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
