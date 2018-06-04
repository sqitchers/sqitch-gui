package App::Sqitch::GUI::Model;

# ABSTRACT: The Model

use 5.010;
use Moo;
use MooX::HandlesVia;
use App::Sqitch::GUI::Types qw(
    SqitchGUIConfig
    SqitchGUIModelListDataTable
    SqitchGUIModelPlanItem
    SqitchGUIModelProjectItem
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);
use Try::Tiny;
use Path::Class;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;
use App::Sqitch::GUI::Model::ListDataTable;
use App::Sqitch::GUI::Model::ProjectItem;
use App::Sqitch::GUI::Model::PlanItem;

has 'config' => (
    is   => 'ro',
    isa  => SqitchGUIConfig,
    lazy => 1,
);

has 'current_project' => (
    is      => 'rw',
    isa     => SqitchGUIModelProjectItem,
    lazy    => 1,
    builder => '_build_current_project',
);

sub _build_current_project {
    my $self = shift;

    # At build time, the current item is the default item
    my $item = App::Sqitch::GUI::Model::ProjectItem->new;
    if ( my $name = $self->config->default_project_name ) {
        if ( my $path = $self->config->default_project_path ) {
            $item->name($name);
            $item->path($path);
        }
    }
    return $item;
}

has 'current_plan_item' => (
    is      => 'rw',
    isa     => SqitchGUIModelPlanItem,
    lazy    => 1,
    builder => '_build_current_plan_item',
);

sub _build_current_plan_item {
    my $self = shift;
    my $item = App::Sqitch::GUI::Model::PlanItem->new;
    return $item;
}

has 'project_config_issues' => (
    is          => 'rw',
    handles_via => 'Array',
    lazy        => 1,
    handles     => {
        config_has_issues => 'count',
        config_add_issue  => 'push',
        config_all_issues => 'elements',
    },
    default => sub { [] },
);

has 'default_project' => (
    is      => 'rw',
    isa     => SqitchGUIModelProjectItem,
    lazy    => 1,
    builder => '_build_default_project',
);

sub _build_default_project {
    my $self = shift;
    my $item = App::Sqitch::GUI::Model::ProjectItem->new;
    if ( my $name = $self->config->default_project_name ) {
        if ( my $path = $self->config->default_project_path ) {
            $item->name($name);
            $item->path($path);
        }
        else {
            $self->config_add_issue(
                __x 'EE The "{name}" project has no associated path and is set as default',
                name => $name );
        }
    }
    return $item;
}

has project_list => (
    is          => 'ro',
    handles_via => 'Hash',
    lazy        => 1,
    builder     => '_build_project_list',
    handles     => {
        get_project => 'get',
        has_project => 'count',
        projects    => 'kv',
    },
);

sub _build_project_list {
    my $self = shift;
    my $projects = {};
    my ( %seen_name, %seen_path );
    for my $rec ( $self->config->projects ) {
        my ( $name, $path ) = @{$rec};

        $seen_name{$name}++;
        $self->config_add_issue( __x 'EE Duplicate name found: "{name}"',
            name => $name )
            if defined $seen_name{$name} and $seen_name{$name} > 1;
        $seen_path{$path}++;
        $self->config_add_issue( __x 'EE Duplicate path found: "{path}"',
            path => $path )
            if defined $seen_path{$path} and $seen_path{$path} > 1;
        unless ( $self->is_project_path($path) ) {
            $self->config_add_issue(
                __x 'EE The "{path}" path does not look like a Sqitch project!',
                path => $path
              );
        }
        
        my $engine  = $self->get_project_engine_from_name($name);
        my $default = $self->default_project->name // q{};
        my $current = $self->current_project->name // q{};
        my $is_default = $name eq $default ? 1 : 0;
        my $is_current = $name eq $current ? 1 : 0;
        $projects->{$name} = {
            name    => $name,
            path    => $path,
            engine  => $engine,
            default => $is_default,
            current => $is_current,
        };
    }
    return $projects;
}

