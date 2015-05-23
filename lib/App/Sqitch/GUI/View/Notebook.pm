package App::Sqitch::GUI::View::Notebook;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxPanel
    WxSizer
    WxCollapsiblePane
    WxStaticText
    WxTextCtrl
    SqitchGUIViewNotebook
	SqitchGUIViewEditor
);
use Wx qw(:everything);
use Wx::Event qw();
use Wx::AUI;

with 'App::Sqitch::GUI::Roles::Element';

extends 'Wx::AuiNotebook';

has 'page_deploy' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_deploy',
);

has 'page_revert' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_revert',
);

has 'page_verify' => (
    is      => 'rw',
    isa     => WxPanel,
    lazy    => 1,
    builder => '_build_page_verify',
);


sub FOREIGNBUILDARGS {
    my $self = shift;
    my %args = @_;
    return (
        $args{parent},
        -1,
        [-1, -1],
        [-1, -1],
        wxAUI_NB_TAB_FIXED_WIDTH,
    );
}

sub BUILD {
    my $self = shift;
    return $self;
};

sub _build_page_deploy {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Deploy' );
    return $page;
}

sub _build_page_revert {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Revert' );
    return $page;
}

sub _build_page_verify {
    my $self = shift;
    my $page = Wx::Panel->new( $self->parent, -1, [-1, -1], [-1, -1] );
    $self->AddPage( $page, 'Verify' );
    return $page;
}

sub _set_events { }

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

1;    # End of App::Sqitch::GUI::View::Notebook
