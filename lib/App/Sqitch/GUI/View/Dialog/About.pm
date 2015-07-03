package App::Sqitch::GUI::View::Dialog::About;

# ABSTRACT: The About Dialog

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    WxAboutDialogInfo
);
use Wx qw(wxVERSION_STRING);

with 'App::Sqitch::GUI::Roles::Element';

has 'info' => (
    is  => 'rw',
    isa => WxAboutDialogInfo,
);

sub BUILD {
    my $self = shift;

    $self->info( Wx::AboutDialogInfo->new );

    my $PROGRAM_NAME = q{ Sqitch GUI };
    my $WX_VERSION   = wxVERSION_STRING;
    my $PROGRAM_DESC
        = qq{\nA GUI for Sqitch.\n} . qq{\nwxPerl $Wx::VERSION, $WX_VERSION\n};
    my $PROGRAM_VER = $App::Sqitch::GUI::VERSION // q{(devel)};
    $self->info->SetName($PROGRAM_NAME);
    $self->info->SetVersion($PROGRAM_VER);
    $self->info->SetDescription($PROGRAM_DESC);
    $self->info->SetCopyright('Copyright 2015 Ștefan Suciu');
    $self->info->SetLicense(
        'This is free software; you can redistribute it and/or modify it under
            the same terms as the Perl 5 programming language system itself.'
    );
    $self->info->AddDeveloper('Ștefan Suciu <stefan@s2i2.ro>');

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
