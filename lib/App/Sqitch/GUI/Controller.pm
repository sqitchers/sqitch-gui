package App::Sqitch::GUI::Controller;

# ABSTRACT: The Controller

use 5.010;
use utf8;
use Moo;
use App::Sqitch::GUI::Types qw(
    Maybe
    Sqitch
    SqitchGUIConfig
    SqitchGUIDialogStatus
    SqitchGUIModel
    SqitchGUIOptions
    SqitchGUIStatus
    SqitchGUITarget
    SqitchGUIView
    SqitchGUIWxApp
    SqitchPlan
);
use App::Sqitch::GUI::Options;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use Wx qw(wxID_EXIT wxID_OK);
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

use App::Sqitch::GUI::WxApp;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::Status;
use App::Sqitch::GUI::Refresh;
use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;

use App::Sqitch::GUI::View::Dialog::Projects;
use App::Sqitch::GUI::View::Dialog::Status;
use App::Sqitch::GUI::View::Dialog::Refresh;

has options => (
    is      => 'ro',
    isa     => SqitchGUIOptions,
    lazy    => 1,
    builder => '_build_options',
);

sub _build_options {
    return App::Sqitch::GUI::Options->new_with_options;
}

has config => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config {
    my $self   = shift;
    my $config = try {
        App::Sqitch::GUI::Config->new;
    }
    catch {
        hurl controller => __x 'EE Configuration error: "{error}"',
            error => $_;
    };
    return $config;
}

has 'model' => (
    is      => 'ro',
    isa     => SqitchGUIModel,
    lazy    => 1,
    builder => '_build_model',
);

sub _build_model {
    my $self  = shift;
    my $model = try {
        App::Sqitch::GUI::Model->new(
            config => $self->config,
        );
    }
    catch {
        hurl model => __x 'EE Model error: "{error}"', error => $_;
    };
    return $model;
}

has 'app' => (
    is       => 'ro',
    isa      => SqitchGUIWxApp,
    lazy     => 1,
    required => 1,
    builder  => '_build_app',
);

sub _build_app {
    my $self = shift;
    return App::Sqitch::GUI::WxApp->new(
        config => $self->config,
        model  => $self->model,
    );
}

has 'view' => (
    is      => 'ro',
    isa     => SqitchGUIView,
    default => sub {
        my $self = shift;
        return $self->app->view;
    },
);

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

###

has 'sqitch' => (
    is      => 'ro',
    isa     => Maybe[Sqitch],
    lazy    => 1,
    clearer => 1,                    # creates clear_sqitch.
    builder => '_build_sqitch',
);

sub _build_sqitch {
    my $self = shift;
    my $opts = {};                           # options for Sqitch
    my $sqitch = try {
        App::Sqitch::GUI::Sqitch->new( {
            options    => $opts,
            config     => $self->config,
            controller => $self,
        } );
    }
    catch {
        hurl "Error on Sqitch initialization: $_";
    };
    return $sqitch;
}

has 'target' => (
    is      => 'ro',
    isa     => Maybe [SqitchGUITarget],
    lazy    => 1,
    clearer => 1,                            # creates clear_target
    builder => '_build_target',
);

sub _build_target {
    my $self   = shift;
    my $target = try {
        App::Sqitch::GUI::Target->new(
            sqitch  => $self->sqitch,
            top_dir => $self->config->current_project_path,
        );
    }
    catch {
        hurl "Error on Target initialization: $_";
    };
    return $target;
}

has 'plan' => (
    is      => 'ro',
    isa     => Maybe[SqitchPlan],
    lazy    => 1,
    clearer => 1,                    # creates clear_plan.
    default => sub {
        my $self = shift;
        return $self->target->plan;
    },
);

###

sub log_message {
    my ($self, $msg) = @_;
    my $newline = ( $msg =~ /\.\./msg ) ? 0 : 1;
    $self->view->log_message($msg, $newline);
    return;
}

