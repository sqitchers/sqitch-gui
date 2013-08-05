package App::Sqitch::GUI::MainFrame::Panel::Plan;

use utf8;
use Moose;
use namespace::autoclean;
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);
use Wx::Perl::ListCtrl;

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'btn_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'sb_sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'main_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );
has 'list_fg_sz' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

has 'list' => ( is => 'rw', isa => 'Wx::Perl::ListCtrl', lazy_build => 1 );

sub BUILD {
    my $self = shift;

    $self->panel->Hide;

    $self->sizer->Add( $self->sb_sizer, 1, wxEXPAND | wxALL, 5 );

    $self->sb_sizer->Add( $self->main_fg_sz, 1, wxEXPAND | wxALL, 5 );

    $self->main_fg_sz->Add( $self->list_fg_sz, 1, wxEXPAND | wxALL, 5 );

    #-- List

    $self->list_fg_sz->Add( $self->list, 1, wxEXPAND, 3 );

    $self->panel->SetSizer($self->sizer);
    $self->parent->Layout();

    #$self->panel->Show;

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

sub _build_main_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 1, 0, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_list_fg_sz {
    my $fgs = Wx::FlexGridSizer->new( 2, 0, 1, 5 );
    $fgs->AddGrowableRow(0);
    $fgs->AddGrowableCol(0);
    return $fgs;
}

sub _build_sb_sizer {
    my $self = shift;

    return Wx::StaticBoxSizer->new(
        Wx::StaticBox->new( $self->panel, -1, ' Plan ', ), wxVERTICAL );
}

sub _build_list {
    my $self = shift;

    my $list = Wx::Perl::ListCtrl->new(
        $self->panel, -1,
        [ -1, -1 ],
        [ -1, -1 ],
        Wx::wxLC_REPORT | Wx::wxLC_SINGLE_SEL,
    );

    $list->InsertColumn( 0, '#', wxLIST_FORMAT_LEFT, 30 );
    $list->InsertColumn( 1, 'Name', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 2, 'Dependends', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 3, 'Create time', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 4, 'Creator', wxLIST_FORMAT_LEFT, 100 );
    $list->InsertColumn( 5, 'Description', wxLIST_FORMAT_LEFT, 180 );

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

Thank you!

=head1 LICENSE AND COPYRIGHT

Copyright:
  Jonathan D. Barton 2012-2013
  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::Panel::Plan
