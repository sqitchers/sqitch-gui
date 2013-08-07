package App::Sqitch::GUI::Controller;

use Moose;
use namespace::autoclean;
use App::Sqitch::GUI::WxApp;

use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU>;

has 'app' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::WxApp',
    lazy_build => 1,
);

has 'view' => (
    is      => 'rw',
    isa     => 'App::Sqitch::GUI::View',
    default => sub { shift->app->view },
);

sub _build_app {
    my $self = shift;
    my $app = App::Sqitch::GUI::WxApp->new();
    return $app;
}

sub BUILD {
    my $self = shift;
    print " Building...\n";
}

__PACKAGE__->meta->make_immutable;

1;
