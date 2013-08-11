package App::Sqitch::GUI::Refresh;

use 5.010;
use Moose;
use namespace::autoclean;

#use Data::Printer;

# apply the oberserver-role, tagging the class as observer and ...
with 'MooseX::Observer::Role::Observer';

has 'view' => (
    is   => 'ro',
    isa  => 'App::Sqitch::GUI::View',
);

# ... require an update-method to be implemented
# this is called after the observed subject calls an observed method
sub update {
    my ( $self, $subject, $args, $eventname ) = @_;
    my $state = $subject->get_state;
    print "Current state is '$state'\n";
    #$self->view->set_status($state);
}

__PACKAGE__->meta->make_immutable;

1;
