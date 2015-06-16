package App::Sqitch::GUI::Model::Cell;

use Moo;
use Types::Standard -types;

has name => (
    is  => 'rw',
    isa => Str,
);

1;

=head1 ACKNOWLEDGMENTS

Code copied from http://www.perlmonks.org/?node_id=1052124

Thanks tobyink.

=cut
