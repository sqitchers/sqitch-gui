package App::Sqitch::GUI::Wx::Menubar;

# ABSTRACT: Wx Menubar Control

use Moo;
use App::Sqitch::GUI::Types qw(
    ArrayRef
    WxMenuBar
);
use Wx qw(:everything);
use Wx::Event qw(EVT_MENU);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::View::Dialog::Help;
use App::Sqitch::GUI::View::Dialog::About;

sub BUILD {};                              # required by the role (?!)

has 'menu_bar' => (
    is      => 'ro',
    isa     => WxMenuBar,
    lazy    => 1,
    builder => '_build_menu_bar',
);

sub _build_menu_bar {
    my $self = shift;

    # App menu
    my $app_menu = Wx::Menu->new;
    $app_menu->Append( $self->item_quit );

    # Admin menu
    my $admin_menu = Wx::Menu->new;
    $admin_menu->Append( $self->item_admin );

    # Help menu
    my $help_menu = Wx::Menu->new;
    $help_menu->Append( $self->item_help );
    $help_menu->Append( $self->item_about );

    my $menu_bar = Wx::MenuBar->new;
    $menu_bar->Append( $app_menu, __ "&App" );
    $menu_bar->Append( $admin_menu, __ "A&dmin" );
    $menu_bar->Append( $help_menu, __ "&Help" );

    return $menu_bar;
}

sub item_quit {
    my $self = shift;
    return Wx::MenuItem->new(
        undef,
        wxID_EXIT,
        "&Quit\tCtrl+Q",
        'Quit',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub item_admin {
    my $self = shift;
    return Wx::MenuItem->new(
        undef,
        2001,
        "Projects\tCtrl+P",
        'Projects',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub item_help {
    my $self = shift;
    return Wx::MenuItem->new(
        undef,
        wxID_HELP,
        '&Help',
        'Show HTML help',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

sub item_about {
    my $self = shift;
    return Wx::MenuItem->new(
        undef,
        wxID_ABOUT,
        '&About',
        'Show about dialog',
        wxITEM_NORMAL,
        undef   # if defined, this is a sub-menu
    );
}

# # If you add a new menu to the bar, be sure to add its name to this list
# has 'menu_list' => (
#     is      => 'rw',
#     isa     => ArrayRef,
#     lazy    => 1,
#     default => sub { [ qw(
#                   menu_app
#                   menu_admin
#                   menu_help
#           ) ];
#     },
# );

sub _set_events {
    my $self = shift;
    EVT_MENU $self->parent, $self->item_about->GetId, sub{$self->OnAbout(@_)};
    EVT_MENU $self->parent, $self->item_help->GetId, sub{$self->OnHelp(@_)};
    return 1;
}

sub OnAbout {
    my $self  = shift;
    my $frame = shift;  # Wx::Frame
    my $event = shift;  # Wx::CommandEvent
    my $d = App::Sqitch::GUI::View::Dialog::About->new(
        app         => $self->app,
        ancestor    => $self,
        parent      => undef,
    );
    $d->show();
    return 1;
}

sub OnHelp {
    my $self  = shift;
    my $frame = shift;  # Wx::Frame
    my $event = shift;  # Wx::CommandEvent
    my $d = App::Sqitch::GUI::View::Dialog::Help->new(
        app         => $self->app,
        ancestor    => $self,
        parent      => undef,
    );
    return 1;
}

1;
