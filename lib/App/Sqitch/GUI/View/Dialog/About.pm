package App::Sqitch::GUI::View::Dialog::About;

use 5.010;
use strict;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxAboutDialogInfo
);

with 'App::Sqitch::GUI::Roles::Element';

has 'info' => (
    is  => 'rw',
    isa => WxAboutDialogInfo,
);

sub BUILD {
    my $self = shift;

    $self->info( Wx::AboutDialogInfo->new() );
    $self->info->SetName('Sqitch-GUI');
    $self->info->SetVersion(
        "$App::Sqitch::GUI::VERSION - wxPerl $Wx::VERSION"
    );
    $self->info->SetCopyright('Copyright 2013 Stefan Suciu');
    $self->info->SetDescription( 'A GUI for Sqitch.' );
    ### Full license in ROOT/LICENSE
    $self->info->SetLicense(
        'This is free software; you can redistribute it and/or modify it under
            the same terms as the Perl 5 programming language system itself.'
    );

    return $self;
}

sub _set_events { }

sub show {
    my $self = shift;
    Wx::AboutBox($self->info);
    return;
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

1;    # End of App::Sqitch::GUI::View::Dialog::About
