package App::Sqitch::GUI::Controller;

use 5.010;
use strict;
use warnings;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    HashRef
    Maybe
    Object
    Sqitch
    SqitchGUIWxApp
    SqitchGUIConfig
    SqitchGUIStatus
    SqitchGUIDialogStatus
    SqitchGUIView
    WxWindow
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw<:everything>;
use Wx::Event qw(
    EVT_BUTTON
    EVT_CLOSE
    EVT_MENU
);
use Path::Class;
use File::Slurp;
use Try::Tiny;
use App::Sqitch::X qw(hurl);

use App::Sqitch::GUI::WxApp;
use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Status;
use App::Sqitch::GUI::Refresh;

use App::Sqitch::GUI::View::Dialog::Status;
use App::Sqitch::GUI::View::Dialog::Refresh;
use App::Sqitch::GUI::View::Dialog::Projects;

has 'app' => (
    is      => 'ro',
    isa     => SqitchGUIWxApp,
    lazy    => 1,
    builder => '_build_app',
);

sub _build_app {
    my $self = shift;
    say "_build_app";
    my $app  = App::Sqitch::GUI::WxApp->new( config => $self->config );
    return $app;
}

has 'view' => (
    is      => 'ro',
    isa     => SqitchGUIView,
    default => sub { shift->app->view },
);

has config => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
    builder => 'init_config',
);

has sqitch => (
    is      => 'rw',
    isa     => Maybe[Sqitch],
    lazy    => 1,
    builder => 'init_sqitch',
);

has status => (
    is      => 'rw',
    isa     => SqitchGUIStatus,
    lazy    => 1,
    default => sub {
        return App::Sqitch::GUI::Status->new;
    }
);

has dlg_status => (
    is      => 'rw',
    isa     => SqitchGUIDialogStatus,
    lazy    => 1,
    default => sub {
        return App::Sqitch::GUI::View::Dialog::Status->new;
    }
);

sub log_message {
    my ($self, $msg) = @_;
    #? This should clear the control first
    Wx::LogMessage($msg);
}

sub init_config {
    my $self = shift;

    my $config;
    try {
        $config = App::Sqitch::GUI::Config->new;
    }
    catch {
        print "Config error: $_\n";
    };

    # TODO:
    # Has a repo list?
    # + yes
    #   + has a default repo?
    #     + yes => load it
    #     - no  => show dialog to set default
    # - no
    #   - show dialog to add new repo

    # Are any repositories configured?
    return $config if $config->project_list_cnt == 0;

    # Load the local configuration file
    if ( $config->repo_default_name ) {
        my $repo_config = $config->repo_default_path;
        if ($repo_config) {
            $config->reload($repo_config);
        }
        else {
            $self->log_message('No default path in config!');
        }
    }

    print 'cfg: user_file:  ', $config->user_file, "\n";
    print 'cfg: local_file: ', $config->local_file, "\n";

    print "\nCONFIG:\n";
    print "---\n";
    print scalar $config->dump;
    print "---\n";
    print "\n";

    return $config;
}

sub init_sqitch {
    my $self = shift;
say "INIT_sqitch";
    my $opts = {};
    my $sqitch;
    try {
        $sqitch = App::Sqitch::GUI::Sqitch->new( {
            options => $opts,
            config  => $self->config,
        } );
    }
    catch {
        print "Error on Sqitch initialization: $_\n";
    };

    return $sqitch;
}

sub BUILD {
    my $self = shift;

    $self->_setup_events;
    $self->_init_observers;

    $self->log_message('Welcome to Sqitch!');

    $self->load_sqitch_plan();

    return;
}

sub load_sqitch_plan {
    my $self = shift;

    my $sqitch = $self->sqitch;

    # Do we have a valid configuration - plan?
    my $target;
    try {
        # App::Sqitch::Plan->new( sqitch => $sqitch )->load;
        $target = App::Sqitch::GUI::Target->new( sqitch => $sqitch );
    }
    catch {
        my $msg = "ERROR: $_";
        print "Catch: $msg\n";
    }
    finally {
        if (@_) {
            $self->log_message(__ 'Sqitch is NOT initialized yet. Please add a project path using the Admin menu.');
            $self->status->set_state('init');
        } else {
            $self->status->set_state('idle');
        }
    };

    if ( $self->status->is_state('idle') ) {
        try {
            # $self->populate_project($target);
            # $self->populate_change($target);
            # $self->populate_plan;
        }
        catch {
            $self->log_message(__ 'Error' . ': '. $_);
        };
    }

    return;
}

