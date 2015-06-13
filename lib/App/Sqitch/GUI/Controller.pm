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
    SqitchGUIModel
    SqitchGUIView
    WxWindow
);
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw<:everything>;
use Wx::Event qw(
    EVT_BUTTON
    EVT_CLOSE
    EVT_MENU
    EVT_TIMER
);
use Path::Class;
use File::Slurp;
use Try::Tiny;
use App::Sqitch::X qw(hurl);

use App::Sqitch::GUI::Model;
use App::Sqitch::GUI::WxApp;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Status;
use App::Sqitch::GUI::Refresh;

use App::Sqitch::GUI::View::Dialog::Projects;
use App::Sqitch::GUI::View::Dialog::Status;
use App::Sqitch::GUI::View::Dialog::Refresh;

use Data::Printer;

has 'app' => (
    is      => 'ro',
    isa     => SqitchGUIWxApp,
    lazy    => 1,
    builder => '_build_app',
);

sub _build_app {
    my $self = shift;
    return App::Sqitch::GUI::WxApp->new( config => $self->config );
}

has 'view' => (
    is      => 'ro',
    isa     => SqitchGUIView,
    default => sub {
        my $self = shift;
        return $self->app->view;
    },
);

has 'model' => (
    is      => 'ro',
    isa     => SqitchGUIModel,
    builder => '_build_model',
);

sub _build_model {
    my $self = shift;
    return App::Sqitch::GUI::Model->new(
        config => $self->config,
        sqitch => $self->sqitch,
    );
}

has config => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config {
    my $self = shift;
    my $config;
    try {
        $config = App::Sqitch::GUI::Config->new;
    }
    catch {
        __x '[EE] Configuration error: "{error}"', error => $_;
    };
    return $config;
}

has 'status' => (
    is      => 'rw',
    isa     => SqitchGUIStatus,
    lazy    => 1,
    default => sub {
        return App::Sqitch::GUI::Status->new;
    }
);

