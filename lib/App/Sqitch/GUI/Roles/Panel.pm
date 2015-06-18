package App::Sqitch::GUI::Roles::Panel;

# ABSTRACT: The Panel Role

use Wx qw(:everything);
use Moo::Role;
use App::Sqitch::X qw(hurl);
use namespace::autoclean;

sub control_write_stc {
    my ( $self, $control, $value, $is_append ) = @_;
    hurl 'Wrong arguments passed to control_write_stc()'
        unless $control and $control->isa('Wx::StyledTextCtrl');
    $value ||= q{};                 # empty
    $control->ClearAll unless $is_append;
    $control->AppendText($value);
    $control->AppendText("\n");
    $control->Colourise( 0, $control->GetTextLength );
    return;
}

sub control_write_e {
    my ( $self, $control, $value ) = @_;
    hurl 'Wrong arguments passed to control_write_e()'
        unless $control and $control->isa('Wx::TextCtrl');
    $control->Clear;
    $control->SetValue($value) if defined $value;
    return;
}

sub control_write_c {
    my ( $self, $control, $value ) = @_;
    hurl 'Wrong arguments passed to control_write_c()'
        unless $control
        and $control->isa('Wx::ComboBox')
        and defined $value;
    $control->SetValue($value);
    return;
}

sub control_write_p {
    my ( $self, $control, $path ) = @_;
    hurl 'Wrong arguments passed to control_write_p()'
        unless $control
        and $control->isa('Wx::DirPickerCtrl')
        and defined $path;
    $control->SetPath($path);
    return;
}

sub control_read_e {
    my ( $self, $control ) = @_;
    hurl 'Wrong arguments passed to control_read_e()'
        unless $control and $control->isa('Wx::TextCtrl');
    return $control->GetValue;
}

sub control_read_p {
    my ( $self, $control ) = @_;
    hurl 'Wrong arguments passed to control_read_p()'
        unless $control
        and $control->isa('Wx::DirPickerCtrl');
    return $control->GetPath;
}

sub control_read_c {
    my ( $self, $control ) = @_;
    hurl 'Wrong arguments passed to control_read_c()'
        unless $control
        and $control->isa('Wx::ComboBox');
    return $control->GetValue();
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

Thank you!

=head1 LICENSE AND COPYRIGHT

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut
