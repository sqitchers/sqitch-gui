package App::Sqitch::GUI::View::Dialog::Repo;

use Moose;
use namespace::autoclean;

use Try::Tiny;
use Path::Class;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);

use Wx qw(:everything);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON EVT_LIST_ITEM_SELECTED
                 EVT_DIRPICKER_CHANGED);

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;

extends 'Wx::Dialog';

use App::Sqitch::GUI::View::List;

use Data::Printer;

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
has 'lbl_engine' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );
has 'cbx_engine' => ( is => 'rw', isa => 'Wx::ComboBox',   lazy_build => 1 );
has 'lbl_db'   => ( is => 'rw', isa => 'Wx::StaticText',    lazy_build => 1 );
has 'txt_db'   => ( is => 'rw', isa => 'Wx::TextCtrl',      lazy_build => 1 );

has 'list_ctrl' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::List',
    lazy_build => 1,
);

has 'mesg_ctrl' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );

has 'btn_sizer'   => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'btn_sizer_l' => ( is => 'rw', isa => 'Wx::GridSizer', lazy_build => 1 );
has 'btn_sizer_r' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'btn_new'     => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_edit'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_remove'  => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_load'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_default' => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_close'   => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_save'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );

has 'selected_item' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => sub { undef },
);

has 'selected_name' => (
    is      => 'rw',
    isa     => 'Maybe[Str]',
    default => sub { undef },
);

has 'selected_path' => (
    is      => 'rw',
    isa     => 'Maybe[Path::Class::Dir]',
    default => sub { undef },
);

has config => (
    is      => 'ro',
    isa     => 'App::Sqitch::GUI::Config',
    lazy    => 1,
    default => sub {
        shift->ancestor->config;
    },
);

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        __ 'Repository List',
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
    $self->list_fg_sz->Add( $self->mesg_ctrl, 1, wxEXPAND | wxALL, 5 );

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

    $self->_init();

    $self->list_ctrl->SetFocus();

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

sub _build_vbox_sizer {
    return Wx::BoxSizer->new(wxVERTICAL);
}

sub _build_sizer {
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
    return Wx::StaticText->new( $self, -1, __ 'Repository' );
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

    my $list = App::Sqitch::GUI::View::List->new(
        app       => $self->app,
        parent    => $self,
        count_col => 1,                      # add a count column
    );

    $list->add_column( __ 'Name',    wxLIST_FORMAT_LEFT, 100, 'name' );
    $list->add_column( __ 'Path',    wxLIST_FORMAT_LEFT, 250, 'path' );
    $list->add_column( __ 'Default', wxLIST_FORMAT_CENTER,    'default' );

    return $list;
}

sub _build_mesg_ctrl {
    my $self = shift;
    my $label = Wx::StaticText->new(
        $self, -1,
        q{This should be a centered blue text on a red background!},
        [ -1, -1 ],
        [ -1, -1 ],
        wxST_NO_AUTORESIZE | wxALIGN_CENTRE | wxRAISED_BORDER, # ! doesn't work
    );
    $label->SetForegroundColour( Wx::Colour->new('blue') );
    $label->SetBackgroundColour( Wx::Colour->new('red') ); # ! doesn't work
    return $label;
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

    my $repo_list = $self->config->repo_list;

    # Prepare records
    my $records_ref = [];
    while ( my ( $name, $path ) = each( %{$repo_list} ) ) {
        push @{$records_ref}, { name => $name, path => $path };
    }

    $self->list_ctrl->populate($records_ref);

    # Default from config
    my $repo_default = $self->config->repo_default_name;
    my $index;
    if ($repo_default) {
        $index = 0;
        foreach my $rec ( @{$records_ref} ) {
            last if $repo_default eq $rec->{name};
            $index++;
        }
        $self->_set_as_default($index);
        $self->list_ctrl->select_item($index);
        $self->_load_item($index);
    }

    $self->ancestor->dlg_status->set_state('init');

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
    print "Init form\n";
    $self->_control_write_e('txt_name', undef);
    $self->_control_write_e('txt_db', undef);
    $self->_control_write_c('cbx_engine', 'unknown');
    return;
}

sub _clear_form {
    my $self = shift;
    print "Clear form\n";
    $self->_control_write_p('dpc_path', '');
    $self->_init_form;
    return;
}

sub _on_item_selected {
    my ($self, $var, $event) =  @_;
    my $item = $event->GetIndex;
    $self->_load_item($item);
    return;
}

sub _on_dpc_change {
    my ($self, $frame, $event) = @_;
    print "Path changed\n";
    my $new_path = $event->GetEventObject->GetPath;
    print "'$new_path' is the new path\n";
    $self->_init_form;
    $self->config->reload($new_path);
    my $engine = $self->config->get( key => 'core.engine' );
    print "Engine is $engine\n";
    p $self->config;
    return;
}

