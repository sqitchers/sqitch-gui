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
    is      => 'ro',
    isa     => WxAboutDialogInfo,
    default => sub {
        return Wx::AboutDialogInfo->new;
    },
);

sub BUILD {
    my $self = shift;

    my $PROGRAM_NAME = q{ Sqitch GUI };
    my $WX_VERSION   = wxVERSION_STRING;
    my $PROGRAM_DESC
        = qq{\nA GUI for Sqitch.\n} . qq{\nwxPerl $Wx::VERSION, $WX_VERSION\n}
        . qq{Sqitch $App::Sqitch::VERSION};
    my $PROGRAM_VER = $App::Sqitch::GUI::VERSION // q{(devel)};
    $self->info->SetName($PROGRAM_NAME);
    $self->info->SetVersion($PROGRAM_VER);
    $self->info->SetDescription($PROGRAM_DESC);
    $self->info->SetCopyright(qq{Copyright 2016 Ștefan Suciu}
                            . qq{\n}
                            . qq{Copyright 2012-2016 iovation Inc.});
    $self->info->SetLicense(q{
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    });
    $self->info->AddDeveloper('Ștefan Suciu');
    $self->info->AddDeveloper('David E. Wheeler');

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
