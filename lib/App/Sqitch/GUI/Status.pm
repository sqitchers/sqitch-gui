package App::Sqitch::GUI::Status;

use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

has gui_state => (
    is       => 'rw',
    isa      => enum([ qw(load init idle edit) ]),
    required => 1,
    default  => 'load',
);

with 'MooseX::Observer::Role::Observable' => {
    notify_after => [
        qw{
             set_state
        }
    ]
};

sub set_state {
    my ($self, $state) = @_;
    $self->gui_state($state);
    return;
}

sub get_state {
    my $self = shift;
    return $self->gui_state;
}

sub is_state {
    my ($self, $state) = @_;
    return 1 if $self->gui_state eq $state;
    return;
}

no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;

1;
