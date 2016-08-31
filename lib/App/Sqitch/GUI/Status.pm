package App::Sqitch::GUI::Status;

# ABSTRACT: GUI Status

use Moo;
use Type::Utils qw(enum);
use namespace::autoclean;

with 'App::Sqitch::GUI::Roles::Observable';

has gui_state => (
    is       => 'rw',
    isa      => enum([ qw(load init idle edit) ]),
    required => 1,
    default  => 'load',
);

sub set_state {
    my ($self, $state) = @_;
    $self->gui_state($state);
    return $self;
}

sub get_state {
    my $self = shift;
    return $self->gui_state;
}

sub is_state {
    my ($self, $state) = @_;
    return 1 if $self->gui_state eq $state;
    return $self;
}

after set_state => sub {
    my ($self) = @_;
    $self->notify();
};

1;
