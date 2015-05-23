package App::Sqitch::GUI::View::StatusBar;

use 5.010;
use strict;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    Str
    WxStatusBar
);
use Wx qw(:everything);
use Wx::Event qw(EVT_SIZE);

with 'App::Sqitch::GUI::Roles::Element';

has 'status_bar' => (
    is      => 'rw',
    isa     => WxStatusBar,
    lazy    => 1,
    builder => '_build_status_bar',
);

has 'caption_msg' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    builder => '_build_caption_msg',
);

has 'caption_state' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    builder => '_build_caption_state',
);

has 'caption_proj' => (
    is      => 'rw',
    isa     => Str,
    lazy    => 1,
    builder => '_build_caption_proj',
);

sub BUILD {
    my $self = shift;
    my $sb   = $self->bar_reset;
    return $sb;
}

sub _build_status_bar {
    my $self = shift;
    return $self->parent->CreateStatusBar(3);
}

sub _build_caption_msg {
    my $self = shift;
    return q{};
}

sub _build_caption_state {
    my $self = shift;
    return q{};
}

sub _build_caption_proj {
    my $self = shift;
    return q{};
}

sub _set_events {
    my $self = shift;
    EVT_SIZE( $self->status_bar, sub { $self->OnResize(@_) } );
    return 1;
}

sub bar_reset {
    my $self = shift;

    $self->status_bar->DestroyChildren();
    $self->status_bar->SetStatusWidths(-1, 100, 100);
    $self->status_bar->SetStatusText($self->caption_msg, 0);
    $self->status_bar->SetStatusText($self->caption_state, 1);
    $self->status_bar->SetStatusText($self->caption_proj, 2);
    $self->status_bar->Update;

    return $self->status_bar;
}

sub change_caption {
    my ($self, $new_text, $field_no) = @_;

    my $old_text = $self->status_bar->GetStatusText($field_no);
    $self->caption_msg($new_text)   if $field_no == 0;
    $self->caption_state($new_text) if $field_no == 1;
    $self->caption_proj($new_text)  if $field_no == 2;
    $self->status_bar->SetStatusText( $new_text, $field_no );

    return $old_text;
}

sub OnResize {
    my($self, $status_bar, $event) = @_;
    return 1;
}

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

1;    # End of App::Sqitch::GUI::View::StatusBar
