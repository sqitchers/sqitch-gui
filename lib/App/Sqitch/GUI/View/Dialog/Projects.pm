package App::Sqitch::GUI::View::Dialog::Projects;

use 5.010;
use strict;
use warnings;
use Moo;
use MooX::HandlesVia;
use App::Sqitch::GUI::Types qw(
    Dir
    HashRef
    Int
    Maybe
    Object
    SqitchGUIConfig
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

with 'App::Sqitch::GUI::Roles::Element';

use App::Sqitch::GUI::Model::ListDataTable;
use App::Sqitch::GUI::Wx::Listctrl;

has 'sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_sizer',
);

sub _build_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

has 'vbox_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_vbox_sizer',
);

has 'h_line1' => (
    is      => 'rw',
    isa     => WxStaticLine,
    lazy    => 1,
    builder => '_build_h_line1',
);

has 'h_line2' => (
    is      => 'rw',
    isa     => WxStaticLine,
    lazy    => 1,
    builder => '_build_h_line2',
);

has 'form_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_form_fg_sz',
);

has 'list_fg_sz' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_list_fg_sz',
);

has 'lbl_name' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_name',
);

has 'txt_name' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_name',
);

has 'lbl_path' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_path',
);

has 'dpc_path' => (
    is      => 'rw',
    isa     => WxDirPickerCtrl,
    lazy    => 1,
    builder => '_build_dpc_path',
);

has 'lbl_engine' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_engine',
);

has 'cbx_engine' => (
    is      => 'rw',
    isa     => WxComboBox,
    lazy    => 1,
    builder => '_build_cbx_engine',
);

has 'lbl_db' => (
    is      => 'rw',
    isa     => WxStaticText,
    lazy    => 1,
    builder => '_build_lbl_db',
);

has 'txt_db' => (
    is      => 'rw',
    isa     => WxTextCtrl,
    lazy    => 1,
    builder => '_build_txt_db',
);

has 'list_ctrl' => (
    is       => 'rw',
    isa      => SqitchGUIWxListctrl,
    required => 1,
    lazy     => 1,
    builder  => '_build_list_ctrl',
);

has 'btn_sizer' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer',
);

has 'btn_sizer_l' => (
    is      => 'rw',
    isa     => WxGridSizer,
    lazy    => 1,
    builder => '_build_btn_sizer_l',
);

has 'btn_sizer_r' => (
    is      => 'rw',
    isa     => WxSizer,
    lazy    => 1,
    builder => '_build_btn_sizer_r',
);

has 'btn_new' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_new',
);

has 'btn_edit' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_edit',
);

has 'btn_remove' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_remove',
);

has 'btn_load' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_load',
);

has 'btn_default' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_default',
);

has 'btn_close' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_close',
);

has 'btn_save' => (
    is      => 'rw',
    isa     => WxButton,
    lazy    => 1,
    builder => '_build_btn_save',
);

has 'selected_item' => (
    is      => 'rw',
    isa     => Maybe[Int],
    default => sub { undef },
);

has 'selected_name' => (
    is      => 'rw',
    isa     => Maybe[Str],
    default => sub { undef },
);

has 'selected_path' => (
    is      => 'rw',
    isa     => Maybe[Dir],
    default => sub { undef },
);

has config => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
    default => sub {
        shift->ancestor->config;
    },
);

has 'project_list' => (
    is          => 'rw',
    handles_via => 'Hash',
    lazy        => 1,
    default     => sub {
        my $self = shift;
        return $self->config->project_list;
    },
    handles => {
        get_repo   => 'get',
        has_repo   => 'count',
        repo_pairs => 'kv',
    }
);

has 'list_data' => (
    is      => 'ro',
    default => sub {
        return App::Sqitch::GUI::Model::ListDataTable->new;
    },
);

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        __ 'Project List',
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
    $self->btn_sizer_l->Add( $self->btn_edit,    1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_remove,  1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_load,    1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_default, 1, wxEXPAND | wxALL, 5 );
    $self->btn_sizer_l->Add( $self->btn_save,    1, wxEXPAND | wxALL, 5 );

    $self->btn_sizer_r->Add( $self->btn_close, 1, wxEXPAND | wxALL, 0 );

    $self->SetSizer( $self->sizer );

    $self->_init;

    $self->list_ctrl->SetFocus;

    return $self;
}