sub _load_item {
    my ($self, $item) = @_;

    my $name = $self->list_ctrl->get_list_item_text($item, 1);
    $self->_control_write_e('txt_name', $name);
    my $path = $self->list_ctrl->get_list_item_text($item, 2);
    $self->_control_write_p('dpc_path', $path);

    # Load the local config

    my $item_cfg_file = file $path, $self->config->confname;
    my $item_cfg_href = Config::GitLike->load_file($item_cfg_file);

    my $engine = $item_cfg_href->{'core.engine'};

    my $engine_name = $self->config->get_engine_name($engine);
    if ($engine_name) {
        $self->_control_write_c('cbx_engine', $engine_name);
    }
    else {
        print "No engine name for $engine\n";
    }

    my $database = $item_cfg_href->{"core.${engine}.db_name"};
    if ($database) {
        $self->_control_write_e('txt_db', $database);
    }
    else {
        print "No DATABASE\n";
    }

    # Store the selected id, name and path
    $self->selected_item($item);
    $self->selected_name($name);
    $self->selected_path( dir $path );

    return;
}

sub _set_as_default {
    my ($self, $item) = @_;

    $self->_clear_default_mark;
    $item = $self->selected_item unless defined $item;
    $self->_set_default_mark($item) if defined $item;

    return;
}

sub set_message {
    my ($self, $mesg) = @_;
    $self->mesg_ctrl->SetLabel('');          # clear
    $self->mesg_ctrl->SetLabel($mesg) if $mesg;
    return;
}

sub _clear_default_mark {
    my $self = shift;

    my $max_index = $self->list_ctrl->list_max_index;
    for my $item (0..$max_index) {
        $self->list_ctrl->set_list_item_data( $item, { default => 0 } );
        $self->list_ctrl->set_list_item_text( $item, 3, q{} );
    }

    return;
}

sub _set_default_mark {
    my ($self, $item) = @_;
    hurl __ 'Wrong arguments passed to _set_default_mark()'
        unless defined $item;
    $self->list_ctrl->set_list_item_data( $item, { default => 1 } );
    $self->list_ctrl->set_list_item_text($item, 3, __ 'Yes');

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

    my $state = $self->ancestor->dlg_status->get_state;

    if ( $state eq 'sele' ) {
        print "Make state add\n";
        $self->_clear_form;
        $self->btn_new->SetLabel( __ 'C&ancel' );
        $self->ancestor->dlg_status->set_state('add');
        $self->_new_list_item();
        $self->list_ctrl->Enable(0);
    }
    elsif ( $state eq 'add' ) {
        print "Canceled...\n";
        $self->btn_new->SetLabel( __ '&New' );
        $self->ancestor->dlg_status->set_state('sele');
        $self->_remove_list_item();
        $self->list_ctrl->Enable(1);
    }

    return;
}

sub config_edit_repo {
    my $self = shift;

    my $state = $self->ancestor->dlg_status->get_state;

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
        $self->set_message('Add a repository Path and a Name, please.');
        return;
    }

    if (   $self->is_duplicate( 'name', $name )
        or $self->is_duplicate( 'path', $path ) )
    {
        $self->set_message(__ 'Duplicate! To add a new repository, select a new path and add a name for it.');
        return 1;
    }

    return;
}

sub _new_list_item {
    my $self = shift;

    my $list_item = [ { name => '', path => '' } ];
    my $new_index = $self->list_ctrl->list_max_index + 1;
    $self->list_ctrl->populate($list_item, $new_index);
    $self->list_ctrl->select_item($new_index);

    return;
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

sub config_remove_repo {
    my $self = shift;

    my $name = $self->_control_read_e('txt_name');
    my $path = $self->_control_read_p('dpc_path');

    unless ($name and $path) {
        $self->set_message(__ 'Select a repository item, please.');
        return;
    }

    my $default    = $self->config->repo_default_name;
    my $is_default = $name eq $default ? 1 : 0;

    $self->ancestor->config_remove_repo($name, $path, $is_default);

    return;
}

sub config_save_repo {
    my $self = shift;

    # Save in user config
    my $name = $self->_control_read_e('txt_name');
    my $path = $self->_control_read_p('dpc_path');
    unless ( $self->record_is_duplicate( $name, $path ) ) {
        $self->ancestor->config_edit_repo( $name, $path );
    }

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

    return;
}

sub config_set_default {
    my $self = shift;

    $self->_set_as_default;

    my $name = $self->selected_name;
    my $path = $self->selected_path;
    unless ( $name and $path ) {
        $self->set_message(__ 'Select a repository item, please.');
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

    return;
}

sub is_duplicate {
    my ($self, $field, $name) = @_;
    my $proc = "selected_$field";
    return 1 if $self->$proc eq $name;
    return 0;
}

sub OnClose {
    my ($self, $dialog, $event) = @_;

    $self->EndModal(wxID_OK);
    $self->Destroy;

    return;
}

__PACKAGE__->meta->make_immutable;

1;
