package App::Sqitch::GUI::Target;

use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
    Maybe
);
#use namespace::autoclean;

use Path::Class qw(dir);

extends 'App::Sqitch::Target';

has +top_dir => (
    is       => 'rw',
    isa      => Maybe[Dir],
    required => 1,
    lazy     => 1,
    default => sub {
        my $self = shift;
        dir( $self->sqitch->config->default_project_path,
            $self->sqitch->config->get( key => 'core.top_dir' ) )
            || ();
        },
);

1;
