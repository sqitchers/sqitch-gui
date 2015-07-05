package App::Sqitch::GUI::View::Dialog::Status;

# ABSTRACT: Projects Dialog Status

use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

has dlg_state => (
    is       => 'rw',
    isa      => enum([ qw(init idle sele edit add) ]),
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
    $self->dlg_state($state);
    return;
}

sub get_state {
    my $self = shift;
    return $self->dlg_state;
}

sub is_state {
    my ($self, $state) = @_;
    return 1 if $self->dlg_state eq $state;
    return;
}

no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;

1;
