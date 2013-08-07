package App::Sqitch::GUI::WxApp;

use Moose;
use namespace::autoclean;

use Wx;
use Wx::Event qw(EVT_CLOSE);

use MooseX::NonMoose;
extends 'Wx::App';

use App::Sqitch::GUI::View;

has 'view' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View',
    lazy_build => 1,
    handles    => { menu_bar => 'menu_bar' },
);

sub FOREIGNBUILDARGS {
    return ();                     # Wx::App->new() gets no arguments.
}

sub BUILD {
    my $self = shift;

    $self->SetTopWindow($self->view->frame);
    $self->view->frame->Show(1);
    $self->_set_events;

    return $self;
}

sub _build_view {
    my $self = shift;

    my $args = {
        app   => $self,
        title => 'Sqitch::GUI',
    };

    return App::Sqitch::GUI::View->new( $args );
}

sub _set_events {
    my $self = shift;
    EVT_CLOSE( $self->view->frame, sub { $self->OnClose(@_) } );
    return;
}

sub OnInit {
    my $self = shift;
    Wx::InitAllImageHandlers();
    return 1;
}

sub OnClose {
    my($self, $frame, $event) = @_;
    $event->Skip();
    return;
}

sub OnAssertFailure {
    my ( $self, $file, $line, $function, $condition, $msg ) = @_;
    print "AssertFailure: $file, $line, $function, $condition, $msg\n";
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

1;
