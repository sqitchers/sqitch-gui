package App::Sqitch::GUI::Model;

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    Maybe
	Sqitch
	SqitchGUIConfig
	SqitchGUITarget
);
use Try::Tiny;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;

has config => (
    is      => 'ro',
    isa     => SqitchGUIConfig,
    lazy    => 1,
);

has sqitch => (
    is      => 'rw',
    isa     => Maybe[Sqitch],
    lazy    => 1,
    builder => '_build_sqitch',
);

has target => (
    is      => 'ro',
    isa     => Maybe[SqitchGUITarget],
    lazy    => 1,
	default => sub {
		my $self = shift;
		return App::Sqitch::GUI::Target->new( sqitch => $self->sqitch );
	},
);

sub _build_sqitch {
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

sub load_sqitch_plan {
    my $self = shift;

    # my $sqitch = $self->sqitch;

    # # Do we have a valid configuration - plan?
    # my $target;
    # try {
    #     $target = App::Sqitch::GUI::Target->new( sqitch => $sqitch );
    # }
    # catch {
    #     my $msg = "ERROR: $_";
    #     print "Catch: $msg\n";
    # }
    # finally {
    #     if (@_) {
    #         $self->log_message(__ 'Sqitch is NOT initialized yet. Please add a project path using the Admin menu.');
    #         $self->status->set_state('init');
    #     } else {
    #         $self->status->set_state('idle');
    #     }
    # };

    # if ( $self->status->is_state('idle') ) {
    #     try {
    #         $self->populate_project($target);
    #         $self->populate_plan($target);
    #         $self->populate_change($target);
    #     }
    #     catch {
    #         $self->log_message(__ 'Error' . ': '. $_);
    #     };
    # }

    return;
}

1;
