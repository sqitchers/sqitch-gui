package App::Sqitch::GUI::Model;

use 5.010;
use Moo;
use App::Sqitch::GUI::Types qw(
    Dir
    Int
    Maybe
    Sqitch
    SqitchGUIConfig
    SqitchGUITarget
    Str
);
use Try::Tiny;

use App::Sqitch::GUI::Sqitch;
use App::Sqitch::GUI::Target;

has 'config' => (
    is   => 'ro',
    isa  => SqitchGUIConfig,
    lazy => 1,
);

has 'sqitch' => (
    is      => 'rw',
    isa     => Maybe[Sqitch],
    lazy    => 1,
);

has 'target' => (
    is      => 'ro',
    isa     => Maybe[SqitchGUITarget],
    lazy    => 1,
    builder => '_build_target',
);

sub _build_target {
    my $self = shift;
    try {
        return App::Sqitch::GUI::Target->new( sqitch => $self->sqitch );
    }
    catch {
        print "Catch ERROR: $_\n";
    };
}

has 'plan' => (
    is      => 'ro',
    isa     => Maybe[SqitchGUITarget],
    lazy    => 1,
    default => sub {
        my $self = shift;
        return App::Sqitch::GUI::Target->new( sqitch => $self->sqitch );
    },
);

#--

has 'selected_item' => (
    is      => 'rw',
    isa     => Maybe[Int],
    default => sub { undef },
);

has 'selected_name' => (
    is      => 'rw',
    isa     => Maybe[Str],
    default => sub { undef },
);

has 'selected_path' => (
    is      => 'rw',
    isa     => Maybe[Dir],
    default => sub { undef },
);

#--

1;
