package App::Sqitch::GUI::Wx::Toolbar;

# ABSTRACT: A ToolBar Control

use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
);
use Wx qw(
    wxBITMAP_TYPE_ANY
    wxITEM_NORMAL
    wxNO_BORDER
    wxNullBitmap
    wxTB_DOCKABLE
    wxTB_FLAT
    wxTB_HORIZONTAL
);
use Wx::ArtProvider qw(:artid);
use Path::Class qw(file);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);

extends 'Wx::ToolBar';

has 'icon_path' => (
    is  => 'ro',
    isa => Dir,
);

sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
        wxTB_HORIZONTAL | wxNO_BORDER | wxTB_FLAT | wxTB_DOCKABLE, 5050,
    );
}

sub BUILD {
    my $self = shift;

    $self->SetToolBitmapSize( Wx::Size->new( 22, 22 ) );
    $self->SetMargins( 4, 4 );

    return $self;
}

sub make_toolbar_button {
    my ( $self, $name, $attribs ) = @_;
    my $type = $attribs->{type};
    if ( $self->can($type) ) {
        $self->$type( $name, $attribs );
    }
    else {
        hurl "Unknown toolbar_button type attribute: $type";
    }
    return;
}

sub set_initial_mode {
    my ( $self, $names ) = @_;
    foreach my $name ( @{$names} ) {

        # Initial state disabled, except quit and project buttons
        next if $name eq 'tb_qt';
        next if $name eq 'tb_pj';
        $self->enable_tool( $name, 0 );    # 0 = disabled
    }
    return;
}

sub _item_normal {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my ( $self, $name, $attribs ) = @_;

    $self->AddSeparator if $attribs->{sep} =~ m{before}x;

    # Add the button
    $self->{$name} = $self->AddTool(
        $attribs->{id}, $self->make_bitmap( $attribs->{icon} ),
        wxNullBitmap,   wxITEM_NORMAL,
        undef,          $attribs->{tooltip},
        $attribs->{help},
    );

    $self->AddSeparator if $attribs->{sep} =~ m{after}x;

    return;
}

sub get_toolbar_btn {
    my ( $self, $name ) = @_;
    return $self->{$name};
}

sub enable_tool {
    my ( $self, $btn_name, $state ) = @_;
    my $tb_btn_id = $self->get_toolbar_btn($btn_name)->GetId;
    my $new_state;
    if ( defined $state ) {
        $new_state
            = $state eq q{}          ? 0
            : $state =~ m/normal/x   ? 1
            : $state =~ m/disabled/x ? 0
            : $state                 ? 1
            :                          0;    # last for: 1|0
    }
    else {
        $new_state = !$self->GetToolState($tb_btn_id);   # undef state: toggle
    }
    $self->EnableTool( $tb_btn_id, $new_state );
    return;
}

sub toggle_tool_check {
    my ( $self, $btn_name, $state ) = @_;
    my $tb_btn_id = $self->get_toolbar_btn($btn_name)->GetId;
    $self->ToggleTool( $tb_btn_id, $state );
    return;
}

sub make_bitmap {
    my ( $self, $icon_file_name ) = @_;
    my $icon = file $self->icon_path, $icon_file_name;
    return Wx::Bitmap->new( $icon->stringify, wxBITMAP_TYPE_ANY ) if -f $icon;
    return Wx::ArtProvider::GetBitmap( wxART_ERROR );
}

1;

=head1 SYNOPSIS

=head2 new

Constructor method.

=head2 make_toolbar_button

Make toolbar button.

=head2 set_initial_mode

Disable some of the toolbar buttons.

=head2 _item_normal

Create a normal toolbar button

=head2 _item_check

Create a check toolbar button

=head2 _item_list

Create a list toolbar button. Not used.

=head2 get_toolbar_btn

Return a toolbar button by name.

=head2 get_choice_options

Return all options or the name of the option with index

=head2 enable_tool

Toggle tool bar button.  If state is defined then set to state, do not toggle.

State can come as 0 | 1 and normal | disabled.  Because toolbar.yml is used for
both Tk and Wx, this sub is more complex that is should be.

=head2 toggle_tool_check

Toggle a toolbar checkbutton.  State can come as 0 | 1.

=head2 make_bitmap

Create and return a bitmap object, of any type.

=cut
