package App::Sqitch::GUI::Controller;

use Moose;
use namespace::autoclean;

use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU>;
use Path::Class;
use File::Slurp;
use Try::Tiny;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::WxApp;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Status;
use App::Sqitch::GUI::Refresh;

#use Data::Printer;

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
    is      => 'ro',
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

    my $opts = {};
    $opts->{config} = $self->config;
    my $sqitch;
    try {
        $sqitch = App::Sqitch::GUI::Sqitch->new($opts);
    };

    return $sqitch;
}

sub BUILD {
    my $self = shift;

    $self->_setup_events;
    $self->_init_observers;

    $self->log_message('Welcome to Sqitch!');

    my $sqitch = $self->sqitch;

    # Do we have a valid configuration - plan?
    try {
        App::Sqitch::Plan->new(sqitch => $sqitch)->load;
    }
    catch {
        print "Err: $_\n";
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

    # Set events for some of the commands
    # 'Revert' needs confirmation - can't use it
    foreach my $cmd ( qw(status deploy verify) ) {
        my $btn = "btn_$cmd";
        EVT_BUTTON $self->view->frame,
            $self->view->right_side->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

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

    my %fields = (
        project       => $plan->project,
        uri           => $plan->uri,
        database      => $sqitch->engine->db_name,
        user          => $sqitch->engine->username,
        created_at    => undef,
        creator_name  => undef,
        creator_email => undef,
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->load_form_for( 'project', $field, $value );
    }

    my $repo_path = $config->repository_path;
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

    my $repo_path = $self->config->repository_path;
    my $sql_file  = file($repo_path, $command, "$name.sql");
    my $text = read_file($sql_file);
    my $ctrl_name = "edit_$command";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->view->control_write_s($ctrl, $text);

    return;
}

__PACKAGE__->meta->make_immutable;

1;