sub set_status {
    my ($self, $state, $dlg_rules) = @_;

    foreach my $btn (keys %{$dlg_rules} ) {
        my $enable = $dlg_rules->{$btn};
        $self->$btn->Enable($enable);
    }

    return;
}

sub get_state {
    my $self = shift;
    return $self->ancestor->dlg_status->get_state;
}

sub _build_vbox_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_btn_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_btn_sizer_l {
    return Wx::GridSizer->new(2, 3, 0, 0);
}

sub _build_btn_sizer_r {
    return Wx::BoxSizer->new(wxVERTICAL);
}

#-- Form

sub _build_form_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 4, 2, 6, 10 );
    $fgs->AddGrowableCol(1);
    return $fgs;
}

sub _build_lbl_name {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Name' );
}

sub _build_txt_name {
    my $self = shift;
    return Wx::TextCtrl->new( $self, -1, q{}, [ -1, -1 ], [ 170, -1 ] );
}

sub _build_lbl_path {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Project' );
}

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

sub _build_lbl_engine {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Engine' );
}

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

sub _build_lbl_db {
    my $self = shift;
    return Wx::StaticText->new( $self, -1, __ 'Database' );
}

sub _build_txt_db {
    my $self = shift;
    return Wx::TextCtrl->new( $self, -1, q{}, [ -1, -1 ], [ -1, -1 ] );
}

