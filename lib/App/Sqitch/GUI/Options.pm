package App::Sqitch::GUI::Options;

# ABSTRACT: Options for Sqitch GUI

use 5.010;
use Moo;
use MooX::Options;

option 'verbose' => (
    is    => 'ro',
    doc   => 'set verbose on',
    short => 'v',
);

option 'debug' => (
    is    => 'ro',
    doc   => 'set debug on',
    short => 'd',
);

1;

__END__

=encoding utf8

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE

=head2 ATTRIBUTES

=head2 C<verbose>

=head2 METHODS

=cut
