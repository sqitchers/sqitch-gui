package App::Sqitch::GUI::Config;

use utf8;
use Moose;
use namespace::autoclean;
use Path::Class;
use List::Util qw(first);
use App::Sqitch::X qw(hurl);

extends 'App::Sqitch::Config';

has repo_default_name => (
    is      => 'rw',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    default => sub {
        shift->get(key => 'repository.default');
    }
);

has repo_default_path => (
    is      => 'rw',
    isa     => 'Maybe[Path::Class::Dir]',
    lazy    => 1,
    default => sub {
        my $self    = shift;
        my $default = $self->repo_default_name;
        return $default
            ? dir $self->get( key => "repository.${default}.path" )
            : undef;
    }
);

override load_dirs => sub {
    my $self = shift;
    my $conf = file( $self->repo_default_path, $self->local_file );
    print "Loading configurations from: ", $conf, "\n";
    $self->load_file($conf);# if -f $conf;
};

has repo_conf_list => (
    is      => 'ro',
    isa     => 'Maybe[HashRef]',
    lazy    => 1,
    default => sub {
        shift->get_regexp( key => '^repository\..+\.path$' );
    }
);

has repo_list => (
    is      => 'ro',
    isa     => 'Maybe[HashRef]',
    lazy_build => 1,
);

# has 'config_file' => (
#     is      => 'rw',
#     isa     => 'Maybe[Path::Class::File]',
#     lazy    => 1,
#     default => sub {
#         my $self = shift;
#         file($self->user_dir, $self->local_file); },
# );

has 'engines' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default => sub {
        return {
            pg       => 'PostgreSQL',
            mysql    => 'MySQL',
            sqlite   => 'SQLite',
            cubrid   => 'CUBRID',
            oracle   => 'Oracle',
            firebird => 'Firebird',
        };
    },
);

sub _build_repo_list {
    my $self = shift;

    my $repo_cfg_lst = $self->repo_conf_list;

    my $repo_list = {};
    while ( my ( $key, $path ) = each( %{$repo_cfg_lst} ) ) {
        my ($name) = $key =~ m{^repository\.(.+)\.path$}xmg;
        $repo_list->{$name} = dir $path;
    }

    return $repo_list;
}

sub has_repo_name {
    my ($self, $name) = @_;
    hurl 'Wrong arguments passed to has_repo_name()'
        unless $name;
    return 1 if first { $name eq $_ } keys %{$self->repo_list};
    return 0;
}

sub has_repo_path {
    my ($self, $path) = @_;
    hurl 'Wrong arguments passed to has_repo_path()'
        unless $path;
    return 1 if first { $path eq $_ } values %{$self->repo_list};
    return 0;
}

sub reload { shift->load; }

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
