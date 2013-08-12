package App::Sqitch::GUI::Refresh;

use 5.010;
use Moose;
use namespace::autoclean;

with 'MooseX::Observer::Role::Observer';

use App::Sqitch::GUI::Settings;

#use Data::Printer;

has 'view' => (
    is   => 'ro',
    isa  => 'App::Sqitch::GUI::View',
);

has 'settings' => (
    is         => 'ro',
    isa        => 'App::Sqitch::GUI::Settings',
    lazy_build => 1,
);

sub _build_settings {
    return App::Sqitch::GUI::Settings->new;
}

sub update {
    my ( $self, $subject, $args, $eventname ) = @_;
    my $state = $subject->get_state;
    print "Current state is '$state'\n";
    $self->view->set_status($state, $self->settings);
}

__PACKAGE__->meta->make_immutable;

1;
