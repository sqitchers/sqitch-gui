package App::Sqitch::GUI::Wx::App;

use Moose;
use MooseX::NonMoose;

use Wx;
extends 'Wx::App';

use App::Sqitch::GUI::Wx::MainFrame;

has frame => (
    is       => 'ro',
    isa      => 'Wx::Frame',
    init_arg => undef,
    builder  => '_build_frame',
    lazy     => 1,
);

# Wx::App constructor takes no arguments.
sub FOREIGNBUILDARGS { return; }

# Initialize the frame.
sub _build_frame {
    return App::Sqitch::GUI::Wx::MainFrame->new();
}

sub OnInit {
    shift->frame->Show(1);
    return 1;
}

no Moose;

# __PACKAGE__->meta->make_immutable; # Do NOT do this for Wx::App.

1;
