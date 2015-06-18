package App::Sqitch::GUI::Rules;

# ABSTRACT: Rules for buttons

use Moose;
use namespace::autoclean;
use MooseX::AttributeHelpers;

has 'rules' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[HashRef]',
    required  => 1,
    lazy      => 1,
    default   => sub {
        {   init => {
                btn_change      => 0,
                btn_change_sel  => 0,
                btn_project     => 1,
                btn_project_sel => 1,
                btn_plan        => 0,
                btn_plan_sel    => 0,
                btn_status      => 0,
                btn_add         => 0,
                btn_deploy      => 0,
                btn_revert      => 0,
                btn_verify      => 0,
                btn_log         => 0,
            },
            idle => {
                btn_change      => 1,
                btn_change_sel  => 1,
                btn_project     => 1,
                btn_project_sel => 1,
                btn_plan        => 1,
                btn_plan_sel    => 1,
                btn_status      => 1,
                btn_add         => 0,
                btn_deploy      => 1,
                btn_revert      => 0,
                btn_verify      => 1,
                btn_log         => 1,
            },
        };
    },
    provides => { 'get' => 'get_rules', },
);

__PACKAGE__->meta->make_immutable;

1;
