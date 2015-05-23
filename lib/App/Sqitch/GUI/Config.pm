package App::Sqitch::GUI::Config;

use 5.010;
use strict;
use utf8;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
    Str
    Maybe
    HashRef
);
use Path::Class;
use Try::Tiny;
use List::Util qw(first);
use App::Sqitch::X qw(hurl);
use MooseX::AttributeHelpers;

extends 'App::Sqitch::Config';

has repo_default_name => (
    is      => 'rw',
    isa     => Maybe[Str],
    lazy    => 1,
    default => sub {
        shift->get(key => 'core.project');
    }
);

has repo_default_path => (
    is      => 'rw',
    isa     => Maybe[Dir],
    lazy    => 1,
    default => sub {
        my $self    = shift;
        my $default = $self->repo_default_name;
        return $default
            ? dir $self->get( key => "project.${default}.path" )
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
    isa     => Maybe[HashRef],
    lazy    => 1,
    default => sub {
        shift->get_regexp( key => qr/^project[.][^.]+[.]path$/ );
    }
);

has project_list => (
    is      => 'ro',
    isa     => Maybe[HashRef],
    lazy    => 1,
    builder => '_build_project_list',
);

has 'engine_list' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => HashRef[Str],
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

sub _build_project_list {
    my $self = shift;

    my $repo_cfg_lst = $self->_repo_conf_list;

    my $project_list = {};
    while ( my ( $key, $path ) = each( %{$repo_cfg_lst} ) ) {
        my ($name) = $key =~ m{^project[.](.+)[.]path$};
        $project_list->{$name} = dir $path;
    }

    return $project_list;
}

sub has_repo_name {
    my ($self, $name) = @_;
    hurl 'Wrong arguments passed to has_repo_name()'
        unless $name;
    # p $self->project_list;
    # p $name;
    return 1 if first { $name eq $_ } keys %{$self->project_list};
    return 0;
}

sub has_repo_path {
    my ($self, $path) = @_;
    hurl 'Wrong arguments passed to has_repo_path()'
        unless $path;
    return 1 if first { $path->stringify eq $_ } values %{$self->project_list};
    return 0;
}

sub reload {
    my ( $self, $path ) = @_;
    my $file = file $path, $self->confname;
    print "Reloading $file...\n";
    try { $self->load($file) } catch { print "Reload config error: $_\n" };
}

sub project_list_cnt {
    my $self = shift;
    return scalar keys %{ $self->project_list };
}

=pod

Additions to the user configuration file C<sqitch.conf>:

[core]
    engine = pg
    project = flipr
[project "flipr"]
    path = /home/user/sqitch/flipr
[project "widgets"]
    path = /home/user/sqitch/widgets

The list of project names and paths and a default project name.

=cut

1;
