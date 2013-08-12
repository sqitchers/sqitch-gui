package App::Sqitch::GUI::Config;

use Moose;
use namespace::autoclean;
use Path::Class;
#use Locale::TextDomain qw(App-Sqitch);
#use App::Sqitch::X qw(hurl);
use utf8;

extends 'App::Sqitch::Config';

has repository_path => (
    is      => 'ro',
    isa     => 'Maybe[Path::Class::Dir]',
    lazy    => 1,
    default => sub {
        my $self    = shift;
        my $default = $self->get(key => 'repository.default');
        dir $self->get(key => "repository.${default}.path");
    }
);

override load_dirs => sub {
    my $self = shift;
    my $conf = file( $self->repository_path, $self->local_file );
    $self->load_file($conf) if -f $conf;
};

__PACKAGE__->meta->make_immutable;

=pod

Additions to the user configuration file C<sqitch.conf>:

  [repository]
      default = FliprPg
  [repository "FliprPg"]
      path = /home/user/sqitch/flipr-pg
  [repository "FliprCubrid"]
      path = /home/user/sqitch/flipr-cubrid

The list of repository names and paths and a default repository name.

=cut

1;
