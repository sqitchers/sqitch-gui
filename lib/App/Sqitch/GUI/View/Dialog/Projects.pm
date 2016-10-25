package App::Sqitch::GUI::View::Dialog::Projects;

# ABSTRACT: The Projects Dialog

use 5.010;
use Moo;
use MooX::HandlesVia;
use App::Sqitch::GUI::Types qw(
    Dir
    HashRef
    Int
    Maybe
    Object
    SqitchGUIConfig
    SqitchGUIModel
    SqitchGUIModelListDataTable
    SqitchGUIWxListctrl
    SqitchGUIWxApp
    Str
    WxButton
    WxComboBox
    WxDirPickerCtrl
    WxGridSizer
    WxSizer
    WxStaticLine
    WxStaticText
    WxTextCtrl
    WxWindow
);
use Path::Class;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(:everything);
use Wx::Event qw(
    EVT_CLOSE
    EVT_BUTTON
    EVT_LIST_ITEM_SELECTED
    EVT_DIRPICKER_CHANGED
);
use App::Sqitch::X qw(hurl);

extends 'Wx::Dialog';

with qw(App::Sqitch::GUI::Roles::Element
        App::Sqitch::GUI::Roles::Panel);

use App::Sqitch::GUI::Wx::Listctrl;

has 'sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer',
);

sub _build_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

has 'vbox_sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_vbox_sizer',
);

sub _build_vbox_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

has 'h_line1' => (
    is      => 'ro',
    isa     => WxStaticLine,
    lazy    => 1,
    builder => '_build_h_line1',
);

sub _build_h_line1 {
    my $self = shift;
    return Wx::StaticLine->new(
        $self, -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

has 'h_line2' => (
    is      => 'ro',
    isa     => WxStaticLine,
    lazy    => 1,
    builder => '_build_h_line2',
);

sub _build_h_line2 {
    my $self = shift;
    return Wx::StaticLine->new(
        $self, -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );
}

has 'form_fg_sz' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_form_fg_sz',
);

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 4, 2, 6, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

has 'list_fg_sz' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_list_fg_sz',
);

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 5, 1, 0, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

has 'lbl_name' => (
    is      => 'ro',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_name',
);

sub _build_lbl_name {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Name' );
}

has 'txt_name' => (
    is      => 'ro',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_name',
);

sub _build_txt_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

has 'lbl_path' => (
    is      => 'ro',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_path',
);

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Project' );
}

has 'dpc_path' => (
    is      => 'ro',
    isa     => WxDirPickerCtrl,
    lazy    => 1,
    builder => '_build_dpc_path',
);

sub _build_dpc_path {
    my $self = shift;
    return Wx::DirPickerCtrl->new(
        $self, -1,
        q{},
        __ 'Choose a directory',
        [ -1, -1 ],
        [ -1, -1 ],
        wxDIRP_DIR_MUST_EXIST | wxDIRP_USE_TEXTCTRL | wxDIRP_CHANGE_DIR,
    );
}

has 'lbl_engine' => (
    is      => 'ro',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_engine',
);

sub _build_lbl_engine {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Engine' );
}

has 'cbx_engine' => (
    is      => 'ro',
    isa     => WxComboBox,
    lazy    => 1,
    builder => '_build_cbx_engine',
);

sub _build_cbx_engine {
    my $self = shift;
    my @engines = values %{$self->config->engine_list;};
    my $cbx = Wx::ComboBox->new(
        $self,
        -1,
        q{},
        [ -1,  -1 ],
        [ 170, -1 ],
        \@engines,
        wxCB_SORT | wxCB_READONLY,
    );
    return $cbx;
}

has 'lbl_db' => (
    is      => 'ro',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_db',
);

sub _build_lbl_db {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Database' );
}

has 'txt_db' => (
    is      => 'ro',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_db',
);

sub _build_txt_db {
    my $self = shift;
    return Wx::TextCtrl->new( $self, -1, q{}, [ -1, -1 ], [ -1, -1 ] );
}

has 'list_ctrl' => (
    is       => 'ro',
    isa      => SqitchGUIWxListctrl,
    required => 1,
    lazy     => 1,
    builder  => '_build_list_ctrl',
);

sub _build_list_ctrl {
    my $self = shift;
    my $list = App::Sqitch::GUI::Wx::Listctrl->new(
        app       => $self->app,
        parent    => $self,
        list_data => $self->list_data,
        meta_data => $self->model->project_dlg_list_meta_data,
    );
    return $list;
}

has 'btn_sizer' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer',
);

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

has 'btn_sizer_l' => (
    is      => 'ro',
    isa     => WxGridSizer,
    lazy    => 1,
    builder => '_build_btn_sizer_l',
);

sub _build_btn_sizer_l {
    return Wx::GridSizer->new(2, 3, 0, 0);
}

has 'btn_sizer_r' => (
    is      => 'ro',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer_r',
);

sub _build_btn_sizer_r {
    return Wx::BoxSizer->new(wxVERTICAL);
}

has 'btn_new' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_new',
);

sub _build_btn_new {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&New',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

has 'btn_add' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_add',
);

sub _build_btn_add {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Add',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

has 'btn_remove' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_remove',
);

sub _build_btn_remove {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Remove',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

has 'btn_close' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_close',
);

sub _build_btn_close {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Close',
        [ -1, -1 ],
        [ -1, -1 ],
    );
    return $button;
}

has 'btn_save' => (
    is      => 'ro',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_save',
);

sub _build_btn_save {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Save',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

#--  End interface definitions

has 'config' => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
    default => sub {
        shift->ancestor->config;
    },
);

has 'model' => (
    is      => 'ro',
    isa     => SqitchGUIModel,
    lazy    => 1,
    default => sub {
        shift->ancestor->model;
    },
);

has 'list_data' => (
    is       => 'ro',
    isa      => SqitchGUIModelListDataTable,
    required => 1,
    default => sub {
        my $self = shift;
        $self->model->project_list_data,
    },
);

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        __ 'Manage Projects List',
        [-1, -1],
        [-1, -1],
        wxRESIZE_BORDER | wxDEFAULT_DIALOG_STYLE,
    );
}

sub BUILD {
    my $self = shift;

    $self->SetMinSize([500, 500]);

    #-- List and buttons

    $self->sizer->Add( $self->vbox_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND | wxALL, 5 );

    $self->list_fg_sz->Add( $self->h_line1,    1, wxEXPAND | wxALL, 5 );
    $self->list_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL, 5 );
    $self->list_fg_sz->Add( $self->h_line2,    1, wxEXPAND | wxALL, 5 );

    $self->list_fg_sz->Add( $self->btn_sizer, 1, wxEXPAND | wxALL,  0 );

    $self->vbox_sizer->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 10 );

    $self->form_fg_sz->Add( $self->lbl_path,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->dpc_path,   1, wxEXPAND | wxRIGHT,5 );
    $self->form_fg_sz->Add( $self->lbl_name,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->txt_name,   0, wxLEFT,            0 );
    $self->form_fg_sz->Add( $self->lbl_engine, 0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->cbx_engine, 1, wxLEFT,            0 );
    $self->form_fg_sz->Add( $self->lbl_db,     0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->txt_db,     1, wxEXPAND | wxRIGHT,5 );

    $self->btn_sizer->Add( $self->btn_sizer_l, 1,
        wxEXPAND | wxLEFT | wxRIGHT, 35 );
    $self->btn_sizer->Add( $self->btn_sizer_r, 0, wxALL | wxALIGN_BOTTOM, 10 );

    $self->btn_sizer_l->Add( $self->btn_new,     1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_add,     1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_remove,  1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_save,    1, wxEXPAND | wxALL, 5 );

    $self->btn_sizer_r->Add( $self->btn_close, 1, wxEXPAND | wxALL, 0 );

    $self->SetSizer( $self->sizer );

    $self->list_ctrl->SetFocus;
    $self->_init_dialog;

    return $self;
}

sub set_button_status {
    my ($self, $state, $dlg_rules) = @_;
    foreach my $button (keys %{$dlg_rules} ) {
        my $enable = $dlg_rules->{$button};
        $self->$button->Enable($enable);
    }
    return;
}

sub get_state {
    my $self = shift;
    return $self->ancestor->dlg_status->get_state;
}

