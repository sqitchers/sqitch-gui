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

use vars qw(@ISA); @ISA = qw(Wx::Timer);

sub Notify {
    my $self  = shift;
    my $frame = Wx::wxTheApp()->GetTopWindow;
    $frame->Destroy;
    main::ok( 1, "ListCtrl instance destroyed" );
}

package TestApp;

use strict;
use warnings;

use Wx qw(:everything);
use Wx::Event;
use base 'Wx::App';

use App::Sqitch::GUI::Model::ListDataTable;
use App::Sqitch::GUI::Wx::Listctrl;

sub list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 25,
            type  => 'int',
        },
        {   field => 'name',
            label => 'Name',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'path',
            label => 'Path',
            align => 'left',
            width => 266,
            type  => 'bool',
        },
    ];
}

sub OnInit {
    my $self = shift;

    my $frame = $self->{frame} = Wx::Frame->new( undef, -1, 'Test!', );

    my $list_data = App::Sqitch::GUI::Model::ListDataTable->new;

    my $list_ctrl = App::Sqitch::GUI::Wx::Listctrl->new(
        app       => undef,
        parent    => $frame,
        list_data => $list_data,
        meta_data => list_meta_data(),
    );

    main::ok( $list_ctrl, 'Listctrl instance created' );

    # Fill the table
    foreach my $iter ( 1..5 ) {
        main::ok( $list_data->add_row( $iter, "Name $iter", "Path $iter" ),
            "add row: $iter" );
        $list_ctrl->RefreshList;
    }
    # print "Data:\n", $list_data->get_data, "\n";

    # Delete even items
    main::ok $list_data->remove_row(1), "remove row 2";
    main::ok $list_data->remove_row(2), "remove row 4";
    $list_ctrl->RefreshList;
    # print "Data:\n", $list_data->get_data, "\n";
    main::is $list_data->get_item_count, 3, 'item count: 3 values';

    # Uncomment this to observe the test
    #$frame->Show(1) if $ENV{DISPLAY};

    MyTimer->new->Start( 500, 1 );

    return 1;
}

# Create the application object, and pass control to it.
package main;
my $app = TestApp->new;
$app->MainLoop;

done_testing;
