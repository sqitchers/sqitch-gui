package App::Sqitch::GUI::View::Dialog::Rules;

use Moose;
use namespace::autoclean;
use MooseX::AttributeHelpers;

has 'rules' => (
    metaclass => 'Collection::Hash',
    is        => 'ro',
    isa       => 'HashRef[HashRef]',
    required  => 1,
    lazy      => 1,
    default => sub {
        {   init => {
                btn_new     => 0,
                btn_remove  => 0,
                btn_save    => 0,
                btn_close   => 1,
                txt_name    => 0,
                dpc_path    => 0,
                cbx_engine  => 0,
                txt_db      => 0,
            },
            sele => {
                btn_new     => 1,
                btn_remove  => 1,
                btn_save    => 0,
                btn_close   => 1,
                txt_name    => 0,
                dpc_path    => 0,
                cbx_engine  => 0,
                txt_db      => 0,
            },
            add => {
                btn_new     => 1,
                btn_remove  => 0,
                btn_save    => 1,
                btn_close   => 0,
                txt_name    => 1,
                dpc_path    => 1,
                cbx_engine  => 0,
                txt_db      => 1,
            },
        };
    },
    provides => { 'get' => 'get_rules', },
);

__PACKAGE__->meta->make_immutable;

1;