has 'dlg_status' => (
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

sub sqitch {
    my $self = shift;

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

    $self->load_sqitch_project;

    return;
}

sub load_sqitch_project {
    my $self = shift;
    $self->status->set_state('idle');

    if ( my $proj_cnt = $self->config->has_project ) {
        my ($name, $path) = $self->validate_projects_conf;
        if ( $name and $path ) {
            $self->config_reload( $name, $path );
            $self->populate_project;
            #$self->populate_plan;
            #$self->populate_change;
        }
    }
    else {
        $self->log_message('Add a project...');
        $self->log_message('Opening a dialog...');
        my $timer = Wx::Timer->new( $self->view->frame, 1 );
        $timer->Start( 2000, 1 );    # one shot
        EVT_TIMER $self->view->frame, 1, sub {
            $self->on_admin(@_);
            #say "loyding: ", $self->model->selected_name;
            # my $project_cfg = $self->model->get_project('sqitch-s2i2');
            # $self->config_reload('sqitch-s2i2', $project_cfg);
        };
    }

    return;
}

sub validate_projects_conf {
    my $self = shift;
    if ( my $proj_cnt = $self->config->has_project ) {
        $self->log_message(
            __nx 'Found a project', 'Found {count} projects',
            $proj_cnt, count => $proj_cnt
        );

        # Do we have a valid config
        my ( %seen_name, %seen_path );
        foreach my $rec ( $self->config->projects ) {
            my ( $name, $path ) = ( $rec->[0], $rec->[1] );
            $seen_name{$name}++;
            $self->log_message( __x 'Duplicate name found: "{name}"',
                name => $name )
                if defined $seen_name{$name} and $seen_name{$name} > 1;
            $seen_path{$path}++;
            $self->log_message( __x 'Duplicate path found: "{path}"',
                path => $path )
                if defined $seen_path{$path} and $seen_path{$path} > 1;
        }

        # Do we have a default project?
        if ( my $name = $self->config->default_project_name ) {
            if ( my $path = $self->config->default_project_path ) {
                return ( $name, $path );
            }
            else {
                $self->log_message(
                    __x '[EE] The "{name}" project has no asociated path',
                    name => $name );
            }
        }
    }
    return;
}

sub load_config {
    my $self = shift;

    # Load the local configuration file
    if ( $self->config->default_project_name ) {
        my $project_path = $self->config->default_project_path;
        if ( $project_path ) {
            $self->config->reload($project_path);
        }
        else {
            $self->log_message('Wrong default path in config!');
            return;
        }
    }

    print 'cfg: user_file:  ', $self->config->user_file, "\n";
    print 'cfg: local_file: ', $self->config->local_file, "\n";

    print "\nCONFIG:\n";
    print "---\n";
    print scalar $self->config->dump;
    print "---\n";
    print "\n";

    return;
}

sub _setup_events {
    my $self = shift;

    my $menu_bar = $self->view->frame->GetMenuBar;

    EVT_MENU $self->view->frame,
        $menu_bar->FindItem(2001),
        sub { $self->on_admin(@_) };        # 2001 -> GUI::Wx::Menubar

    EVT_MENU $self->view->frame,
        $menu_bar->FindItem(wxID_EXIT),
        sub { $self->on_quit(@_) };

    # Set events for some of the commands
    # 'Revert' needs confirmation - can't use it, yet
    foreach my $cmd ( qw(status deploy verify log) ) {
        my $btn = "btn_$cmd";
        EVT_BUTTON $self->view->frame,
            $self->view->right_side->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

    #-- Quit
    $self->view->event_handler_for_tb_button( 'tb_qt',
        sub { $self->on_quit(@_) },
    );

    #-- Projects
    $self->view->event_handler_for_tb_button( 'tb_pj',
        sub { $self->on_admin(@_) },
    );

    return;
}

sub _init_observers {
    my $self = shift;

    $self->status->add_observer(
        App::Sqitch::GUI::Refresh->new( view => $self->view ) );

    return;
}

sub populate_project {
    my $self = shift;

    my $config = $self->config;
    my $engine = $self->model->target->engine;
    my $plan   = $self->model->target->plan;
    # hurl "No plan?" unless $plan and $plan->isa('App::Sqitch::Plan');
    # my $dbname = $engine->uri->dbname;

    my $fields = {
        project  => $plan->project                // 'unknown',
        uri      => $plan->uri                    // 'unknown',
        database => $engine->uri->dbname          // 'unknown',
        user     => $engine->uri->user            // 'unknown',
        path     => $config->default_project_path // 'unknown',
        engine   => $engine->uri->engine          // 'unknown',
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
    my $self = shift;

    my $engine = $self->model->target->engine;
    my $plan   = $self->model->target->plan;
    my $change = $plan->last;
    my $name   = $change->name;
    my $state  = $engine->current_state( $plan->project );

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

    my $plan   = $self->model->target->plan;

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
    $self->view->plan->populate(\@recs);

    return;
}

sub execute_command {
    my ($self, $cmd, @cmd_args) = @_;

    # Instantiate the command object.
    my $command = App::Sqitch::Command->load({
        sqitch  => $self->model->sqitch,
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

    my $repo_path = $self->config->default_project_path;
    my $sql_file  = file $repo_path, $command, "$name.sql";
    my $text = read_file($sql_file);
    my $ctrl_name = "edit_$command";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->view->control_write_s($ctrl, $text);

    return;
}

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

    $name //= $self->model->selected_name;
    $path //= $self->model->selected_path;

    $self->log_message( __x 'Loading the "{name}" project', name => $name );

    $self->config->reload($path);

    print 'cfg: user_file:  ', $self->config->user_file, "\n";
    print 'cfg: local_file: ', $self->config->local_file, "\n";
    # print "\nCONFIG:\n";
    # print "---\n";
    # print scalar $self->config->dump;
    # print "---\n";
    # print "\n";

    $self->config->default_project_name($name);
    $self->config->default_project_path($path);

    my $c_name = $self->config->default_project_name;
    my $c_path = $self->config->default_project_path;

    say "Loading: $c_name $c_path";

    $self->populate_project;

    return;
}

sub config_set_default {
    my ($self, $name) = @_;
    my @cmd = qw(config --user);
    $self->execute_command(@cmd, "core.project", $name);
    return 1;
}

sub config_edit_project {
    my ($self, $name, $path) = @_;
    my @cmd = qw(config --user);
    $self->execute_command(@cmd, "project.${name}.path", $path);
    return 1;
}

sub config_remove_project {
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
