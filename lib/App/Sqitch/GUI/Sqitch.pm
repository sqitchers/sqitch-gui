package App::Sqitch::GUI::Sqitch;

# ABSTRACT: A Sqitch Extension

use Moo;
use namespace::autoclean;

extends 'App::Sqitch';

around 'trace' => sub {
    my ($orig, $self) = (shift, shift);
    $self->$orig(@_);
};

around 'trace_literal' => sub {
    my ($orig, $self) = (shift, shift);
    $self->$orig(@_);
};

around 'emit' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

around 'emit_literal' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

around 'vent' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

around 'vent_literal' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

around 'page' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

around 'page_literal' => sub {
    my ($orig, $self) = (shift, shift);
    Wx::LogMessage(@_);
};

1;
