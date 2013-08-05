package App::Sqitch::GUI::MainFrame::StatusBar;

use Moose;
use namespace::autoclean;
use Wx qw(:everything);
use Wx::Event qw(EVT_SIZE);
with 'App::Sqitch::GUI::Roles::Element';

has 'status_bar' => (
    is         => 'rw',
    isa        => 'Wx::StatusBar',
    lazy_build => 1,
);

has 'caption' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'old_w' => (is => 'rw', isa => 'Int', lazy => 1, default => 0);
has 'old_h' => (is => 'rw', isa => 'Int', lazy => 1, default => 0);

sub BUILD {
    my $self = shift;
    $self->bar_reset; # Resets the whole bar, including the gauge.
    return $self;
}

sub _build_status_bar {
    my $self = shift;
    return $self->parent->CreateStatusBar(2);
}

sub _build_caption {
    my $self = shift;
    return 'Welcome!';
}

sub _set_events {
    my $self = shift;
    EVT_SIZE( $self->status_bar, sub { $self->OnResize(@_) } );
    return 1;
}

sub bar_reset {
    my $self = shift;
    $self->status_bar->DestroyChildren();
    $self->status_bar->SetStatusWidths(-5, -1);
    $self->status_bar->SetStatusText($self->caption, 0);

    my $rect = $self->status_bar->GetFieldRect(1);
    #$self->gauge( $self->_build_gauge );
    # $self->yield;

    $self->status_bar->Update;
    return $self->status_bar;
}

sub change_caption {
    my $self = shift;
    my $new_text = shift;
    my $old_text = $self->status_bar->GetStatusText(0);
    $self->caption($new_text);
    $self->status_bar->SetStatusText($new_text, 0);
    return $old_text;
}

sub OnResize {
    my($self, $status_bar, $event) = @_;

    if( $self->has_main_frame ) {
        my $mf = $self->get_main_frame;
        my $current_size = $mf->frame->GetSize;
        if (   $current_size->width != $self->old_w
            or $current_size->height != $self->old_h )
        {
            $self->bar_reset;   # otherwise the throbber gauge gets all screwy
            $self->old_w( $current_size->width );
            $self->old_h( $current_size->height );
        }
    }
    return 1;
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

1;    # End of App::Sqitch::GUI::MainFrame::StatusBar
