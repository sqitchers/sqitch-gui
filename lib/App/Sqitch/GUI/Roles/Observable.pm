package App::Sqitch::GUI::Roles::Observable;

# ABSTRACT: Observable role

use Moo::Role;
use MooX::HandlesVia;
use namespace::autoclean;

has observers => (
    is          => 'ro',
    handles_via => 'Array',
    default     => sub { [] },
    handles     => {
        'add_observer'     => 'push',
        'count_observers'  => 'count',
        'remove_observers' => 'clear',
    },
);

sub notify {
    my ($self) = @_;
    foreach my $observer ( @{ $self->observers } ) {
        $observer->update($self);
    }
}

1;
