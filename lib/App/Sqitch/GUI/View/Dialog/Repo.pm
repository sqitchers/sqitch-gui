package App::Sqitch::GUI::View::Dialog::Repo;

use Moose;
use namespace::autoclean;
use Try::Tiny;

use Wx qw(:everything);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON);
use Wx::Perl::ListCtrl;

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;

extends 'Wx::Dialog';

has 'sizer'      => ( is => 'rw', isa => 'Wx::Sizer',  lazy_build => 1 );
has 'vbox_sizer' => ( is => 'rw', isa => 'Wx::Sizer',  lazy_build => 1 );

has 'h_line1' => ( is => 'rw', isa => 'Wx::StaticLine',  lazy_build => 1 );
has 'h_line2' => ( is => 'rw', isa => 'Wx::StaticLine',  lazy_build => 1 );

has 'form_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'list_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'lbl_name' => ( is => 'rw', isa => 'Wx::StaticText',    lazy_build => 1 );
has 'txt_name' => ( is => 'rw', isa => 'Wx::TextCtrl',      lazy_build => 1 );
has 'lbl_path' => ( is => 'rw', isa => 'Wx::StaticText',    lazy_build => 1 );
has 'dpc_path' => ( is => 'rw', isa => 'Wx::DirPickerCtrl', lazy_build => 1 );
has 'lbl_driver' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'cbx_driver' => ( is => 'rw', isa => 'Wx::ComboBox',   lazy_build => 1 );

has 'repo_list' => ( is => 'rw', isa => 'Wx::Perl::ListCtrl', lazy_build => 1 );

has 'btn_sizer'   => ( is => 'rw', isa => 'Wx::Sizer',  lazy_build => 1 );
has 'btn_load'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_default' => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_add'     => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_exit'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );

sub FOREIGNBUILDARGS {
    my $self = shift;

    my %args = @_;

    return (
        $args{parent},
        -1,
        'Repository List',
        [-1, -1],
        [-1, -1],
        wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE,
    );
}

sub BUILD {
    my $self = shift;

    $self->SetMinSize([500, 400]);

    #-- List and buttons

    $self->sizer->Add( $self->vbox_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->list_fg_sz->Add( $self->repo_list,  1, wxEXPAND | wxALL, 5 );
    $self->list_fg_sz->Add( $self->h_line1,     1, wxEXPAND | wxALL, 10 );
    $self->list_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL, 5 );
    $self->list_fg_sz->Add( $self->h_line2,     1, wxEXPAND | wxALL, 10 );
    $self->list_fg_sz->Add( $self->btn_sizer,  1, wxALIGN_CENTRE,   0 );

    $self->vbox_sizer->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 10 );

    $self->form_fg_sz->Add( $self->lbl_path,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->dpc_path,   1, wxEXPAND | wxLEFT, 0 );
    $self->form_fg_sz->Add( $self->lbl_name,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->txt_name,   1, wxEXPAND | wxLEFT, 0 );
    $self->form_fg_sz->Add( $self->lbl_driver, 0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->cbx_driver, 1, wxLEFT,            0 );

    $self->btn_sizer->Add( $self->btn_load,    1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_default, 1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_add,     1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_exit,    1, wxEXPAND | wxALL, 15 );

    $self->SetSizer( $self->sizer );

    return $self;
}

sub _build_vbox_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

#-- Form

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 3, 2, 6, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_lbl_name {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, q{Name} );
}

sub _build_txt_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, q{Repository} );
}

sub _build_dpc_path {
    my $self = shift;

    return Wx::DirPickerCtrl->new(
        $self, -1, q{},
        q{Choose a directory},
        [ -1, -1 ],
        [ -1, -1 ],
        wxDIRP_DIR_MUST_EXIST | wxDIRP_USE_TEXTCTRL | wxDIRP_CHANGE_DIR,
    );
}

sub _build_lbl_driver {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, q{Driver} );
}

sub _build_cbx_driver {
    my $self = shift;
    my @engines = qw{cucu mucu};
    return Wx::ComboBox->new(
        $self,
        -1,
        q{},
        [ -1,  -1 ],
        [ 170, -1 ],
        \@engines,
        wxCB_SORT | wxCB_READONLY,
    );
}

#-  List and buttons

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 3, 1, 0, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_btn_load {
    my $self = shift;

    my $button = Wx::Button->new(
        $self,
        -1,
        q{Load},
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_btn_default {
    my $self = shift;

    my $button = Wx::Button->new(
        $self,
        -1,
        q{Default},
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_btn_add {
    my $self = shift;

    my $button = Wx::Button->new(
        $self,
        -1,
        q{Add},
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_btn_exit {
    my $self = shift;

    my $button = Wx::Button->new(
        $self,
        -1,
        q{E&xit},
        [ -1, -1 ],
        [ -1, -1 ],
    );

    return $button;
}

sub _build_repo_list {
    my $self = shift;

    my $list = Wx::Perl::ListCtrl->new(
        $self, -1,
        [ -1, -1 ],
        [ -1, -1 ],
        Wx::wxLC_REPORT | Wx::wxLC_SINGLE_SEL,
    );

    $list->InsertColumn( 0, '#', wxLIST_FORMAT_LEFT, 50 );
    $list->InsertColumn( 1, 'Name', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 2, 'Path', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 3, 'Default', wxLIST_FORMAT_LEFT, 60 );
    $list->InsertColumn( 4, 'Description', wxLIST_FORMAT_LEFT, 180 );

    return $list;
}

sub _build_h_line1 {
    my $self = shift;
    return Wx::StaticLine->new(
        $self, -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _build_h_line2 {
    my $self = shift;
    return Wx::StaticLine->new(
        $self, -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

sub _set_events {
    my $self = shift;

    EVT_CLOSE $self, sub { $self->OnClose(@_) };

    EVT_BUTTON $self, $self->btn_exit->GetId, sub {
        $self->OnClose(@_);
    };

    return;
}

sub OnClose {
    my ($self, $dialog, $event) = @_;
    print "Closing dialog...\n";
    $self->EndModal(wxID_CANCEL);
    $self->Destroy;
    return;
}

__PACKAGE__->meta->make_immutable;

1;
