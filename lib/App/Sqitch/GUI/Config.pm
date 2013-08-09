package App::Sqitch::GUI::Config;

use Moose;
use namespace::autoclean;
use Path::Class;
#use Locale::TextDomain qw(App-Sqitch);
#use App::Sqitch::X qw(hurl);
use utf8;

extends 'App::Sqitch::Config';

has project_path => (
    is      => 'ro',
    isa     => 'Maybe[Path::Class::Dir]',
    lazy    => 1,
    default => sub {
        dir shift->get(key => 'projects.path');
    }
);

override load_dirs => sub {
    my $self = shift;
    my $conf = file( $self->project_path, $self->local_file );
    $self->load_file($conf) if -f $conf;
};

__PACKAGE__->meta->make_immutable;

1;
