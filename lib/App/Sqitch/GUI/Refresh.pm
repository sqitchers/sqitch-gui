package App::Sqitch::GUI::Refresh;

use 5.010;
use Moose;
use namespace::autoclean;

with 'MooseX::Observer::Role::Observer';

use App::Sqitch::GUI::Rules;

has 'view' => (
    is   => 'ro',
    isa  => 'App::Sqitch::GUI::View',
);

has 'gui_rules' => (
    is         => 'ro',
    isa        => 'App::Sqitch::GUI::Rules',
    lazy_build => 1,
);

sub _build_gui_rules {
    return App::Sqitch::GUI::Rules->new;
}

sub update {
    my ( $self, $subject, $args, $eventname ) = @_;
    my $state = $subject->get_state;
    $self->view->set_status($state, $self->gui_rules);
    return;
}

__PACKAGE__->meta->make_immutable;

1;