sub _setup_events {
    my $self = shift;

    # EVT_MENU $self->view->frame,
    #     $self->view->menu_bar->menu_admin->itm_admin->GetId,
    #     sub { $self->on_admin(@_) };

    # EVT_MENU $self->view->frame,
    #     $self->view->menu_bar->menu_app->itm_quit->GetId,
    #     sub { $self->on_quit(@_) };

    # Set events for some of the commands
    # 'Revert' needs confirmation - can't use it, yet
    foreach my $cmd ( qw(status deploy verify log) ) {
        my $btn = "btn_$cmd";
        EVT_BUTTON $self->view->frame,
            $self->view->right_side->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

    EVT_BUTTON $self->view->frame,
        $self->view->right_side->btn_quit->GetId,
        sub { $self->on_quit(@_) };

    return;
}

sub _init_observers {
    my $self = shift;

    $self->status->add_observer(
        App::Sqitch::GUI::Refresh->new( view => $self->view ) );

    return;
}

sub populate_project {
    my ($self, $target) = @_;

    my $config = $self->config;
    my $sqitch = $self->sqitch;
    my $engine = $target->engine;
    my $plan   = $target->plan;

    hurl "No plan?" unless $plan and $plan->isa('App::Sqitch::Plan');

    my $dbname = $engine->uri->dbname;

    my $fields = {
        project  => $plan->project             // 'unknown',
        uri      => $plan->uri                 // 'unknown',
        database => $dbname,
        user     => $engine->uri->user         // 'unknown',
        path     => $config->repo_default_path // 'unknown',
        engine   => $engine->uri->engine       // 'unknown',
        created_at    => undef,
        creator_name  => undef,
        creator_email => undef,
    };
    while ( my ( $field, $value ) = each %{$fields} ) {
        $self->load_form_for( 'project', $field, $value );
    }

    return;
}

sub populate_change {
    my ($self, $target) = @_;

    my $sqitch = $self->sqitch;
    my $plan   = $target->plan;
    my $change = $plan->last;

    hurl "No change plan!"
        unless $change and $change->isa('App::Sqitch::Plan::Change');

    my $name  = $change->name;
    my $state = $sqitch->engine->current_state( $plan->project );

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

sub populate_plan {
    my $self = shift;

    my $config = $self->config;
    my $sqitch = $self->sqitch;
    my $plan   = $sqitch->plan;

    # Search the changes. (from ...Sqitch::Command::plan)
    my $iter = $plan->search_changes();
    my @recs;
    while ( my $change = $iter->() ) {
        push @recs, {
            name        => $change->name,
            description => $change->note,
            create_time => $change->timestamp,
            creator     => $change->planner_name,
        };
    }

    $self->view->plan->list_ctrl->populate(\@recs);

    return;
}

sub execute_command {
    my ($self, $cmd, @cmd_args) = @_;

    # Instantiate the command object.
    my $command = App::Sqitch::Command->load({
        sqitch  => $self->sqitch,
        command => $cmd,
        config  => $self->config,
        args    => \@cmd_args,
    });

    # Execute command.
    try {
        $command->execute(@cmd_args);
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

    hurl __ 'Wrong arguments passed to load_form_for()'
        unless defined $field;

    my $ctrl_name = "txt_$field";
    my $ctrl = $self->view->$form->$ctrl_name;
    $self->view->control_write_e($ctrl, $value);

    return;
}

sub load_sql_for {
    my ($self, $command, $name) = @_;

    my $repo_path = $self->config->repo_default_path;
    my $sql_file  = file $repo_path, $command, "$name.sql";
    my $text = read_file($sql_file);
    my $ctrl_name = "edit_$command";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->view->control_write_s($ctrl, $text);

    return;
}

# sub on_dpc_change {
#     my ($self, $frame, $event) = @_;
#     print "Path changed\n";
#     my $new_path = $event->GetEventObject->GetPath;
#     #$self->status->set_state('idle');
# }

sub on_quit {
    my ($self, $frame, $event) = @_;
    print "Normal exit.\n";
    $frame->Close(1);
}

sub on_admin {
    my ($self, $frame, $event) = @_;

    my $dialog = App::Sqitch::GUI::View::Dialog::Projects->new(
        app      => $self->app,
        ancestor => $self,
        parent   => undef,                   # for dialogs
    );

    $self->dlg_status->add_observer(
        App::Sqitch::GUI::View::Dialog::Refresh->new( dialog => $dialog ) );

    $self->dlg_status->set_state('sele');

    if ( $dialog->ShowModal == wxID_OK ) {
        $self->dlg_status->remove_all_observers;
        return;
    }
    else {
        hurl __ 'This should NOT happen!';
    }

    return;
}

sub config_reload {
    my ($self, $name, $path) = @_;

    print "Reload config...\n";
    print ": $name, $path\n";

    $self->config->reload;

    $self->config->repo_default_name($name);
    $self->config->repo_default_path($path);

    my $c_name = $self->config->repo_default_name;
    my $c_path = $self->config->repo_default_path;

    $self->init_sqitch;
    $self->load_sqitch_plan;

    return;
}

sub config_set_default {
    my ($self, $name) = @_;
    my @cmd = qw(config --user);
    $self->execute_command(@cmd, "core.project", $name);
    return 1;
}

sub config_edit_repo {
    my ($self, $name, $path) = @_;
    my @cmd = qw(config --user);
    $self->execute_command(@cmd, "project.${name}.path", $path);
    return 1;
}

sub config_remove_repo {
    my ( $self, $name, $path, $is_default ) = @_;
    my @cmd = qw(config --user --remove-section);
    $self->execute_command(@cmd, "project.${name}");
    $self->execute_command(@cmd, "project") if $is_default;
    return 1;
}

sub config_save_local {
    my ( $self, $engine, $database ) = @_;
    my @cmd = qw(config --local);
    $self->execute_command(@cmd, "core.${engine}.db_name", $database);
    return 1;
}

1;
