package App::Sqitch::GUI;

use 5.010001;
use Moose;
use namespace::autoclean;

use Data::Printer;
use App::Sqitch::GUI::Controller;

our $VERSION = '0.002';

has 'controller' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::Controller',
    lazy_build => 1,
);

sub _build_controller {
    return App::Sqitch::GUI::Controller->new();
}

sub run {
    shift->controller->app->MainLoop;
}

__PACKAGE__->meta->make_immutable;

1;    # End of App::Sqitch::GUI
