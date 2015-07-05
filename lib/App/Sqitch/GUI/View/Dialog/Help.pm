package App::Sqitch::GUI::View::Dialog::Help;

# ABSTRACT: The Help Dialog

use 5.010;
use strict;
use warnings;
use Moo;

with 'App::Sqitch::GUI::Roles::Element';

sub BUILD {
    my $self = shift;
    return $self;
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

  Stefan Suciu 2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::View::Dialog::Help