sub _set_events {
    my $self = shift;

    EVT_CLOSE $self, sub { $self->OnClose(@_) };

    EVT_BUTTON $self, $self->btn_close->GetId, sub {
        $self->OnClose(@_);
    };

    EVT_BUTTON $self, $self->btn_new->GetId, sub {
        $self->config_new_project;
    };

    EVT_BUTTON $self, $self->btn_add->GetId, sub {
        $self->config_add_project;
    };

    EVT_BUTTON $self, $self->btn_remove->GetId, sub {
        $self->config_remove_project;
    };

    EVT_BUTTON $self, $self->btn_save->GetId, sub {
        $self->config_save_project;
    };

    EVT_LIST_ITEM_SELECTED $self, $self->list_ctrl, sub {
        $self->_on_listitem_selected(@_);
    };

    EVT_DIRPICKER_CHANGED $self, $self->dpc_path->GetId, sub {
        $self->_on_dpc_change(@_);
    };

    return;
}

#--  End interface build

sub _init_dialog {
    my $self = shift;
    $self->ancestor->dlg_status->set_state('init');
    $self->list_ctrl->RefreshList;
    return;
}

sub init_form {
    my $self = shift;
    $self->control_write_e( $self->txt_name, undef );
    $self->control_write_e( $self->txt_db,   undef );
    $self->control_write_c( $self->cbx_engine, 'unknown' );
    return;
}

sub clear_form {
    my $self = shift;
    $self->control_write_p($self->dpc_path, '');
    $self->init_form;
    return;
}

sub _on_listitem_selected {
    my ($self, $var, $event) =  @_;
    return unless $self->get_state eq 'sele';

    my $item = $event->GetIndex;
    my $name = $self->list_data->get_value($item, 1);
    my $path = $self->list_data->get_value($item, 2);
    $self->clear_form;
    $self->load_item_details($name);
    return;
}

sub load_item_details {
    my ( $self, $name ) = @_;
    return unless $name;
    $self->control_write_e( $self->txt_name, $name );
    my $project = $self->model->get_project($name);
    if ( my $project = $self->model->get_project($name) ) {
        $self->control_write_p( $self->dpc_path, $project->{path} )
            if $project->{path};
        $self->control_write_c( $self->cbx_engine, $project->{engine} )
            if $project->{engine};
    }
    return;
}

sub dialog_info {
    my ( $self, $message, $details ) = @_;
    Wx::MessageBox( "$message\n\n$details", 'Info', wxOK | wxICON_INFORMATION,
        $self );
    return;
}

sub _on_dpc_change {
    my ($self, $frame, $event) = @_;
    if ( my $dir = $event->GetEventObject->GetPath ) {
        $self->_validate_path($dir);
    }
    return;
}

sub _validate_path {
    my ($self, $path) = @_;

    say "State is ", $self->get_state;
    if ( $self->get_state eq 'new' ) {
        unless ( $self->model->is_empty_path($path) ) {
            $self->dialog_info(
                "The selected path is not empty.",
                "$path\n\n Please, select or create another path." );
            return;
        }
    }
    if ( $self->get_state eq 'add' ) {
        unless ( $self->model->is_project_path($path) ) {
            $self->dialog_info(
                "The selected path doesn't look like a Sqitch project.",
                "Path: $path" );
            return;
        }
    }
    if ( $self->get_state ne 'sele' ) {
        if ( $self->is_duplicate_path($path) ) {
            $self->dialog_info("The selected path is a duplicate.", "Path: $path");
            return;
        }
    }

    $self->init_form;

    if ( my $engine = $self->model->get_project_engine_from_path($path) ) {
        $self->control_write_c( $self->cbx_engine, $engine );
    }

    # Default project name: the dir name
    my $name = $path->basename;
    $self->control_write_e($self->txt_name, $name);

    $self->btn_save->Enable(1);
    return;
}

sub is_duplicate_path {
    my ( $self, $path ) = @_;
    my $rezult = 0;
    for my $rec ( $self->model->projects ) {
        if ( $rec->[1]{path}->stringify eq $path->stringify ) {
            $rezult = 1;
            last;
        }
    }
    return $rezult;
}

sub set_message {
    my ($self, $mesg) = @_;
    my $busy = Wx::BusyInfo->new($mesg);
    $self->app->Yield;          # no text without this
    Wx::Sleep(3);               # not very nice...
    $busy = undef;
    return;
}

