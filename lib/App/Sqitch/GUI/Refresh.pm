package App::Sqitch::GUI::Refresh;

# ABSTRACT: An Observer for the GUI

use 5.010;
use Moose;
use namespace::autoclean;

with 'MooseX::Observer::Role::Observer';

use App::Sqitch::GUI::Rules;

has 'view' => (
    is   => 'ro',
    isa  => 'App::Sqitch::GUI::View',
);

has 'rules' => (
    is      => 'ro',
    isa     => 'App::Sqitch::GUI::Rules',
    lazy    => 1,
    builder => '_build_rules',
);

sub _build_rules {
    return App::Sqitch::GUI::Rules->new;
}

sub update {
    my ( $self, $subject, $args, $eventname ) = @_;
    my $state = $subject->get_state;
    $self->view->set_status( $state, $self->rules->get_rules($state) );
    return;
}

__PACKAGE__->meta->make_immutable;

1;
