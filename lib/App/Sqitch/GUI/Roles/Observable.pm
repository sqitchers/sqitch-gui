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

__END__

=encoding utf8

=head1 SYNOPSIS

    my $status = App::Sqitch::GUI::Status->new;
    $status->add_observer(
        App::Sqitch::GUI::Refresh->new( view => $view )
    );

=head1 DESCRIPTION


=head1 INTERFACE

=head2 ATTRIBUTES

=head3 observers

The observers attribute is an array reference holding the objects
being observed.

=head2 INSTANCE METHODS

=head3 add_observer

Adds an object to the observer list.

=head3 count_observers

Counts and returns the number of observed objects.

=head3 remove_observers

Removes all observed objects.

=cut