sub BUILD {
    my $self = shift;
    $self->_setup_events;
    $self->status->add_observer(
        App::Sqitch::GUI::Refresh->new( view => $self->view ) );
    $self->log_message('II Welcome to Sqitch (GUI)!');
    my $timer = Wx::Timer->new( $self->view->frame, 1 );
    $timer->Start( 100, 1 );    # one shot
    EVT_TIMER $self->view->frame, 1, sub {
        $self->prepare_projects;
    };
    return;
}

sub populate_list {
    my ($self, $list_data, $list_meta_data, $record_ref) = @_;
    my $row = 0;
    foreach my $rec ( @{$record_ref} ) {
        my @row_data = ();
        foreach my $meta ( @{$list_meta_data} ) {
            my $field = $meta->{field};
            my $value
                = $field eq q{}     ? q{}
                : $field eq 'recno' ? ( $rec->{$field} // $row + 1 )
                :                     ( $rec->{$field} // q{} );
            $value = $value->stringify
                if ref $value and $value->can('stringify');
            $value = $value->as_string
                if ref $value and $value->can('as_string');
            push @row_data, $value;
        }
        $list_data->add_row(@row_data);
        $row++;
    }
    return;
}

sub prepare_projects {
    my $self = shift;
    $self->status->set_state('idle');

    if ( my $proj_cnt = $self->config->has_project ) {
        $self->populate_project_list;
        $self->load_sqitch_project;
    }
    else {
        $self->log_message('WW Add a project');
        $self->log_message('WW Opening the dialog');
        my $timer = Wx::Timer->new( $self->view->frame, 1 );
        $timer->Start( 2000, 1 );    # one shot
        EVT_TIMER $self->view->frame, 1, sub {
            $self->on_admin(@_);
            $self->load_sqitch_project;
        };
    }

    return;
}

sub load_sqitch_project {
    my $self = shift;

    my $proj_cnt = $self->config->has_project;
    if ($proj_cnt) {
        $self->log_message(
            __nx 'II OK, found a project', 'II Found {count} projects',
            $proj_cnt, count => $proj_cnt ) if $self->options->verbose;
    }
    else {
        return;
    }

    # Configuration issues?
    foreach my $item ( $self->model->config_all_issues ) {
        $self->log_message($item);
    }

    # Load the default == current project
    my $name = $self->model->current_project->name;
    my $path = $self->model->current_project->path;
    if ( $name and $path ) {
        if ( $self->load_project_from_path($path) ) {
            my $index = $self->default_project_item;
            $self->mark_item('project', $index, 5);
            $self->model->current_project->item($index);
            $self->view->get_project_list_ctrl->set_selection($index);
        }
    }
    else {
        $self->log_message(
            __nx 'II No valid default project, select the project and load it',
                 'II No valid default project, select a project and load it',
            $proj_cnt );
    }

    return;
}

sub default_project_item {
    my $self  = shift;
    my $index = 0;
    my $default_item;
    foreach my $item ( $self->model->project_list_data->get_col(4) ) {
        if ( $item->name eq __ 'Yes' ) {
            $self->model->default_project->item($index);
            $default_item = $index;
            last;
        }
        $index++;
    }
    return $default_item;
}

sub load_project_item {
    my $self = shift;
    my $item = $self->view->get_project_list_ctrl->get_selection;
    my $name = $self->model->project_list_data->get_value($item, 1);
    my $path = $self->model->project_list_data->get_value($item, 2);
    unless ( $name and $path ) {
        $self->log_message(
            __ 'EE Something went wrong, no project "name" and path"' );
        return;
    }
    if ( $self->load_project_from_path($path) ) {
        $self->model->current_project->item($item);
        $self->model->current_project->name($name);
        $self->model->current_project->path(dir $path);
        $self->mark_item('project', $item, 5);
    }
    return;
}

sub load_plan_list_item {
    my $self = shift;
    my $item = $self->view->get_plan_list_ctrl->get_selection;
    my $name = $self->model->plan_list_data->get_value($item, 1);
    $self->load_change_item($item);
    $self->model->current_plan_item->item($item);
    $self->model->current_plan_item->name($name);
    $self->mark_item('plan', $item, 5);
    return;
}

sub load_change_item {
    my ($self, $item) = @_;
    my $engine = $self->target->engine;
    my $plan   = $self->plan;
    $plan->position($item);
    $self->log_message( __x 'II Current plan item is {poz}',
        poz => $plan->position )
        if $self->options->verbose;
    $self->clear_change_form;
    my $change = $plan->current;
    $self->load_change($change);
}

sub load_project_from_path {
    my ($self, $path) = @_;

    unless ( $self->model->is_project_path($path) ) {
        $self->log_message(
            __x 'WW The "{path}" path does not look like a Sqitch project',
            path => $path,
        );
        return;
    }

    # TODO: This should be not necessary, but it is (is it? XXX)
    chdir $path
      or $self->log_message( __x 'II Can not cd to {path}"', path => $path );

    my $status_ok = try {
        $self->config->reload($path);
        1;
    }
    catch {
        $self->catch_init_errors($_);
        return undef;
    };
    $self->config_dump if $self->options->debug;

    return unless $status_ok;

    $self->clear_target;
    $self->clear_sqitch;
    $self->clear_project_form;
    $self->clear_plan;
    $self->clear_plan_form;
    $self->clear_change_form;

    # Fill the forms
    if ( my $name = $self->populate_project_form ) {
        $self->log_message(
            __x 'II Loading the "{name}" project', name => $name );
        $self->populate_plan_form;
        $self->populate_change_form;
        $self->view->project->btn_load->Enable(0);
    }

    return 1;
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
            $self->view->right->$btn->GetId, sub {
                $self->execute_command($cmd);
            };
    }

    # The "Default" button from the Project panel
    EVT_BUTTON $self->view->frame,
        $self->view->project->btn_default->GetId, sub {
            $self->set_project_default;
        };

    # The "Load" button from the Project panel
    EVT_BUTTON $self->view->frame,
        $self->view->project->btn_load->GetId, sub {
            $self->load_project_item;
        };

    # The "Load" button from the Plan panel
    EVT_BUTTON $self->view->frame,
        $self->view->plan->btn_load->GetId, sub {
            $self->load_plan_list_item;
        };

    #-- Quit
    $self->view->event_handler_for_tb_button( 'tb_qt',
        sub { $self->on_quit(@_) },
    );

    #-- Projects
    $self->view->event_handler_for_tb_button( 'tb_pj',
        sub { $self->on_admin(@_) },
    );

    #-- Projects list
    $self->view->event_handler_for_list(
        $self->view->get_project_list_ctrl,
        sub { $self->_on_project_listitem_selected(@_) },
    );

    #-- Plan list
    $self->view->event_handler_for_list(
        $self->view->get_plan_list_ctrl,
        sub { $self->_on_plan_listitem_selected(@_) },
    );

    return;
}

sub populate_project_list {
    my $self = shift;
    my @projects;
    for my $rec ( $self->model->projects ) {
        my ($name, $attrib) = @{$rec};
        my $default_label   = $attrib->{default} ? __('Yes') : q();
        push @projects, {
            name    => $name,
            path    => $attrib->{path},
            engine  => $attrib->{engine},
            default => $default_label,
            current => q(),
        };
    }
    $self->populate_list(
        $self->model->project_list_data,
        $self->model->project_list_meta_data,
        \@projects,
    );
    $self->view->get_project_list_ctrl->RefreshList;
    return;
}

sub populate_project_form {
    my $self = shift;
    my $config = $self->config;

    my $plan = try { $self->plan }
    catch {
        $self->catch_init_errors($_);
        return undef;
    };
    return unless $plan;
    my $project = try { $plan->project }
    catch {
        $self->catch_init_errors($_);
        return undef;
    };
    return unless $project;
    my $engine = try { $self->target->engine }
    catch {
        $self->catch_init_errors($_);
        return undef;
    };
    return unless $engine;

    my $fields = {
        project  => $project                      // 'unknown',
        uri      => $plan->uri                    // 'unknown',
        database => $engine->uri->dbname          // 'unknown',
        user     => $engine->uri->user            // 'unknown',
        path     => $config->current_project_path // 'unknown',
        engine   => $engine->uri->engine          // 'unknown',
        created_at    => undef,
        creator_name  => undef,
        creator_email => undef,
    };
    while ( my ( $field, $value ) = each %{$fields} ) {
        $self->view->load_txt_form_for( 'project', $field, $value );
    }
    return $project;
}

sub catch_init_errors {
    my ($self, $error) = @_;
    say "Stack trace: \n$_" if $self->options->debug;
    ( my $msg = $error ) =~ s/\nTrace begun.*$//ms;
    $self->log_message( qq{EE $msg} );
    $self->log_message( qq{WW Inconsistent state, please load another project!} );
    return;
}

sub clear_project_form {
    my $self   = shift;
    my $fields = {
        project       => undef,
        uri           => undef,
        database      => undef,
        user          => undef,
        path          => undef,
        engine        => undef,
        created_at    => undef,
        creator_name  => undef,
        creator_email => undef,
    };
    while ( my ( $field, $value ) = each %{$fields} ) {
        $self->view->load_txt_form_for( 'project', $field, $value );
    }
    return;
}

sub populate_change_form {
    my $self = shift;
    my $plan   = $self->plan;
    my $change = $plan->last;
    unless ($change) {
        $self->log_message( __x 'II No changes defined yet' );
        return;
    }
    $self->load_change($change);
    return;
}

sub load_change {
    my ($self, $change) = @_;
    unless ($change) {
        $self->log_message( __x 'II No changes defined yet' );
        return;
    }
    $self->log_message( __x 'II Loading change' )
        if $self->options->verbose;
    my $name  = $change->name;
    # say "change name: ", $name;

    my $engine = $self->target->engine;
    my $plan   = $self->plan;
    my $state = try {
        $engine->current_state( $plan->project );
    }
    catch {
        $self->log_message( "EE $_" );
        return undef;
    };

    my $planned_at
        = defined $state
        ? $state->{planned_at}->as_string
        : $change->timestamp;
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
        committer_name  => $state->{committer_name},
        committer_email => $state->{committer_email},
        committed_at    => $committed_at,
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->view->load_txt_form_for( 'change', $field, $value );
    }

    $self->load_sql_for($_, $name) for qw(deploy revert verify);
    return;
}

