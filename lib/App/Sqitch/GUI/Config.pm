package App::Sqitch::GUI::Config;

use utf8;
use Moose;
use namespace::autoclean;
use Path::Class;
use Try::Tiny;
use List::Util qw(first);
use App::Sqitch::X qw(hurl);
use MooseX::AttributeHelpers;

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

sub local_file {
    my $self = shift;
    return $self->repo_default_path
        ? file( $self->repo_default_path, $self->confname )
        : file( $self->confname );
};

has _repo_conf_list => (
    is      => 'ro',
    isa     => 'Maybe[HashRef]',
    lazy    => 1,
    default => sub {
        shift->get_regexp( key => qr/^repository[.][^.]+[.]path$/ );
    }
);

has repo_list => (
    is      => 'ro',
    isa     => 'Maybe[HashRef]',
    lazy_build => 1,
);

has 'engine_list' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[Str]',
    required  => 1,
    lazy      => 1,
    default   => sub {
        {
            unknown  => 'Unknown',
            pg       => 'PostgreSQL',
            mysql    => 'MySQL',
            sqlite   => 'SQLite',
            oracle   => 'Oracle',
            firebird => 'Firebird',
        };
    },
    provides => { 'get' => 'get_engine_name', }
);

sub get_engine_from_name {
    my ($self, $engine) = @_;
    my %engines = reverse %{ $self->engine_list };
    return $engines{$engine};
}

sub _build_repo_list {
    my $self = shift;

    my $repo_cfg_lst = $self->_repo_conf_list;

    my $repo_list = {};
    while ( my ( $key, $path ) = each( %{$repo_cfg_lst} ) ) {
        my ($name) = $key =~ m{^repository[.](.+)[.]path$};
        $repo_list->{$name} = dir $path;
    }

    return $repo_list;
}

sub has_repo_name {
    my ($self, $name) = @_;
    hurl 'Wrong arguments passed to has_repo_name()'
        unless $name;
    p $self->repo_list;
    p $name;
    return 1 if first { $name eq $_ } keys %{$self->repo_list};
    return 0;
}

sub has_repo_path {
    my ($self, $path) = @_;
    hurl 'Wrong arguments passed to has_repo_path()'
        unless $path;
    return 1 if first { $path->stringify eq $_ } values %{$self->repo_list};
    return 0;
}

sub reload {
    my ( $self, $path ) = @_;
    my $file = file $path, $self->confname;
    print "Reloading $file...\n";
    try { $self->load($file) } catch { print "Reload config error: $_\n" };
}

sub repo_list_cnt {
    my $self = shift;
    return scalar keys %{ $self->repo_list };
}

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
