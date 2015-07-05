package App::Sqitch::GUI::View::Dialog::Rules;

# ABSTRACT: Rules for the Projects Dialog

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
                btn_new    => 0,
                btn_remove => 0,
                btn_save   => 0,
                btn_close  => 1,
                txt_name   => 0,
                dpc_path   => 0,
                cbx_engine => 0,
                txt_db     => 0,
            },
            sele => {
                btn_new    => 1,
                btn_remove => 1,
                btn_save   => 0,
                btn_close  => 1,
                txt_name   => 0,
                dpc_path   => 0,
                cbx_engine => 0,
                txt_db     => 0,
            },
            add => {
                btn_new    => 1,
                btn_remove => 0,
                btn_save   => 1,
                btn_close  => 0,
                txt_name   => 1,
                dpc_path   => 1,
                cbx_engine => 0,
                txt_db     => 1,
            },
        };
    },
    handles => { get_rules => 'get' },
);

1;
