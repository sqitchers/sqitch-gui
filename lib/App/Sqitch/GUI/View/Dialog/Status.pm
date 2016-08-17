package App::Sqitch::GUI::View::Dialog::Status;

# ABSTRACT: Projects Dialog Status

use Moo;
use Type::Utils qw(enum);
use namespace::autoclean;

has dlg_state => (
    is       => 'rw',
    isa      => enum([ qw(init idle sele edit add) ]),
    required => 1,
    default  => 'init',
);

# with 'MooseX::Observer::Role::Observable' => {
#     notify_after => [
#         qw{
#              set_state
#         }
#     ]
# };
with 'App::Sqitch::GUI::Roles::Observable';

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

after set_state => sub {
    my ($self) = @_;
    $self->notify();
};

1;
