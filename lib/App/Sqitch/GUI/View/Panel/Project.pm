package App::Sqitch::GUI::View::Panel::Project;

use utf8;
use Moose;
use namespace::autoclean;

use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE EVT_DIRPICKER_CHANGED);
use Wx::Perl::ListCtrl;

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'btn_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'sb_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'main_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'list_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'form_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'subform1_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'subform2_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'list' => ( is => 'rw', isa => 'Wx::Perl::ListCtrl', lazy_build => 1 );

has 'btn_load'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_default' => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_add'     => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );

has 'lbl_project'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_database' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_user'     => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_uri'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_created_at'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_creator_name'  => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_creator_email' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_path' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'lbl_db'   => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );

has 'txt_project'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_database' => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_user'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_uri'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_created_at'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_creator_name'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'txt_creator_email'  => ( is => 'rw', isa => 'Wx::TextCtrl', lazy_build => 1 );
has 'dpc_path'  => ( is => 'rw', isa => 'Wx::DirPickerCtrl', lazy_build => 1 );
has 'cb_driver'    => ( is => 'rw', isa => 'Wx::ComboBox',      lazy_build => 1 );
has 'engines' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default => sub {
        return {
            pg     => 'PostgreSQL',
            mysql  => 'MySQL',
            sqlite => 'SQLite',
            cubrid => 'CUBRID',
            oracle => 'Oracle',
        };
    },
);

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL, 5 );
    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- Top form

    $self->form_fg_sz->Add( $self->lbl_project, 0, wxLEFT, 5 );
    $self->subform1_fg_sz->Add( $self->txt_project, 1, wxLEFT, 0 );
    $self->subform1_fg_sz->Add( $self->lbl_db, 0, wxLEFT, 50 );
    $self->subform1_fg_sz->Add( $self->cb_driver, 0, wxLEFT, 20 );
    $self->form_fg_sz->Add( $self->subform1_fg_sz, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_database, 0, wxLEFT, 5 );
    $self->subform2_fg_sz->Add( $self->txt_database, 1, wxLEFT, 0 );
    $self->subform2_fg_sz->Add( $self->lbl_user, 0, wxLEFT, 53 );
    $self->subform2_fg_sz->Add( $self->txt_user, 1, wxEXPAND | wxLEFT, 20 );
    $self->form_fg_sz->Add( $self->subform2_fg_sz, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_path, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->dpc_path, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_uri, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_uri, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_created_at, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_created_at, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_creator_name, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_creator_name, 1, wxEXPAND | wxLEFT, 0 );

    $self->form_fg_sz->Add( $self->lbl_creator_email, 0, wxLEFT, 5 );
    $self->form_fg_sz->Add( $self->txt_creator_email, 1, wxEXPAND | wxLEFT, 0 );

    #-- List and buttons

    $self->list_fg_sz->Add( $self->list, 1, wxEXPAND, 3 );

    $self->btn_sizer->Add( $self->btn_load, 1, wxLEFT | wxRIGHT | wxEXPAND,
        25 );
    $self->btn_sizer->Add( $self->btn_default, 1,
        wxLEFT | wxRIGHT | wxEXPAND, 25 );
    $self->btn_sizer->Add( $self->btn_add, 1, wxLEFT | wxRIGHT | wxEXPAND,
        25 );

    $self->list_fg_sz->Add( $self->btn_sizer, 1, wxALIGN_CENTRE);

    $self->panel->SetSizer($self->sizer);

    return $self;
}

sub _build_panel {
    my $self = shift;

    my $panel = Wx::Panel->new(
        $self->parent,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxFULL_REPAINT_ON_RESIZE,
        'projectPanel',
    );
    #$panel->SetBackgroundColour( Wx::Colour->new('green') );

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(1);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

#-  Form

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 7, 2, 6, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_subform1_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 3, 0, 0 );
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_subform2_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 3, 0, 0 );
    $fgs->AddGrowableCol(0);
    return $fgs;
}

#-- Labels

sub _build_lbl_project {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Project} );
}

sub _build_lbl_database {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Database} );
}

sub _build_lbl_user {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{User} );
}

sub _build_lbl_uri {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{URI} );
}

sub _build_lbl_created_at {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Created at} );
}

sub _build_lbl_creator_name {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Creator name} );
}

sub _build_lbl_creator_email {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Creator email} );
}

sub _build_lbl_db {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Driver} );
}

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self->panel, -1, q{Repository} );
}

#-- Entry

sub _build_txt_project {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_database {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_user {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_uri {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_created_at {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_creator_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_txt_creator_email {
    my $self = shift;
    return Wx::TextCtrl->new( $self->panel, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_dpc_path {
    my $self = shift;

    return Wx::DirPickerCtrl->new(
        $self->panel, -1, q{},
        q{Choose a directory},
        [ -1, -1 ],
        [ -1, -1 ],
        wxDIRP_DIR_MUST_EXIST | wxDIRP_USE_TEXTCTRL,
    );
}

sub _build_cb_driver {
    my $self = shift;
    my @engines = values %{$self->engines};
    return Wx::ComboBox->new(
        $self->panel,
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
    my $fgs = Wx::FlexGridSizer->new( 2, 0, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, ' Project ', ), wxVERTICAL );
}

sub _build_btn_load {
    my $self = shift;

    my $button = Wx::Button->new(
        $self->panel,
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
        $self->panel,
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
        $self->panel,
        -1,
        q{Add},
        [ -1, -1 ],
        [ -1, -1 ],
    );
    $button->Enable(0);

    return $button;
}

sub _build_list {
    my $self = shift;

    my $list = Wx::Perl::ListCtrl->new(
        $self->panel, -1,
        [ -1, -1 ],
        [ -1, -1 ],
        Wx::wxLC_REPORT | Wx::wxLC_SINGLE_SEL,
    );

    $list->InsertColumn( 0, '#', wxLIST_FORMAT_LEFT, 50 );
    $list->InsertColumn( 1, 'Project', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 2, 'Database', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 3, 'Default', wxLIST_FORMAT_LEFT, 60 );
    $list->InsertColumn( 4, 'Description', wxLIST_FORMAT_LEFT, 180 );

    return $list;
}

sub _set_events {
    my ($self, $event) = @_;

    EVT_DIRPICKER_CHANGED $self->panel, $self->dpc_path->GetId, sub {
        $self->on_dpc_change;
    };
}

sub on_dpc_change {
    print "Path changed\n";
}

sub OnClose {
    my ($self, $event) = @_;
}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

None known.

Please report any bugs or feature requests to the author.

=head1 ACKNOWLEDGMENTS

GUI with Wx and Moose heavily inspired/copied from the LacunaWaX
project:

https://github.com/tmtowtdi/LacunaWaX

Copyright: Jonathan D. Barton 2012-2013

Thank you!

=head1 LICENSE AND COPYRIGHT

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::Panel::Project
