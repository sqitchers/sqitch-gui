package App::Sqitch::GUI::Sqitch;

use Moose;
use namespace::autoclean;

extends 'App::Sqitch';

use Path::Class;

has +top_dir => (
    is       => 'rw',
    isa      => 'Maybe[Path::Class::Dir]',
    required => 1,
    lazy     => 1,
    default => sub {
        my $self = shift;
        dir( $self->config->repository_path,
            $self->config->get( key => 'core.top_dir' ) )
            || ();
        },
);

sub emit {
    shift;
    Wx::LogMessage(@_);
}

sub emit_literal {
    shift;
    Wx::LogMessage(@_);
}

sub vent {
    shift;
    Wx::LogMessage(@_);
}

sub vent_literal {
    shift;
    Wx::LogMessage(@_);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
