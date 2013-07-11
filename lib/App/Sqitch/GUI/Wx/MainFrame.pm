package App::Sqitch::GUI::Wx::MainFrame;

use Moose;
use MooseX::NonMoose;
use Wx qw<:everything>;
use Wx::Event qw(EVT_BUTTON);

extends 'Wx::Frame';

has title => (
    is       => 'rw',
    isa      => 'Str',
    required => 0,
    default  => 'Hello World!',
    trigger  => \&_change_title,
);

sub FOREIGNBUILDARGS {
    my $class     = shift;
    my %args  = @_;
    my $title = exists $args{title} ? $args{title} : 'Sqitch::GUI';

    return (
        undef,
        - 1,
        $title,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub BUILD {
    my $self = shift;

    my $panel = Wx::Panel->new($self);

    Wx::StaticText->new(
        $panel,
        -1,
        'Welcome to the world of WxPerl!',
        [ 20, 20 ],
    );
}

sub _change_title {
    my $self  = shift;
    my $title = shift;
    $self->SetTitle($title);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
