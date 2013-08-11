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

use Data::Printer;

has 'app' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::WxApp',
    lazy_build => 1,
);

has 'view' => (
    is      => 'rw',
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
    default => sub {
        my $self = shift;
        my $opts = {};
        $opts->{config}    = $self->config;
        #$opts->{plan_file} = 'fisier.plan';  # debug
        my $sqitch;
        try {
            $sqitch = App::Sqitch::GUI::Sqitch->new($opts);
        }
        return $sqitch;
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

sub BUILD {
    my $self = shift;

    #print scalar $self->config->dump, "\n";
    # my $local_file = $config->local_file;
    # print "Local file is $local_file\n";
    # my $user_file = $config->user_file;
    # print "User file is $user_file\n";
    #print 'Top dir is:', $self->sqitch->top_dir, "\n";
    #p $self->config->config_files;

    $self->log_message('Welcome to Sqitch!');

    my $sqitch = $self->sqitch;

    try {
        App::Sqitch::Plan->new(sqitch => $sqitch)->load;
    }
    finally {
        if (@_) {
            $self->log_message('Sqitch is NOT initialized yet. Please set a valid project path!');
        } else {
            $self->log_message('Sqitch is initialized.');
        }
    };

    $self->_setup_events();

    return;
}

sub _setup_events {
    my $self = shift;

    # Set events for some of the commands
    # Verifiy needs confirmation
    foreach my $cmd ( qw(status deploy verify) ) {
        my $btn = "btn_$cmd";
        EVT_BUTTON $self->view->frame,
            $self->view->right_side->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

    EVT_BUTTON $self->view->frame,
        $self->view->right_side->btn_deploy->GetId, sub {
            $self->execute_command('deploy');
    };

    return;
}

sub load_project {
    my $self = shift;

    my $sqitch = $self->sqitch;
    my $plan   = $sqitch->plan;
    my $change = $plan->last;
    my $name   = $change->name;

    # print "Plan:\n";
    # p $plan;
    # print "Change\n";
    # p $change;
    # my $state = $sqitch->engine->current_state( $plan->project );
    # print "State\n";
    # p $state;

    my %fields = (
        change_id       => $change->id,
        name            => $change->name,
        note            => $change->note,
        #planned_at      => $change->{planned_at}->as_string,
        planner_name    => $change->{planner_name},
        planner_email   => $change->{planner_email},
        # planned_at      => $state->{planned_at}->as_string,
        # planner_name    => $state->{planner_name},
        # planner_email   => $state->{planner_email},
        # committed_at    => $state->{committed_at}->as_string,
        # committer_name  => $state->{committer_name},
        # committer_email => $state->{committer_email},
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->load_change_for( $field, $value );
    }

    $self->load_sql_for($_, $name) for qw(deploy revert verify);

    return;
}

sub execute_command {
    my ($self, $cmd) = @_;

    print "Execute $cmd\n";
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

sub load_change_for {
    my ($self, $field, $value) = @_;

    my $ctrl_name = "txt_$field";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->control_write_e($ctrl, $value);

    return;
}

sub load_sql_for {
    my ($self, $command, $name) = @_;

    my $proj_path = $self->config->project_path;
    my $sql_file  = file($proj_path, $command, "$name.sql");
    my $text = read_file($sql_file);
    my $ctrl_name = "edit_$command";
    my $ctrl = $self->view->change->$ctrl_name;
    $self->control_write_s($ctrl, $text);

    return;
}

sub control_write_s {
    my ( $self, $control, $value, $is_append ) = @_;

    $value ||= q{};                 # empty

    $control->ClearAll unless $is_append;
    $control->AppendText($value);
    $control->AppendText("\n");
    $control->Colourise( 0, $control->GetTextLength );

    return;
}

sub control_write_e {
    my ( $self, $control, $value ) = @_;

    $control->Clear;
    $control->SetValue($value) if defined $value;

    return;
}

__PACKAGE__->meta->make_immutable;

1;
