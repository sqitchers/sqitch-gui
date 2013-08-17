package App::Sqitch::GUI::View::Dialog::Repo;

use Moose;
use namespace::autoclean;
use Try::Tiny;
use Path::Class;
use App::Sqitch::X qw(hurl);

use Wx qw(:everything);
use Wx::Event qw(EVT_CLOSE EVT_BUTTON EVT_LIST_ITEM_SELECTED
                 EVT_DIRPICKER_CHANGED);

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;

extends 'Wx::Dialog';

use App::Sqitch::GUI::View::List;

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

has 'list_ctrl' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::List',
    lazy_build => 1,
);

has 'mesg_ctrl' => ( is => 'rw', isa => 'Wx::StaticText', lazy_build => 1 );

has 'btn_sizer'   => ( is => 'rw', isa => 'Wx::Sizer',  lazy_build => 1 );
has 'btn_load'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_default' => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_add'     => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );
has 'btn_exit'    => ( is => 'rw', isa => 'Wx::Button', lazy_build => 1 );

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

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND | wxALL, 5 );
    $self->list_fg_sz->Add( $self->mesg_ctrl, 1, wxEXPAND | wxALL, 5 );

    $self->list_fg_sz->Add( $self->h_line1,    1, wxEXPAND | wxALL, 10 );
    $self->list_fg_sz->Add( $self->form_fg_sz, 1, wxEXPAND | wxALL,  5 );
    $self->list_fg_sz->Add( $self->h_line2,    1, wxEXPAND | wxALL, 10 );
    $self->list_fg_sz->Add( $self->btn_sizer,  1, wxEXPAND | wxALL,  0 );

    $self->vbox_sizer->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 10 );

    $self->form_fg_sz->Add( $self->lbl_path,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->dpc_path,   1, wxEXPAND | wxLEFT, 0 );
    $self->form_fg_sz->Add( $self->lbl_name,   0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->txt_name,   0, wxLEFT,            0 );
    $self->form_fg_sz->Add( $self->lbl_driver, 0, wxLEFT,            5 );
    $self->form_fg_sz->Add( $self->cbx_driver, 1, wxLEFT,            0 );

    $self->btn_sizer->Add( $self->btn_load,    1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_default, 1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_add,     1, wxEXPAND | wxALL, 15 );
    $self->btn_sizer->Add( $self->btn_exit,    1, wxEXPAND | wxALL, 15 );

    $self->SetSizer( $self->sizer );

    $self->_init();

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

#-  Buttons

sub _build_cbx_driver {
    my $self = shift;
    my @engines = qw{Not yet used};
    my $cbx = Wx::ComboBox->new(
        $self,
        -1,
        q{},
        [ -1,  -1 ],
        [ 170, -1 ],
        \@engines,
        wxCB_SORT | wxCB_READONLY,
    );
    $cbx->Enable(0);

    return $cbx;
}

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 4, 1, 0, 5 );
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
    $button->Enable(1);
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
    $button->Enable(1);
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

sub _build_list_ctrl {
    my $self = shift;

    my $list = App::Sqitch::GUI::View::List->new(
        app       => $self->app,
        parent    => $self,
        ancestor  => $self,
        count_col => 1,                      # add a count column
    );

    $list->add_column( 'Name',    wxLIST_FORMAT_LEFT, 100, 'name' );
    $list->add_column( 'Path',    wxLIST_FORMAT_LEFT, 250, 'path' );
    $list->add_column( 'Default', wxLIST_FORMAT_CENTER,    'default' );

    return $list;
}

