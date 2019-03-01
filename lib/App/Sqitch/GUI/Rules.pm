package App::Sqitch::GUI::Rules;

# ABSTRACT: Rules for buttons

use Moo;
use MooX::HandlesVia;
use namespace::autoclean;

has 'rules' => (
    is          => 'ro',
    handles_via => 'Hash',
    required    => 1,
    lazy        => 1,
    default     => sub {
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
                btn_deploy      => 0,
                btn_revert      => 0,
                btn_verify      => 1,
                btn_log         => 1,
            },
        };
    },
    handles => { get_rules => 'get' },
);

1;
