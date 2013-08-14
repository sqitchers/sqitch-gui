package App::Sqitch::GUI::Controller;

use Moose;
use namespace::autoclean;

use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU EVT_DIRPICKER_CHANGED>;

use Path::Class;
use File::Slurp;
use Try::Tiny;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::WxApp;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Status;
use App::Sqitch::GUI::Refresh;

use App::Sqitch::GUI::View::Dialog::Repo;

use Data::Printer;

has 'app' => (
    is         => 'ro',
    isa        => 'App::Sqitch::GUI::WxApp',
    lazy_build => 1,
);

has 'view' => (
    is      => 'ro',
    isa     => 'App::Sqitch::GUI::View',
    default => sub { shift->app->view },
);

has config => (
    is      => 'ro',
    isa     => 'App::Sqitch::GUI::Config',
    lazy    => 1,
    default => sub {
        App::Sqitch::GUI::Config->new;
    }
);

has sqitch => (
    is      => 'rw',
    isa     => 'Maybe[App::Sqitch]',
    lazy    => 1,
    builder => 'init_sqitch',
);

has status => (
    is      => 'rw',
    isa     => 'App::Sqitch::GUI::Status',
    lazy    => 1,
    default => sub {
        App::Sqitch::GUI::Status->new;
    }
);

sub log_message {
    my ($self, $msg) = @_;
    #? This should clear the control first
    Wx::LogMessage($msg);
}

sub _build_app {
    my $self = shift;
    my $app = App::Sqitch::GUI::WxApp->new();
    return $app;
}

sub init_sqitch {
    my $self = shift;

    print "Initializing Sqitch\n";

    my $opts = {};
    $opts->{config} = $self->config;

    my $sqitch;
    try {
        $sqitch = App::Sqitch::GUI::Sqitch->new($opts);
    }
    catch {
        print "Error on init: $_\n";
    };

    return $sqitch;
}

sub BUILD {
    my $self = shift;

    $self->_setup_events;
    $self->_init_observers;

    $self->log_message('Welcome to Sqitch!');

    $self->check_plan();

    return;
}

sub check_plan {
    my $self = shift;

    my $sqitch = $self->sqitch;

    # Do we have a valid configuration - plan?
    try {
        App::Sqitch::Plan->new(sqitch => $sqitch)->load;
    }
    catch {
        my $msg = "ERROR: $_";
        #$self->log_message($msg);
        print "$msg\n";
    }
    finally {
        if (@_) {
            $self->log_message('Sqitch is NOT initialized yet. Please set a valid repository path!');
            $self->status->set_state('init');
        } else {
            $self->log_message('Sqitch is initialized.');
            $self->status->set_state('idle');
        }
    };

    if ( $self->status->is_state('idle') ) {
        $self->load_change;
        $self->load_projects;
    }

    return;
}

