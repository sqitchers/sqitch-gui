package App::Sqitch::GUI::View::Panel::Plan;

use utf8;
use Moose;
use namespace::autoclean;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
#use Locale::Messages qw(bind_textdomain_filter);
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

use App::Sqitch::GUI::View::List;

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'btn_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'sb_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'main_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'list_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'list_ctrl' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::List',
    lazy_build => 1,
);

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- List

    $self->list_fg_sz->Add( $self->list_ctrl, 1, wxEXPAND, 3 );

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
    #$panel->SetBackgroundColour( Wx::Colour->new('blue') );

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
}

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 1, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 1, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, __ 'Plan ', ), wxVERTICAL );
}

sub _build_list_ctrl {
    my $self = shift;

    my $list = App::Sqitch::GUI::View::List->new(
        app       => $self->app,
        parent    => $self->panel,
        ancestor  => $self,
        count_col => 1,                      # add a count column
    );

    $list->add_column( 'Name',        wxLIST_FORMAT_LEFT, 100, 'name' );
    $list->add_column( 'Dependends',  wxLIST_FORMAT_LEFT, 100, 'dependends' );
    $list->add_column( 'Create time', wxLIST_FORMAT_LEFT, 100, 'create_time' );
    $list->add_column( 'Creator',     wxLIST_FORMAT_LEFT, 100, 'creator' );
    $list->add_column( 'Description', wxLIST_FORMAT_LEFT, 180, 'description' );

    return $list;
}

sub _set_events { }

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

1;    # End of App::Sqitch::GUI::Panel::Plan
