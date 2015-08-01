package App::Sqitch::GUI::Target;

# ABSTRACT: A Sqitch::Target Extension

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
    File
    Maybe
);
use Path::Class qw(dir file);
use App::Sqitch::X qw(hurl);
use namespace::autoclean;

extends 'App::Sqitch::Target';

has 'top_dir' => (
    is       => 'rw',
    isa      => Dir,
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self = shift;
        dir($self->sqitch->config->current_project_path,
            $self->sqitch->config->get( key => 'core.top_dir' )
        );
    },
);

1;