sub _build_mesg_ctrl {
    my $self = shift;
    my $label = Wx::StaticText->new(
        $self, -1,
        q{},
        [ -1, -1 ],
        [ -1, -1 ],
        wxST_NO_AUTORESIZE | wxALIGN_CENTRE | wxRAISED_BORDER, # ! doesn't work
    );
    $label->SetForegroundColour( Wx::Colour->new('red') );
    $label->SetBackgroundColour( Wx::Colour->new('white') ); # ! doesn't work
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

    EVT_BUTTON $self, $self->btn_exit->GetId, sub {
        $self->OnClose(@_);
    };

    EVT_BUTTON $self, $self->btn_load->GetId, sub {
        $self->ancestor->config_load(
            $self->selected_name,
            $self->selected_path,
        );
        $self->OnClose(@_);
    };

    EVT_BUTTON $self, $self->btn_default->GetId, sub {
        $self->_set_default;
        $self->ancestor->config_set_default(
            $self->selected_name, $self->selected_path,
        );
    };

    EVT_BUTTON $self, $self->btn_add->GetId, sub {
        $self->config_add_repo;
    };

    EVT_LIST_ITEM_SELECTED $self, $self->list_ctrl, sub {
        $self->_on_item_selected(@_);
    };

    EVT_DIRPICKER_CHANGED $self,
        $self->dpc_path->GetId, sub {
            $self->_clear_form;
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
    my $index = 0;
    foreach my $rec ( @{$records_ref} ) {
        last if $repo_default eq $rec->{name};
        $index++;
    }

    $self->_set_default($index);
    $self->list_ctrl->select_item($index);
    $self->_load_item($index);

    return;
}

sub _control_write_p {
    my ( $self, $name, $path ) = @_;
    hurl 'Wrong arguments passed to _control_write_p()'
        unless $name and defined $path;
    $self->$name->SetPath($path);
    return;
}

sub _control_write_e {
    my ( $self, $name, $value ) = @_;
    hurl 'Wrong arguments passed to _control_write_e()'
        unless $name;
    $self->$name->Clear;
    $self->$name->SetValue($value) if defined $value;
    return;
}

sub _control_read_e {
    my ( $self, $name ) = @_;
    hurl 'Wrong arguments passed to _control_read_e()'
        unless $name;
    return $self->$name->GetValue;
}

sub _control_read_p {
    my ( $self, $name ) = @_;
    hurl 'Wrong arguments passed to _control_read_p()'
        unless $name;
    return $self->$name->GetPath;
}

sub _control_write_l {
    my ($self, $data, $index, $repo_default) = @_;

    # Check params?

    my $item = $index;
    while (my ($name, $path) = each (%{$data})) {
        $self->list_ctrl->InsertStringItem( $item, 'dummy' );
        $self->_set_list_item_text($item, 0, $item+1 );
        $self->_set_list_item_text($item, 1, $name );
        $self->_set_list_item_text($item, 2, $path);
        if ($repo_default and $repo_default eq $name) {
            $self->_clear_default_mark;
            $self->_set_default_mark($item);
        }
        $item++;
    }
}

sub _clear_form {
    my $self = shift;
    $self->_control_write_e('txt_name', undef);
    return;
}

sub _on_item_selected {
    my ($self, $var, $event) =  @_;
    my $item = $event->GetIndex;
    $self->_load_item($item);
    return;
}

sub _load_item {
    my ($self, $item) = @_;

    my $name = $self->list_ctrl->get_list_item_text($item, 1);
    my $path = $self->list_ctrl->get_list_item_text($item, 2);
    $self->_control_write_e('txt_name', $name);
    $self->_control_write_p('dpc_path', $path);

    # Store the selected id, name and path
    $self->selected_item($item);
    $self->selected_name($name);
    $self->selected_path( dir $path );

    return;
}

sub _set_default {
    my ($self, $item) = @_;

    $item = $self->selected_item unless defined $item;
    $self->_clear_default_mark;
    $self->_set_default_mark($item);

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
    hurl 'Wrong arguments passed to _set_default_mark()'
        unless defined $item;
    $self->list_ctrl->set_list_item_data( $item, { default => 1 } );
    $self->list_ctrl->set_list_item_text($item, 3, 'Yes');

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

sub config_add_repo {
    my $self = shift;

    my $name = $self->_control_read_e('txt_name');
    my $path = $self->_control_read_p('dpc_path');

    unless ($name and $path) {
        $self->set_message('Add a name.');
        return;
    }                                            # ???

    if (   $self->is_duplicate( 'name', $name )
        or $self->is_duplicate( 'path', $path ) )
    {
        $self->set_message('Duplicate!, select a new repository path and add a name.');
        return;
    }

    # New item
    my $list_item = [ { name => $name, path => dir $path } ];
    my $new_index = $self->list_ctrl->list_max_index + 1;

    $self->list_ctrl->populate($list_item, $new_index);

    $self->ancestor->config_add_repo($name, $path);

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
