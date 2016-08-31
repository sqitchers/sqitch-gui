package App::Sqitch::GUI::View::Dialog::Status;

# ABSTRACT: Projects Dialog Status

use Moo;
use Type::Utils qw(enum);
use namespace::autoclean;

with 'App::Sqitch::GUI::Roles::Observable';

has dlg_state => (
    is       => 'rw',
    isa      => enum([ qw(init idle sele edit add) ]),
    required => 1,
    default  => 'init',
);

sub set_state {
    my ($self, $state) = @_;
    $self->dlg_state($state);
    return $self;
}

sub get_state {
    my $self = shift;
    return $self->dlg_state;
}

sub is_state {
    my ($self, $state) = @_;
    return 1 if $self->dlg_state eq $state;
    return $self;
}

after set_state => sub {
    my ($self) = @_;
    $self->notify();
};

1;