sub _setup_events {
    my $self = shift;

    EVT_MENU $self->view->frame,
        $self->view->menu_bar->menu_admin->itm_admin->GetId,
        sub { $self->on_admin(@_) };

    # Set events for some of the commands
    # 'Revert' needs confirmation - can't use it
    foreach my $cmd ( qw(status deploy verify log) ) {
        my $btn = "btn_$cmd";
        EVT_BUTTON $self->view->frame,
            $self->view->right_side->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

    EVT_DIRPICKER_CHANGED $self->view->frame,
        $self->view->project->dpc_path->GetId, sub {
        $self->on_dpc_change(@_);
    };

    return;
}

sub _init_observers {
    my $self = shift;

    my $status = $self->status;

    $status->add_observer(
        App::Sqitch::GUI::Refresh->new( view => $self->view ) );

    return;
}

sub load_projects {
    my $self = shift;

    my $config = $self->config;
    my $sqitch = $self->sqitch;
    my $plan   = $sqitch->plan;

    # CUBRID has user not username ???
    my $user = $sqitch->engine->can('username')
        ? $sqitch->engine->username : $sqitch->engine->user;

    my %fields = (
        project       => $plan->project,
        uri           => $plan->uri,
        database      => $sqitch->engine->db_name,
        user          => $user,
        created_at    => undef,
        creator_name  => undef,
        creator_email => undef,
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->load_form_for( 'project', $field, $value );
    }

    my $repo_path = $config->repo_default_path;
    $self->view->dirpicker_write($repo_path );
    my $driver = $config->get( key => 'core.engine' );
    $self->view->combobox_write($driver);

    return;
}

sub load_change {
    my $self = shift;

    my $sqitch = $self->sqitch;
    my $plan   = $sqitch->plan;
    my $change = $plan->last;
    my $name   = $change->name;
    my $state  = $sqitch->engine->current_state( $plan->project );

    my $planned_at
        = defined $state
        ? $state->{planned_at}->as_string
        : undef;
    my $committed_at
        = defined $state
        ? $state->{committed_at}->as_string
        : undef;

    my %fields = (
        change_id       => $change->id,
        name            => $change->name,
        note            => $change->note,
        planner_name    => $change->{planner_name},
        planner_email   => $change->{planner_email},
        planned_at      => $planned_at,
        planner_name    => $state->{planner_name},
        planner_email   => $state->{planner_email},
        committed_at    => $committed_at,
        committer_name  => $state->{committer_name},
        committer_email => $state->{committer_email},
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->load_form_for( 'change', $field, $value );
    }

    $self->load_sql_for($_, $name) for qw(deploy revert verify);

    return;
}

sub execute_command {
    my ($self, $cmd) = @_;

    print "Execute '$cmd'\n";
    my $cmd_args;

    # Instantiate the command object.
    my $command = App::Sqitch::Command->load({
        sqitch  => $self->sqitch,
        command => $cmd,
        config  => $self->config,
        args    => $cmd_args,
    });

    # Execute command.
    try {
        $command->execute( @{$cmd_args} );
    }
    catch {
        local $@ = $_;
        $self->log_message($@); # HOWTO get rid of the stack trace?
                                # or better to redirect it to another Logger?
    };

    return;
}

sub load_form_for {
    my ($self, $form, $field, $value) = @_;

    my $ctrl_name = "txt_$field";
    my $ctrl = $self->view->$form->$ctrl_name;
    $self->view->control_write_e($ctrl, $value);

    return;
}

sub load_sql_for {
    my ($self, $command, $name) = @_;

    my $repo_path = $self->config->repo_default_path;
    my $sql_file  = file($repo_path, $command, "$name.sql");
    my $text = read_file($sql_file);
    my $ctrl_name = "edit_$command";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->view->control_write_s($ctrl, $text);

    return;
}

sub on_dpc_change {
    my ($self, $frame, $event) = @_;
    print "Path changed\n";
    my $new_path = $event->GetEventObject->GetPath;
    #$self->status->set_state('idle');
}

sub on_admin {
    my ($self, $frame, $event) = @_;

    my $d = App::Sqitch::GUI::View::Dialog::Repo->new(
        app      => $self->app,
        ancestor => $self,
        parent   => undef,                   # for dialogs
    );
    if ( $d->ShowModal == wxID_OK ) {
        print "OK!\n";
        return;
    }
    else {
        print "This should NOT happen!\n";
        return;
    }
}

sub config_load {
    my ($self, $name, $path) = @_;

    # Doesn't work :(

    # $self->config->repo_default_name($name);
    # $self->config->repo_default_path($path);

    # my $c_name = $self->config->repo_default_name;
    # my $c_path = $self->config->repo_default_path;

    # $self->init_sqitch;
    # $self->check_plan;

    return;
}

sub config_set_default {
    my ($self, $name, $path) = @_;
    $self->config->config_set_default($name, $path);
    return;
}

sub config_add_repo {
    my ($self, $name, $path) = @_;
    $self->config->config_add_repo($name, $path);
    return;
}

__PACKAGE__->meta->make_immutable;

1;
