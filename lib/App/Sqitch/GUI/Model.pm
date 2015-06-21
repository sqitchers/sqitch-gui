package App::Sqitch::GUI::Model;

# ABSTRACT: The Model

use 5.010;
use Moo;
use MooX::HandlesVia;
use App::Sqitch::GUI::Types qw(
    Dir
    Int
    Maybe
    Sqitch
    SqitchPlan
    SqitchGUIConfig
    SqitchGUIModelListDataTable
    SqitchGUIModelProjectItem
    SqitchGUITarget
    Str
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);
use Try::Tiny;
use Path::Class;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;
use App::Sqitch::GUI::Model::ListDataTable;
use App::Sqitch::GUI::Model::ProjectItem;

has 'config' => (
    is   => 'ro',
    isa  => SqitchGUIConfig,
    lazy => 1,
);

has 'current_project' => (
    is      => 'rw',
    isa     => SqitchGUIModelProjectItem,
    lazy    => 1,
    default => sub {
        return App::Sqitch::GUI::Model::ProjectItem->new;
    }
);

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
                __x '[EE] The "{name}" project has no asociated path',
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
        $self->config_add_issue( __x '[EE] Duplicate name found: "{name}"',
            name => $name )
            if defined $seen_name{$name} and $seen_name{$name} > 1;
        $seen_path{$path}++;
        $self->config_add_issue( __x '[EE] Duplicate path found: "{path}"',
            path => $path )
            if defined $seen_path{$path} and $seen_path{$path} > 1;

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

sub get_project_engine_from_name {
    my ($self, $name) = @_;
    my $path = $self->config->get_project($name);
    return $self->get_project_engine_from_path($path);
}

sub get_project_engine_from_path {
    my ($self, $path) = @_;
    my $item_cfg_file = file $path, $self->config->confname;
    if ( -f $item_cfg_file ) {
        my $item_cfg_href = Config::GitLike->load_file($item_cfg_file);
        my $engine_code = $item_cfg_href->{'core.engine'};
        my $engine_name = $self->config->get_engine_name($engine_code);
        return $engine_name;
    }
    else {
        hurl "File not found: $item_cfg_file";
    }
    return;
}

sub sqitch {
    my $self = shift;
    my $opts = {};                           # options for Sqitch
    my $sqitch = try {
        App::Sqitch::GUI::Sqitch->new( {
            options => $opts,
            config  => $self->config,
        } );
    }
    catch {
        say "Error on Sqitch initialization: $_";
        return;
    };
    return $sqitch;
}

has 'target' => (
    is      => 'ro',
    isa     => Maybe[SqitchGUITarget],
    lazy    => 1,
    builder => '_build_target',
);

sub _build_target {
    my $self = shift;
    my $target = try {
        App::Sqitch::GUI::Target->new( sqitch => $self->sqitch );
    }
    catch {
        say "Error on Target initialization: $_";
        return;
    };
    return $target;
}

has 'plan' => (
    is      => 'ro',
    isa     => Maybe[SqitchPlan],
    lazy    => 1,
    builder => '_build_plan',
);

sub _build_plan {
    my $self = shift;
    my $plan = try {
        App::Sqitch::Plan->new(
            sqitch => $self->sqitch,
            target => $self->target,
        );
    }
    catch {
        say "Error on Target initialization: $_";
        return;
    };
    return $plan;
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
            width => 326,
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
            width => 100,
            type  => 'str',
        },
        {   field => 'path',
            label => __ 'Path',
            align => 'left',
            width => 345,
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
            width => 160,
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
            width => 245,
            type  => 'str',
        },
    ];
}

1;