sub clear_change_form {
    my $self = shift;
    my %fields = (
        change_id       => undef,
        name            => undef,
        note            => undef,
        planner_name    => undef,
        planner_email   => undef,
        planned_at      => undef,
        planner_name    => undef,
        planner_email   => undef,
        committed_at    => undef,
        committer_name  => undef,
        committer_email => undef,
    );
    while ( my ( $field, $value ) = each(%fields) ) {
        $self->view->load_txt_form_for( 'change', $field, $value );
    }
    $self->view->load_sql_form_for( 'change', $_, undef )
        for qw(deploy revert verify);
    return;
}

sub load_sql_for {
    my ($self, $command, $name) = @_;
    my $repo_path = $self->config->current_project_path;
    my $sql_file  = file $repo_path, $command, "$name.sql";
    say "loading SQL file: $sql_file" if $self->options->verbose;
    if (-f $sql_file) {
        my $text = read_file($sql_file);
        $self->view->load_sql_form_for( 'change', $command, $text );
    }
    else {
        say "NO SQL file: $sql_file";
    }
    return;
}

sub populate_plan_form {
    my $self = shift;
    my $plan = $self->plan;
    my $iter = $plan->search_changes();
    my $is_current = 0;
    my $current_label = $is_current ? __('Yes') : q();
    my @plans;
    while ( my $change = $iter->() ) {
        push @plans, {
            name        => $change->name,
            description => $change->note,
            create_time => $change->timestamp,
            creator     => $change->planner_name,
            current     => $current_label,
        };
    }

    if (scalar @plans > 0 ) {
        $self->populate_list(
            $self->model->plan_list_data,
            $self->model->plan_list_meta_data,
            \@plans,
        );
    }

    $self->view->get_plan_list_ctrl->RefreshList;
    my $index = $self->view->get_plan_list_ctrl->set_selection('last');
    $self->mark_item('plan', $index, 5);
    return;
}