sub config_new_project {
    my $self = shift;
    my $state = $self->get_state;
    if ( $state eq 'sele' ) {
        $self->clear_form;
        $self->btn_new->SetLabel( __ 'C&ancel' );
        $self->ancestor->dlg_status->set_state('new');
        $self->list_ctrl->Enable(1);
        $self->add_empty_list_item;
        $self->list_ctrl->set_selection('last');
        $self->list_ctrl->Enable(0);
        $self->btn_save->Enable(0);

        $self->dir_dialog;
        $self->cbx_engine->Enable(1);
    }
    elsif ( $state eq 'new' ) {
        $self->btn_new->SetLabel( __ '&New' );
        $self->ancestor->dlg_status->set_state('sele');
        $self->list_ctrl->delete_current_item;
        $self->list_ctrl->Enable(1);
        $self->clear_form;
    }
    return;
}

sub config_add_project {
    my $self = shift;
    my $state = $self->get_state;
    if ( $state eq 'sele' ) {
        $self->clear_form;
        $self->btn_add->SetLabel( __ 'C&ancel' );
        $self->ancestor->dlg_status->set_state('add');
        $self->list_ctrl->Enable(1);
        $self->add_empty_list_item;
        $self->list_ctrl->set_selection('last');
        $self->list_ctrl->Enable(0);
        $self->btn_save->Enable(0);
    }
    elsif ( $state eq 'add' ) {
        $self->btn_add->SetLabel( __ '&Add' );
        $self->ancestor->dlg_status->set_state('sele');
        $self->list_ctrl->delete_current_item;
        $self->list_ctrl->Enable(1);
        $self->clear_form;
    }
    return;
}

sub config_remove_project {
    my $self = shift;
    my $item = $self->list_ctrl->get_selection;
    my $name = $self->list_data->get_value($item, 1);
    say "Removing $name";
    unless ($name) {
        $self->set_message(__ 'Select an item, please.');
        return;
    }
    my $default    = $self->config->default_project_name;
    my $is_default = $name eq $default ? 1 : 0;
    $self->ancestor->config_remove_project($name, $is_default);
    $self->list_ctrl->delete_current_item;
    return;
}

sub config_save_project {
    my $self = shift;

    my $name = $self->control_read_e($self->txt_name);
    my $path = $self->control_read_p($self->dpc_path);

    # Save in user config
    $self->ancestor->config_edit_project( $name, $path );

    my $engine_name = $self->control_read_c( $self->cbx_engine );
    my $params      = {
        name   => $name,
        path   => $path,
        engine => $engine_name,
    };
    $self->btn_new->SetLabel( __ '&Add' );
    $self->ancestor->dlg_status->set_state('sele');

    $self->_edit_list_item( $self->list_ctrl->get_selection, $params );

    return;
}

sub add_empty_list_item {
    my $self = shift;
    my $row_count = $self->list_ctrl->get_item_count;
    $self->list_data->add_row($row_count + 1, '<name>', '<path>');
    $self->list_ctrl->RefreshList;
    return;
}

sub _edit_list_item {
    my ($self, $item, $params) = @_;
    $self->list_ctrl->Enable(0);
    $item //= $self->list_ctrl->get_selection;
    $self->list_data->set_value( $item, 1, $params->{name} );
    $self->list_data->set_value( $item, 2, $params->{path} );
    $self->list_data->set_value( $item, 3, $params->{engine} );
    $self->list_data->set_value( $item, 4, '' ); # default
    $self->list_data->set_value( $item, 5, '' ); # current
    $self->list_ctrl->RefreshList;
    $self->list_ctrl->Enable(1);
    return;
}

sub OnClose {
    my ($self, $dialog, $event) = @_;
    $self->EndModal(wxID_OK);
    $self->Destroy;
    return;
}

sub dir_dialog {
    my $self = shift;
    my $dialog = Wx::DirDialog->new($self);
    if ( $dialog->ShowModal == wxID_CANCEL ) {
        Wx::LogMessage("User cancelled the dialog");
    }
    else {
        if ( my $dir = $dialog->GetPath ) {
            $self->control_write_p( $self->dpc_path, $dir );
            $self->_validate_path($dir);
        }
    }
    $dialog->Destroy;
}

1;

__END__

=encoding utf8

=head1 DESCRIPTION

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 C<plan>

=head1 METHODS

=head2 <load_item_details>

Load info for the selected list item.  Can't use the current Sqitch
configuration for this, for every item (project) we have to load
the local configuration file and get the required info from there.

=cut
