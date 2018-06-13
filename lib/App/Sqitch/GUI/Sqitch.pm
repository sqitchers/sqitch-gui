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

around 'emit' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

around 'emit_literal' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

around 'vent' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

around 'vent_literal' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

around 'page' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

around 'page_literal' => sub {
    my ($orig, $self) = (shift, shift);
    my $msg = join '', @_;
    $self->controller->log_message($msg);
};

1;