sub clear_plan_form {
    my $self = shift;
    $self->view->get_plan_list_ctrl->delete_all_items;
    $self->view->get_plan_list_ctrl->RefreshList;
    return;
}

sub execute_command {
    my ($self, $cmd, @cmd_args) = @_;

    push @cmd_args, '--no-color' if $cmd eq 'log';

    # Instantiate the command object.
    my $command = App::Sqitch::Command->load({
        sqitch  => $self->sqitch,
        config  => $self->config,
        command => $cmd,
        args    => \@cmd_args,
    });

    # Execute command.
    try {
        $command->execute(@cmd_args);
    }
    catch {
        ( my $msg = $_ ) =~ s{\s+(Trace|Can't).+}{}sm ;
        $self->log_message($msg);  # Better way to get rid of the stack trace?!
    };

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
        app       => $self->app,
        ancestor  => $self,
        parent    => undef,                  # undef for dialogs
    );

    $self->dlg_status->add_observer(
        App::Sqitch::GUI::View::Dialog::Refresh->new( dialog => $dialog ) );
    $self->dlg_status->set_state('sele');
    $dialog->list_ctrl->set_selection(0)
        if $dialog->list_ctrl->get_item_count > 0;

    if ( $dialog->ShowModal == wxID_OK ) {
        $self->view->get_project_list_ctrl->RefreshList;
        $self->dlg_status->remove_observers;
        return;
    }
    else {
        hurl 'This should NOT happen!';
    }

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

sub config_remove_default {
    my ( $self, $name, $is_default ) = @_;
    my @cmd = qw(config --user --remove-section);
    $self->execute_command(@cmd, "project") if $is_default;
    return 1;
}

sub config_remove_project {
    my ( $self, $name, $is_default ) = @_;
    my @cmd = qw(config --user --remove-section);
    $self->execute_command(@cmd, "project.${name}");
    return 1;
}

sub config_save_local {
    my ( $self, $engine, $database ) = @_;
    my @cmd = qw(config --local);
    $self->execute_command(@cmd, "core.${engine}.db_name", $database);
    return 1;
}

sub set_project_default {
    my $self = shift;

    my $item = $self->view->get_project_list_ctrl->get_selection;
    my $name = $self->model->project_list_data->get_value($item, 1);
    my $path = $self->model->project_list_data->get_value($item, 2);
    unless ( $name and $path ) {
        $self->log_message( __ 'WW Select a project item, please' );
        return;
    }
    $self->config_set_default($name); # write to the config file
    $self->model->default_project->item($item);
    $self->mark_item('project', $item, 4);
    $self->view->project->btn_default->Enable(0);

    $self->config->default_project_name($name);
    $self->config->default_project_path(dir $path);
    return;
}

sub get_list_by_name {
    my ( $self, $name ) = @_;
    my $list
        = $name eq 'project' ? $self->view->get_project_list_ctrl
        : $name eq 'plan'    ? $self->view->get_plan_list_ctrl
        :                      $self->dispatch_error($name);
    return $list;
}

sub get_list_data_by_name {
    my ( $self, $name ) = @_;
    my $list
        = $name eq 'project' ? $self->model->project_list_data
        : $name eq 'plan'    ? $self->model->plan_list_data
        :                      $self->dispatch_error($name);
    return $list;
}

sub dispatch_error {
    my ($self, $name) = @_;
    die "No such list name: $name";
}

sub _clear_mark_label {
    my ( $self, $list_name, $col ) = @_;
    hurl 'Wrong arguments passed to mark_item()'
        unless $list_name and defined($col) and $col >= 0;
    my $data = $self->get_list_data_by_name($list_name);
    $data->set_col( $col, '' );
    return;
}

sub _set_mark_label {
    my ($self, $list_name, $item, $col) = @_;
    hurl 'Wrong arguments passed to mark_item()'
        unless $list_name and defined($col) and $col >= 0;
    my $data = $self->get_list_data_by_name($list_name);
    $data->set_value( $item, $col, __('Yes') );
    return;
}

# project default col: 4
# project current col: 5
# plan    current col: 5
sub mark_item {
    my ($self, $list_name, $item, $col) = @_;
    hurl 'Wrong arguments passed to mark_item()'
        unless $list_name and defined($item) and defined($col) and $col >= 0;
    my $list = $self->get_list_by_name($list_name);
    $item //= $list->get_selection;
    $self->_clear_mark_label($list_name, $col);
    $self->_set_mark_label($list_name, $item, $col);
    $list->RefreshList;
    return;
}

sub _on_project_listitem_selected {
    my ($self, $var, $event) =  @_;
    my $item = $event->GetIndex;
    my $default_item = $self->model->default_project->item // 999;
    my $current_item = $self->model->current_project->item // 999;
    my $defa_enabled = $item == $default_item ? 0 : 1;
    my $load_enabled = $item == $current_item ? 0 : 1;
    $self->view->project->btn_default->Enable($defa_enabled);
    $self->view->project->btn_load->Enable($load_enabled);
    return;
}

sub _on_plan_listitem_selected {
    my ($self, $var, $event) =  @_;
    my $item = $event->GetIndex;
    return;
}

# TODO: Should this dump be cleaned of sensitive info like passwords
# (from targets)?
sub config_dump {
    my $self = shift;
    my $config = $self->sqitch->config;
    $self->sqitch->emit("\n");
    $self->sqitch->comment("Config dump:");
    $self->sqitch->comment( scalar $config->dump ) if $config;
    return $self;
}

1;

__END__

=encoding utf8

=head1 DESCRIPTION

The Controller.

=head1 SYNOPSIS

=head1 ATTRIBUTES

=head3 options

=head3 config

=head3 model

=head3 app

=head3 view

=head3 status

=head3 dlg_status

=head3 sqitch

=head3 target

=head3 plan

=head1 METHODS

=head3 _build_options

=head3 _build_config

=head3 _build_model

=head3 _build_app

=head3 _build_sqitch

=head3 _build_target

=head3 log_message

=head3 BUILD

=head3 populate_list

=head3 prepare_projects

=head3 load_sqitch_project

=head3 default_project_item

=head3 load_project_item

=head3 load_plan_list_item

=head3 load_change_item

=head3 load_project_from_path

=head3 _setup_events

=head3 populate_project_list

=head3 populate_project_form

=head3 catch_init_errors

=head3 clear_project_form

=head3 populate_change_form

=head3 load_change

=head3 clear_change_form

=head3 load_sql_for

=head3 populate_plan_form

=head3 clear_plan_form

=head3 execute_command

=head3 on_quit

=head3 on_admin

=head3 config_set_default

=head3 config_edit_project

=head3 config_remove_default

=head3 config_remove_project

=head3 config_save_local

=head3 set_project_default

=head3 get_list_by_name

=head3 get_list_data_by_name

=head3 dispatch_error

=head3 _clear_mark_label

=head3 _set_mark_label

=head3 mark_item

=head3 _on_project_listitem_selected

Enable or disable the C<Default> and C<Load> buttons for the selected
project item.

=head3 _on_plan_listitem_selected

Not used, yet.

=head3 config_dump

Dumps the configurations to the log control.

=cut
