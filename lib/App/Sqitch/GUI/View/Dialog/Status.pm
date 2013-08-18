package App::Sqitch::GUI::View::Dialog::Status;

use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

has state => (
    is       => 'rw',
    isa      => enum([ qw(init idle sele) ]),
    required => 1,
    default  => 'init',
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

    $self->state($state);
    print " Dialog status is $state\n";

    return;
}

sub get_state {
    my $self = shift;

    return $self->state;
}

sub is_state {
    my ($self, $state) = @_;

    return 1 if $self->state eq $state;

    return;
}

no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;

1;
