package App::Sqitch::GUI::Roles::Element;

# ABSTRACT: The Element Role

use Moo::Role;
use App::Sqitch::GUI::Types qw(
    HashRef
    Maybe
    Object
    SqitchGUIWxApp
    SqitchGUIModel
    WxWindow
);
use namespace::autoclean;

has 'app' => (
    is       => 'rw',
    isa      => SqitchGUIWxApp,
    required => 1,
    weak_ref => 1,
);

has 'ancestor' => (
    is       => 'ro',
    isa      => Object,
    weak_ref => 1,
);

has 'parent' => (
    is  => 'rw',
    isa => Maybe[WxWindow],
);

requires '_set_events';

after BUILD => sub {
    my $self = shift;
    $self->_set_events;
    return 1;
};

1;

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
