package App::Sqitch::GUI::MainFrame::Panel::Top;

use utf8;
use Moose;
use namespace::autoclean;
use Wx qw(:allclasses :everything);
use Wx::Event qw(EVT_CLOSE);

with 'App::Sqitch::GUI::Roles::Element';

has 'panel' => ( is => 'rw', isa => 'Wx::Panel', lazy_build => 1 );
has 'sizer' => ( is => 'rw', isa => 'Wx::Sizer', lazy_build => 1 );

sub BUILD {
    my $self = shift;

    $self->panel->Show(0);
    $self->panel->SetSizer( $self->sizer );
    $self->panel->Show(1);

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
        'mainPanel',
    );
    $panel->SetBackgroundColour(Wx::Colour->new('yellow'));

    return $panel;
}

sub _build_sizer {
    return Wx::BoxSizer->new(wxHORIZONTAL);
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

1;    # End of App::Sqitch::GUI::Panel::Top
