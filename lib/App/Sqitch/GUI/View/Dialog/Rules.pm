package App::Sqitch::GUI::View::Dialog::Rules;

use Moose;
use namespace::autoclean;

has 'dia_rules' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default => sub {
        return {
            init => {
                btn_load    => 0,
                btn_default => 0,
                btn_add     => 0,
                btn_exit    => 1,
            },
            idle => {
                btn_load    => 0,
                btn_default => 0,
                btn_add     => 0,
                btn_exit    => 1,
            },
            sele => {
                btn_load    => 0,
                btn_default => 1,
                btn_add     => 1,
                btn_exit    => 1,
            },
        };
    },
);

sub init {
    return shift->dia_rules->{init};
}

sub idle {
    return shift->dia_rules->{idle};
}

sub sele {
    return shift->dia_rules->{sele};
}

__PACKAGE__->meta->make_immutable;

1;
