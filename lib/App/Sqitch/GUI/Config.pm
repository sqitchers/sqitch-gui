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
        my $self    = shift;
        my $default = $self->get(key => 'project.default');
        dir $self->get(key => "project.${default}.path");
    }
);

override load_dirs => sub {
    my $self = shift;
    my $conf = file( $self->project_path, $self->local_file );
    $self->load_file($conf) if -f $conf;
};

__PACKAGE__->meta->make_immutable;

=pod

Additions to the user configuration file C<sqitch.conf>:

  [project]
      default = FliprPg
  [project "FliprPg"]
      path = /home/user/sqitch/flipr-pg
  [project "FliprCubrid"]
      path = /home/user/sqitch/flipr-cubrid

The list of project names and paths and a default project name.

=cut

1;
