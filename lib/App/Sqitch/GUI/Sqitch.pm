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

override 'emit' => sub {
    shift;
    Wx::LogMessage(@_);
};

override 'emit_literal' => sub {
    shift;
    Wx::LogMessage(@_);
};

override 'vent' => sub {
    shift;
    Wx::LogMessage(@_);
};

override 'vent_literal' => sub {
    shift;
    Wx::LogMessage(@_);
};

override 'page' => sub {
    shift;
    Wx::LogMessage(@_);
};

override 'page_literal' => sub {
    shift;
    Wx::LogMessage(@_);
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