#-  Buttons

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 5, 1, 0, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_btn_load {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Load',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

sub _build_btn_default {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Default',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

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

sub _build_btn_edit {
    my $self = shift;
    my $button = Wx::Button->new(
        $self,
        -1,
        __ '&Edit',
        [ -1, -1 ],
        [ -1, -1 ],
        wxBU_EXACTFIT,
    );
    return $button;
}

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

sub _build_list_ctrl {
    my $self = shift;

    my $list = App::Sqitch::GUI::Wx::Listctrl->new(
        app       => $self->app,
        parent    => $self,
        list_data => $self->list_data,
        meta_data => $self->list_meta_data,

        # count_col => 1,                      # add a count column XXX
    );

    return $list;
}

#-- Lines

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

    EVT_BUTTON $self, $self->btn_close->GetId, sub {
        $self->OnClose(@_);
    };

    EVT_BUTTON $self, $self->btn_load->GetId, sub {
        $self->ancestor->config_reload(
            $self->selected_name,
            $self->selected_path,
        );
        $self->OnClose(@_);
    };

    EVT_BUTTON $self, $self->btn_default->GetId, sub {
        $self->config_set_default;
    };

    EVT_BUTTON $self, $self->btn_new->GetId, sub {
        $self->config_new_repo;
    };

    EVT_BUTTON $self, $self->btn_edit->GetId, sub {
        $self->config_edit_repo;
    };

    EVT_BUTTON $self, $self->btn_remove->GetId, sub {
        $self->config_remove_repo;
    };

    EVT_BUTTON $self, $self->btn_save->GetId, sub {
        $self->config_save_repo;
    };

    EVT_LIST_ITEM_SELECTED $self, $self->list_ctrl, sub {
        $self->_on_item_selected(@_);
    };

    EVT_DIRPICKER_CHANGED $self, $self->dpc_path->GetId, sub {
        $self->_on_dpc_change(@_);
    };

    return;
}

#---

sub _init {
    my $self = shift;

    # Populate list
    my $records_ref = [];
    for my $pair ( $self->repo_pairs ) {
        push @{$records_ref}, { name => $pair->[0], path => $pair->[1] };
    }
    $self->populate($records_ref);

    # Default from config
    my $repo_default = $self->config->repo_default_name;
    my $index;
    if ($repo_default) {
        $index = 0;
        foreach my $rec ( @{$records_ref} ) {
            last if $repo_default eq $rec->{name};
            $index++;
        }
        $self->_mark_as_default($index);
        $self->list_ctrl->set_selection($index);
        $self->_select_item($index);
        $self->_load_selected_item($index);
    }

    $self->ancestor->dlg_status->set_state('init');

    return;
}

sub populate {
    my ($self, $record_ref) = @_;

    my $data_table = $self->list_data;
    my $cols_meta  = $self->list_meta_data;
    my $row        = ( $data_table->get_item_count // 1 ) - 1;
    foreach my $rec ( @{$record_ref} ) {
        my $col = 0;
        foreach my $meta ( @{$cols_meta} ) {
            my $field = $meta->{field};
            my $value
                = $field eq q{}     ? q{}
                : $field eq 'recno' ? ( $row + 1 )
                :                     ( $rec->{$field} // q{} );
            $data_table->set_value( $row, $col, $value );
            $col++;
        }
        $self->list_ctrl->RefreshList;
        $row++;
    }
    return;
}

sub _control_write_p {
    my ( $self, $name, $path ) = @_;
    hurl __ 'Wrong arguments passed to _control_write_p()'
        unless $name and defined $path;
    $self->$name->SetPath($path);
    return;
}

sub _control_write_e {
    my ( $self, $name, $value ) = @_;
    hurl __ 'Wrong arguments passed to _control_write_e()'
        unless $name;
    $self->$name->Clear;
    $self->$name->SetValue($value) if defined $value;
    return;
}

sub _control_write_c {
    my ( $self, $name, $value ) = @_;
    hurl __ 'Wrong arguments passed to _control_write_c()'
        unless $name and defined $value;
    $self->$name->SetValue($value);
    return;
}

sub _control_read_e {
    my ( $self, $name ) = @_;
    hurl __ 'Wrong arguments passed to _control_read_e()'
        unless $name;
    return $self->$name->GetValue;
}

sub _control_read_p {
    my ( $self, $name ) = @_;
    hurl __ 'Wrong arguments passed to _control_read_p()'
        unless $name;
    return $self->$name->GetPath;
}

sub _control_read_c {
    my ( $self, $name ) = @_;
    hurl __ 'Wrong arguments passed to _control_read_p()'
        unless $name;
    return $self->$name->GetValue();
}

sub _init_form {
    my $self = shift;
    $self->_control_write_e('txt_name', undef);
    $self->_control_write_e('txt_db', undef);
    $self->_control_write_c('cbx_engine', 'unknown');
    return;
}

sub _clear_form {
    my $self = shift;
    $self->_control_write_p('dpc_path', '');
    $self->_init_form;
    return;
}

sub _on_item_selected {
    my ($self, $var, $event) =  @_;
    my $item = $event->GetIndex;

    return unless $self->get_state eq 'sele';

    $self->_clear_form;
    $self->_select_item($item);
    $self->_load_selected_item;

    return;
}

sub _on_dpc_change {
    my ($self, $frame, $event) = @_;

    print "Path changed\n";

    my $new_path = $event->GetEventObject->GetPath;
    if ( $self->get_state ne 'sele' ) {
        if ( $self->is_duplicate_path($new_path) ) {
            $self->set_message( __ '*** Duplicate path! ***' );
            return;
        }
    }

    $self->_init_form;
    $self->config->reload($new_path);
    my $engine = $self->config->get( key => 'core.engine' );
    print "Engine is $engine\n";

    # Default project name: the dir name
    my $name = file($new_path)->basename;
    $self->_control_write_e('txt_name', $name);

    return;
}

sub _select_item {
    my ($self, $item) = @_;

    ###my $sel = $self->list_ctrl->get_selection;
    #p $sel;

    my $name = $self->list_data->get_value($item, 1);
    my $path = $self->list_data->get_value($item, 2);

    $self->_control_write_e('txt_name', $name);
    $self->_control_write_p('dpc_path', $path);

    # Store the selected id, name and path
    $self->selected_item($item);
    $self->selected_name($name);
    $self->selected_path( dir $path ) if $path;

    return;
}

=head2 _load_selected_item

Load info for the selected list item.  Can't use the current Sqitch
configuration for this, for every item (project) we have to load
the local configuration file and get the required info from there.

=cut

sub _load_selected_item {
    my $self = shift;

    # Load the local config

    my $item_cfg_file = file $self->selected_path, $self->config->confname;
    my $item_cfg_href = Config::GitLike->load_file($item_cfg_file);

    my $engine_code = $item_cfg_href->{'core.engine'};
    my $engine_name = $self->config->get_engine_name($engine_code);
    $self->_control_write_c('cbx_engine', $engine_name) if $engine_name;

    # Use target here
    # $self->config->reload($self->selected_path);
    # my %targets = $self->config->get_regexp(key => qr/^target[.][^.]+[.]uri$/);
    # p %targets;
    # my $engine = $self->ancestor->sqitch->engine_for_target('flipr_test');
    # my $database = $engine->uri->dbname;
    # if ($database) {
    #     $self->_control_write_e('txt_db', $database);
    # }

    return;
}

sub _mark_as_default {
    my ($self, $item) = @_;
    $self->_clear_default_mark;
    $item = $self->selected_item unless defined $item;
    $self->_set_default_mark($item) if defined $item;
    return;
}

sub set_message {
    my ($self, $mesg) = @_;
    my $busy = Wx::BusyInfo->new($mesg);
    $self->app->Yield;          # no text without this
    Wx::Sleep(3);               # not very nice...
    $busy = undef;
    return;
}

sub _clear_default_mark {
    my $self = shift;
    my $max_index = $self->list_data->get_item_count;
    for my $item (0..$max_index) {
        # $self->list_ctrl->set_list_item_data( $item, { default => 0 } ); XXX
        # $self->list_ctrl->set_list_item_text( $item, 3, q{} );
    }
    return;
}

sub _set_default_mark {
    my ($self, $item) = @_;
    hurl __ 'Wrong arguments passed to _set_default_mark()'
        unless defined $item;
    # $self->list_ctrl->set_list_item_data( $item, { default => 1 } ); XXX
    # $self->list_ctrl->set_list_item_text($item, 3, __ 'Yes');
    return;
}

sub _get_default_item {
    my $self = shift;
    my $max_index = $self->list_ctrl->list_max_index;
    my $defa_item = 0;
    for my $item (0..$max_index) {
        my $data = $self->list_ctrl->get_list_item_data($item);
        if (exists $data->{default} and $data->{default} == 1) {
            $defa_item = $item;
        }
    }
    return $defa_item;
}

sub config_new_repo {
    my $self = shift;

    my $state = $self->get_state;

    if ( $state eq 'sele' ) {
        print "Make state add\n";
        $self->_clear_form;
        $self->btn_new->SetLabel( __ 'C&ancel' );
        $self->ancestor->dlg_status->set_state('add');
        $self->list_ctrl->Enable(1);
        my $item = $self->_new_list_item;
        $self->selected_item($item);
        $self->list_ctrl->Enable(0);
    }
    elsif ( $state eq 'add' ) {
        print "Canceled...\n";
        $self->btn_new->SetLabel( __ '&New' );
        $self->ancestor->dlg_status->set_state('sele');
        $self->_remove_list_item;
        $self->list_ctrl->Enable(1);
    }

    return;
}

sub config_edit_repo {
    my $self = shift;

    my $state = $self->get_state;

    if ( $state eq 'sele' ) {
        print "Make state edit\n";
        $self->ancestor->dlg_status->set_state('edit');
        $self->list_ctrl->Enable(0);
        $self->btn_edit->SetLabel( __ 'C&ancel' );
    }
    elsif ( $state eq 'edit' ) {
        print "Canceled...\n";
        $self->btn_edit->SetLabel( __ '&Edit' );
        $self->ancestor->dlg_status->set_state('sele');
        $self->list_ctrl->Enable(1);
    }

    return;
}

sub record_is_duplicate {
    my ($self, $name, $path) = @_;

    unless ($name and $path) {
        $self->set_message(__ 'Add a project path, please.');
        return 1;
    }

    my $dup_name = $self->is_duplicate_name($name);
    my $dup_path = $self->is_duplicate_path($path);
    if ($dup_name and $dup_path) {
        $self->set_message(__ 'Duplicate name and path!');
        return 1;
    }
    else {
        if ($dup_name) {
            $self->set_message(__ 'Duplicate name!');
            return 1;
        }
        if ($dup_path) {
            $self->set_message(__ 'Duplicate path!');
            return 1;
        }
    }

    return;
}

sub _new_list_item {
    my $self = shift;
    my $list_item = [ { name => '', path => '' } ];
    my $new_index = $self->list_ctrl->list_max_index + 1;
    $self->list_ctrl->populate($list_item, $new_index);
    $self->list_ctrl->select_item($new_index);
    return $new_index;
}

sub _remove_list_item {
    my $self = shift;
    my $item = $self->selected_item;
    if ($item) {
        $self->list_ctrl->DeleteItem($item);
        $self->list_ctrl->select_item(0);
    }
    return;
}

sub _edit_list_item {
    my ($self, $item, $name, $path) = @_;
    $self->list_ctrl->set_list_item_text($item, 1, $name);
    $self->list_ctrl->set_list_item_text($item, 2, $path);
    return;
}

sub config_remove_repo {
    my $self = shift;

    my $name = $self->_control_read_e('txt_name');
    my $path = $self->_control_read_p('dpc_path');

    unless ($name and $path) {
        $self->set_message(__ 'Select a project item, please.');
        return;
    }

    my $default    = $self->config->repo_default_name;
    my $is_default = $name eq $default ? 1 : 0;

    $self->ancestor->config_remove_repo($name, $path, $is_default);

    $self->_remove_list_item;

    return;
}

sub config_save_repo {
    my $self = shift;

    my $name = $self->_control_read_e('txt_name');
    my $path = $self->_control_read_p('dpc_path');

    return if $self->record_is_duplicate( $name, $path );

    print " Saving...\n";

    # Save in user config
    $self->ancestor->config_edit_repo( $name, $path );

    # Save in local config
    my $engine_name = $self->_control_read_c('cbx_engine');
    my $engine      = $self->config->get_engine_from_name($engine_name);
    my $database    = $self->_control_read_e('txt_db');
    if( $engine and $database ) {
        $self->ancestor->config_save_local( $engine, $database );
    }
    $self->btn_new->SetLabel( __ '&New' );
    $self->btn_edit->SetLabel( __ '&Edit' );
    $self->ancestor->dlg_status->set_state('sele');

    $self->_edit_list_item($self->selected_item, $name, $path);

    return;
}

sub config_set_default {
    my $self = shift;

    my $index = $self->list_ctrl->get_selection;
    print "Select item no $index\n";
    $self->_select_item($index);

    my $name = $self->selected_name;
    my $path = $self->selected_path;
    unless ( $name and $path ) {
        $self->set_message(__ 'Select a project item, please.');
        return;
    }

    $self->ancestor->config_set_default($name); # write to the config file
    $self->config->repo_default_name($name);    # set the new default
    $self->config->repo_default_path($path);

    # my $user_file = $self->config->user_file;
    # $self->config->reload($user_file);
    # $self->config->reload($path);
    # p $self->config;
    print 'r: user_file:   ', $self->config->user_file, "\n";
    print 'r: local_file:  ', $self->config->local_file, "\n";

    $self->_mark_as_default;

    return;
}

sub is_duplicate_name {
    my ($self, $name) = @_;
    my $curr_name = $self->selected_name;
    for my $pair ( $self->repo_pairs ) {
        next if $name eq $curr_name;
        return 1 if $pair->[0] eq $name;
    }
    return;
}

sub is_duplicate_path {
    my ($self, $path) = @_;
    my $curr_path = $self->selected_path;
    for my $pair ( $self->repo_pairs ) {
        next if $path eq $curr_path;
        return 1 if $pair->[1] eq $path;
    }
    return;
}

sub OnClose {
    my ($self, $dialog, $event) = @_;
    $self->EndModal(wxID_OK);
    $self->Destroy;
    return;
}

sub list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 25,
            type  => 'int',
        },
        {   field => 'name',
            label => __ 'Name',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'path',
            label => __ 'Path',
            align => 'left',
            width => 266,
            type  => 'bool',
        },
        {   field => 'default',
            label => __ 'Default',
            align => 'center',
            width => 60,
            type  => 'bool',
        },
    ];
}

1;
