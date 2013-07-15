package App::Sqitch::GUI::MainFrame::Notebook;

use Moose;
use Wx qw(:everything);
use Wx::Event qw();
use Wx::AUI;

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;
extends 'Wx::AuiNotebook';

has 'page_deploy' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'page_revert' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'page_verify' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );

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

sub BUILD { shift };

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

no Moose;
__PACKAGE__->meta->make_immutable;


1;
