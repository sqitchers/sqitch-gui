package App::Sqitch::GUI::View::Dialog::Refresh;

# ABSTRACT: An Observer for the Projects Dialog

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    SqitchGUIDialogProjects
    SqitchGUIDialogRules
);
use App::Sqitch::GUI::View::Dialog::Rules;
use namespace::autoclean;

with 'App::Sqitch::GUI::Roles::Observer';

has 'dialog' => (
    is   => 'ro',
    isa  => SqitchGUIDialogProjects,
);

has 'rules' => (
    is      => 'ro',
    isa     => SqitchGUIDialogRules,
    lazy    => 1,
    builder => '_build_rules',
);

sub _build_rules {
    return App::Sqitch::GUI::View::Dialog::Rules->new;
}

sub update {
    my ( $self, $subject, $args, $eventname ) = @_;
    my $state = $subject->get_state;
    $self->dialog->set_status($state, $self->rules->get_rules($state) );
    return;
}

1;
