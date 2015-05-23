package App::Sqitch::GUI::View::Dialog::Refresh;

use 5.010;
use Moose;
use namespace::autoclean;

with 'MooseX::Observer::Role::Observer';

use App::Sqitch::GUI::View::Dialog::Rules;

has 'dialog' => (
    is   => 'ro',
    isa  => 'App::Sqitch::GUI::View::Dialog::Repo',
);

has 'rules' => (
    is      => 'ro',
    isa     => 'App::Sqitch::GUI::View::Dialog::Rules',
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

__PACKAGE__->meta->make_immutable;

1;
