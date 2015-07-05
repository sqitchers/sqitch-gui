package App::Sqitch::GUI::Wx::Notebook;

# ABSTRACT: Wx Notebook Control

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxPanel
    WxSizer
    WxCollapsiblePane
    WxStaticText
    WxTextCtrl
    SqitchGUIWxNotebook
    SqitchGUIWxEditor
);
use Wx qw(:everything);
use Wx::Event qw();
use Wx::AUI;

with 'App::Sqitch::GUI::Roles::Element';

extends 'Wx::AuiNotebook';

has 'page_deploy' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_deploy',
);

has 'page_revert' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_revert',
);

has 'page_verify' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_verify',
);


sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [-1, -1],
        [-1, -1],
        wxAUI_NB_TAB_FIXED_WIDTH,
    );
}

sub BUILD {
    my $self = shift;
    return $self;
};

sub _build_page_deploy {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Deploy' );
    return $page;
}

sub _build_page_revert {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Revert' );
    return $page;
}

sub _build_page_verify {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Verify' );
    return $page;
}

sub _set_events { }

1;
