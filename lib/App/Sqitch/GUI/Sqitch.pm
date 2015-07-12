package App::Sqitch::GUI::Sqitch;

# ABSTRACT: A Sqitch Extension

use Moo;
use App::Sqitch::GUI::Types qw(
    SqitchGUIController
);
use namespace::autoclean;

extends 'App::Sqitch';

has 'controller' => (
    is   => 'ro',
    isa  => SqitchGUIController,
    lazy => 1,
);

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
    $self->controller->log_message(@_);
};

around 'emit_literal' => sub {
    my ($orig, $self) = (shift, shift);
    $self->controller->log_message(@_);
};

around 'vent' => sub {
    my ($orig, $self) = (shift, shift);
    $self->controller->log_message(@_);
};

around 'vent_literal' => sub {
    my ($orig, $self) = (shift, shift);
    $self->controller->log_message(@_);
};

around 'page' => sub {
    my ($orig, $self) = (shift, shift);
    $self->controller->log_message(@_);
};

around 'page_literal' => sub {
    my ($orig, $self) = (shift, shift);
    $self->controller->log_message(@_);
};

1;
