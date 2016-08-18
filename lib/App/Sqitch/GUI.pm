package App::Sqitch::GUI;

# ABSTRACT: GUI for Sqitch

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    SqitchGUIController
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Locale::Messages qw(bind_textdomain_filter);
use App::Sqitch::GUI::Controller;

BEGIN {
    # Force Locale::TextDomain to encode in UTF-8 and to decode all messages.
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'App-Sqitch-GUI' => \&Encode::decode_utf8;
}

has 'controller' => (
    is      => 'rw',
    isa     => SqitchGUIController,
    lazy    => 1,
    builder => '_build_controller',
);

sub _build_controller {
    return App::Sqitch::GUI::Controller->new();
}

sub run {
    shift->controller->app->MainLoop;
}

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

The implementation of the localization code is based on the work of
David E. Wheeler.

Thank you!

=head1 LICENSE AND COPYRIGHT

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut
