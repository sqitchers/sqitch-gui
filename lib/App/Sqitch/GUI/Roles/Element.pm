package App::Sqitch::GUI::Roles::Element;

use Moose::Role;
use Wx qw(:everything);

has 'app' => (
    is          => 'rw',
    isa         => 'App::Sqitch::GUI::WxApp',
    required    => 1,
    weak_ref    => 1,
    handles => {
        get_view       => 'view',
        has_view       => 'has_view',
        menu           => 'menu_bar',
        get_left_pane  => 'left_pane',
        get_right_pane => 'right_pane',
        }
);
has 'ancestor'  => (is => 'rw', isa => 'Object', weak_ref => 1 );
has 'parent'    => (is => 'rw', isa => 'Maybe[Wx::Window]' );
has 'sizer_debug' => (is => 'rw', isa => 'Int',  lazy => 1, default => 0,
        documentation => q{
            draws boxes with titles around all sizers if true.
        }
    );
has 'sizers' => (is => 'rw', isa => 'HashRef', lazy => 1, default => sub{ {} });

requires '_set_events';

after BUILD => sub {
    my $self = shift;
    $self->_set_events;
    return 1;
};

sub build_sizer {
    my $self        = shift;
    my $parent      = shift;
    my $direction   = shift;
    my $name        = shift or die "the Sizer name is required!";
    my $force_box   = shift || 0;
    my $pos         = shift || wxDefaultPosition;
    my $size        = shift || wxDefaultSize;

    my $hr = { };
    if( $self->sizer_debug or $force_box ) {
        $hr->{'box'} = Wx::StaticBox->new($parent, -1, $name, $pos, $size),
        $hr->{'sizer'} = Wx::StaticBoxSizer->new($hr->{'box'}, $direction);
    }
    else {
        $hr->{'sizer'} = Wx::BoxSizer->new($direction);
    }
    $self->sizers->{$name} = $hr;

    return $hr->{'sizer'};
}

no Moose::Role;

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

1;    # End of App::Sqitch::GUI::Roles::Element