sub is_project_path {
    my ($self, $path) = @_;
    my $cfg_file = file $path, $self->config->confname;
    return 0 unless -f $cfg_file->stringify;
    return 1;
}

sub is_empty_path {
    my ($self, $path) = @_;
    my $dir = dir $path;
    my $is_empty = $dir->stat && !$dir->children; # thanks tobyink from PM ;)
    return $is_empty;
}

sub get_project_engine_from_name {
    my ($self, $name) = @_;
    my $path = $self->config->get_project($name);
    return $self->get_project_engine_from_path($path);
}

sub get_project_engine_from_path {
    my ($self, $path) = @_;
    my $cfg_file = file $path, $self->config->confname;
    if ( -f $cfg_file ) {
        my $cfg_href = Config::GitLike->load_file($cfg_file);
        if ( exists $cfg_href->{'core.engine'} ) {
            my $engine_code = $cfg_href->{'core.engine'};
            my $engine_name = $self->config->get_engine_name($engine_code);
            return $engine_name;
        }
    }
    return;
}

#-- List data

has 'project_list_data' => (
    is      => 'ro',
    isa     => SqitchGUIModelListDataTable,
    default => sub {
        return App::Sqitch::GUI::Model::ListDataTable->new;
    },
);

has 'plan_list_data' => (
    is      => 'ro',
    isa     => SqitchGUIModelListDataTable,
    default => sub {
        return App::Sqitch::GUI::Model::ListDataTable->new;
    },
);

#-- Lists meta data

sub project_dlg_list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 25,
            type  => 'int',
        },
        {   field => 'name',
            label => __ 'Name',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'path',
            label => __ 'Path',
            align => 'left',
            width => 327,
            type  => 'str',
        },
    ];
}

sub project_list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 25,
            type  => 'int',
        },
        {   field => 'name',
            label => __ 'Name',
            align => 'left',
            width => 160,
            type  => 'str',
        },
        {   field => 'path',
            label => __ 'Path',
            align => 'left',
            width => 415,
            type  => 'str',
        },
        {   field => 'engine',
            label => __ 'Engine',
            align => 'left',
            width => 100,
            type  => 'str',
        },
        {   field => 'default',
            label => __ 'Default',
            align => 'center',
            width => 70,
            type  => 'str',
        },
        {   field => 'current',
            label => __ 'Current',
            align => 'center',
            width => 70,
            type  => 'str',
        },
    ];
}

sub plan_list_meta_data {
    return [
        {   field => 'recno',
            label => '#',
            align => 'center',
            width => 35,
            type  => 'int',
        },
        {   field => 'name',
            label => __ 'Name',
            align => 'left',
            width => 130,
            type  => 'str',
        },
        {   field => 'create_time',
            label => __ 'Create time',
            align => 'left',
            width => 160,
            type  => 'str',
        },
        {   field => 'creator',
            label => __ 'Creator',
            align => 'center',
            width => 110,
            type  => 'str',
        },
        {   field => 'description',
            label => __ 'Description',
            align => 'left',
            width => 260,
            type  => 'str',
        },
        {   field => 'current',
            label => __ 'Current',
            align => 'center',
            width => 60,
            type  => 'str',
        },
        {   field => 'status',
            label => __ 'Status',
            align => 'center',
            width => 60,
            type  => 'str',
        },
    ];
}

1;

__END__

=encoding utf8

=head1 DESCRIPTION

The Model.

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head2 C<config>

=head2 C<current_project>

=head2 C<project_config_issues>

=head2 C<default_project>

=head2 C<project_list>

=head2 C<target>

=head2 C<plan>

=head2 C<project_list_data>

=head2 C<plan_list_data>

=head1 METHODS

=head2 C<is_project_path>

Return true if the path contains a Sqitch project.

XXX: Is enough to check if it has a sqitch.conf file in it?

=head2 C<get_project_engine_from_name>

=head2 C<get_project_engine_from_path>

=head2 C<sqitch>

=head2 C<project_dlg_list_meta_data>

=head2 C<project_list_meta_data>

=head2 C<plan_list_meta_data>

=cut
