#
# Test the Observer role
#
# Adapted after the 'collection_with_roles.t' test from Moose;
#
use 5.010;
use strict;
use warnings;

use Test::More;

{
    package Counter;

    use Moo;
    use Types::Standard qw(Int);

    with 'App::Sqitch::GUI::Roles::Observable';

    has count => (
        is      => 'rw',
        isa     => Int,
        default => 0,
    );

    sub inc_counter {
        my $self = shift;
        $self->count( $self->count + 1);
        return;
    }

    sub dec_counter {
        my $self = shift;
        $self->count( $self->count - 1);
        return;
    }

    after qw(inc_counter dec_counter) => sub {
        my ($self) = @_;
        $self->notify();
    };
}

{
    package Display;

    use Moo;
    use Test::More;

    with 'App::Sqitch::GUI::Roles::Observer';

    sub update {
        my ( $self, $subject ) = @_;
        like $subject->count, qr{^-?\d+$},
            'Observed number ' . $subject->count;
    }
}

package main;

my $count = Counter->new();

ok( $count->can('add_observer'), 'add_observer method added' );

ok( $count->can('count_observers'), 'count_observers method added' );

ok( $count->can('inc_counter'), 'inc_counter method added' );

ok( $count->can('dec_counter'), 'dec_counter method added' );

$count->add_observer( Display->new() );

is( $count->count_observers, 1, 'Only one observer' );

is( $count->count, 0, 'Default to zero' );

$count->inc_counter;

is( $count->count, 1, 'Increment to one ' );

$count->inc_counter for ( 1 .. 6 );

is( $count->count, 7, 'Increment up to seven' );

$count->dec_counter;

is( $count->count, 6, 'Decrement to 6' );

$count->dec_counter for ( 1 .. 5 );

is( $count->count, 1, 'Decrement to 1' );

$count->dec_counter for ( 1 .. 2 );

is( $count->count, -1, 'Negative numbers' );

$count->inc_counter;

is( $count->count, 0, 'Back to zero' );

done_testing;
