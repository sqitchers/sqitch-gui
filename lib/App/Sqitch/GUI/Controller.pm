package App::Sqitch::GUI::Controller;

use Moose;
use namespace::autoclean;

use Wx qw<:everything>;
use Wx::Event qw<EVT_CLOSE EVT_BUTTON EVT_MENU>;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::WxApp;

#use Data::Printer;

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

sub log_message {
    my ($self, $msg) = @_;
    Wx::LogMessage($msg);
}

sub _build_app {
    my $self = shift;
    my $app = App::Sqitch::GUI::WxApp->new();
    return $app;
}

sub BUILD {
    my $self = shift;

    $self->log_message('Welcome to Sqitch!');

    EVT_BUTTON $self->view->frame,
        $self->view->right_side->btn_status->GetId, sub {
            $self->status;
    };

    return 1;
}

sub status {
    my $self = shift;

    # my $config = App::Sqitch::GUI::Config->new( confname => 'sqitch-gui.conf' );
    # say scalar $config->dump;

    # my $project = dir $config->get( key => 'projects.path' );
    # p $project;
    # print "dir is $project\n";

    # 1. Instantiate Sqitch.

    my $opts = {};

    my $cmd = 'status';
    my $cmd_args;

    # 4. Load config.
    my $config = App::Sqitch::Config->new;

    # 5. Instantiate Sqitch.
    $opts->{_engine} = delete $opts->{engine} if $opts->{engine};
    $opts->{config}  = $config;
    my $sqitch = App::Sqitch::GUI::Sqitch->new($opts);
    #print 'Top dir is:', $sqitch->top_dir, ":\n";

    # 6. Instantiate the command object.
    my $command = App::Sqitch::Command->load({
        sqitch  => $sqitch,
        command => $cmd,
        config  => $config,
        args    => $cmd_args,
    });

    # 7. Execute command.
    $command->execute( @{$cmd_args} ) ? 0 : 2;
}

__PACKAGE__->meta->make_immutable;

1;
