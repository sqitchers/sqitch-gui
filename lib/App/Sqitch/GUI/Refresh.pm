package App::Sqitch::GUI::Refresh;

# ABSTRACT: An Observer for the GUI

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
	SqitchGUIRules
    SqitchGUIView
);
use App::Sqitch::GUI::Rules;
use namespace::autoclean;

#with 'MooseX::Observer::Role::Observer';
with 'App::Sqitch::GUI::Roles::Observer';

has 'view' => (
    is   => 'ro',
    isa  => SqitchGUIView,
);

has 'rules' => (
    is      => 'ro',
    isa     => SqitchGUIRules,
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

1;
