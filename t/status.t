use 5.010;
use strict;
use warnings;
use Test::Most;

use App::Sqitch::GUI;
use App::Sqitch::GUI::Refresh;
use App::Sqitch::GUI::View::Dialog::Refresh;

ok my $app = App::Sqitch::GUI->new, 'new GUI';

ok my $ctrl = $app->controller, 'get the controller';
isa_ok $ctrl, 'App::Sqitch::GUI::Controller', 'controller';

ok my $view = $ctrl->view, 'get the view';
isa_ok $view, 'App::Sqitch::GUI::View', 'view';

my $dialog = App::Sqitch::GUI::View::Dialog::Projects->new(
    app       => $ctrl->app,
    ancestor  => $ctrl,
    parent    => undef,                  # undef for dialogs
);

subtest 'GUI Status' => sub {

    use_ok 'App::Sqitch::GUI::Status';

    can_ok 'App::Sqitch::GUI::Status', qw(
        set_state
        get_state
        is_state
    );

    ok my $status = App::Sqitch::GUI::Status->new, 'new GUI status instance';
    isa_ok $status, 'App::Sqitch::GUI::Status', 'GUI status';

    ok my $gui_ref = App::Sqitch::GUI::Refresh->new( view => $view ),
        'new GUI refresh instance';
    isa_ok $gui_ref, 'App::Sqitch::GUI::Refresh', 'GUI refresh';

    ok $status->add_observer( $gui_ref ), 'add observer';

    for my $state (qw(edit idle init load)) {
        ok $status->set_state($state), "set state $state";
        is $status->get_state, $state, "get state ($state)";
        ok $status->is_state($state), "is state $state";
    }

    throws_ok { $status->set_state('unknown') }
        qr/\QValue "unknown" did not pass type constraint "Enum[edit,idle,init,load]"/,
        qq{'unknown' should not be a valid mode};

};

subtest 'GUI Dialog Status' => sub {

    use_ok 'App::Sqitch::GUI::View::Dialog::Status';

    can_ok 'App::Sqitch::GUI::View::Dialog::Status', qw(
        set_state
        get_state
        is_state
    );

    ok my $status = App::Sqitch::GUI::View::Dialog::Status->new, 'new GUI status instance';
    isa_ok $status, 'App::Sqitch::GUI::View::Dialog::Status', 'GUI dialog status';

    ok my $gui_ref = App::Sqitch::GUI::View::Dialog::Refresh->new( dialog => $dialog ),
        'new GUI refresh instance';
    isa_ok $gui_ref, 'App::Sqitch::GUI::View::Dialog::Refresh', 'GUI dialog refresh';

    ok $status->add_observer( $gui_ref ), 'add observer';

    for my $state (qw(add edit idle init sele)) {
        ok $status->set_state($state), "set state $state";
        is $status->get_state, $state, "get state ($state)";
        ok $status->is_state($state), "is state $state";
    }

    throws_ok { $status->set_state('unknown') }
        qr/\QValue "unknown" did not pass type constraint "Enum[add,edit,idle,init,new,sele]"/,
        qq{'unknown' should not be a valid mode};

};


done_testing;
