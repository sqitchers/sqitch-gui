package App::Sqitch::GUI::MainFrame::Notebook;

use Moose;
use Wx qw(:everything);
use Wx::AUI;
use Wx::Event qw();

with 'App::Sqitch::GUI::Roles::Element';

has 'notebook' => (is => 'rw', isa => 'Wx::AuiNotebook', lazy_build => 1);
has 'page_p1'  => (is => 'rw', isa => 'Wx::Panel', lazy_build => 1);
has 'page_p2'  => (is => 'rw', isa => 'Wx::Panel', lazy_build => 1);
has 'page_p3'  => (is => 'rw', isa => 'Wx::Panel', lazy_build => 1);

sub BUILD {
    my $self = shift;
    $self->notebook;
    return $self;
};

sub _build_notebook {
    my $self = shift;

    my $nb = Wx::AuiNotebook->new(
        $self->parent,
        -1,
        [-1, -1],
        [-1, -1],
        wxAUI_NB_TAB_FIXED_WIDTH,
    );

    return $nb;
}

sub _build_page_p1 {
    my $self = shift;
    my $p1 = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->notebook->AddPage( $p1, 'Deploy' );
    return $p1;
}

sub _build_page_p2 {
    my $self = shift;
    my $p2 = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->notebook->AddPage( $p2, 'Revert' );
    return $p2;
}

sub _build_page_p3 {
    my $self = shift;
    my $p3 = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->notebook->AddPage( $p3, 'Verify' );
    return $p3;
}

sub _set_events { }

no Moose;
__PACKAGE__->meta->make_immutable; 


1;
