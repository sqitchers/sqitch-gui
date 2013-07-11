package App::Sqitch::GUI;

use 5.010;
use strict;
use warnings;

use Wx;
use App::Sqitch::GUI::Wx::App;

our $VERSION = '0.001';

sub run {
    App::Sqitch::GUI::Wx::App->new()->MainLoop();
}
