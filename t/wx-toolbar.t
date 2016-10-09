#
# Inspired from the tests of the Wx-Scintilla module,
# Copyright (C) 2011 Ahmad M. Zawawi,
# the MyTimer package is copied verbatim.
#
use strict;
use warnings;

use Test::More;

BEGIN {
    unless ( $ENV{DISPLAY} or $^O eq 'MSWin32' ) {
        plan skip_all => 'Needs DISPLAY';
        exit 0;
    }
    eval { require Wx; };
    if ($@) {
        plan( skip_all => 'wxPerl is required for this test' );
    }
}

package MyTimer;

use Wx qw(:everything);
use Wx::Event;

use base qw(Wx::Timer);

sub Notify {
    my $self  = shift;
    my $frame = Wx::wxTheApp()->GetTopWindow;
    $frame->Destroy;
    main::ok( 1, "Toolbar instance destroyed" );
}

package TestApp;

use strict;
use warnings;

use Path::Class;
use Wx qw(:everything);
use Wx::Event;
use base 'Wx::App';

use App::Sqitch::GUI::Config::Toolbar;
use App::Sqitch::GUI::Wx::Toolbar;

sub OnInit {
    my $self = shift;

    my $frame = Wx::Frame->new( undef, -1, 'Test!', );

    # Tool Bar
    my $conf = App::Sqitch::GUI::Config::Toolbar->new;
    main::ok( $conf, 'new Toolbar config instance' );

    main::ok my @toolbars = $conf->all_buttons, 'all buttons attributes';

    main::ok my $tb = App::Sqitch::GUI::Wx::Toolbar->new(
        app       => undef,
        ancestor  => $self,
        parent    => $frame,
        icon_path => dir('share', 'etc', 'icons'),
    ), 'new Toolbar instance';

    foreach my $name (@toolbars) {
        my $attribs = $conf->get_tool($name);
        $tb->make_toolbar_button( $name, $attribs );
    }
    $tb->set_initial_mode( \@toolbars );

    $frame->SetToolBar($tb);



    # Uncomment this to observe the test
    # $frame->Show(1) if $ENV{DISPLAY};

    MyTimer->new->Start( 500, 1 );

    return 1;
}

# Create the application object, and pass control to it.
package main;

my $app = TestApp->new;
$app->MainLoop;

done_testing;
