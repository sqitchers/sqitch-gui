package App::Sqitch::GUI::Config::Toolbar;

# ABSTRACT: Data store for toolbar

use Moo;
use MooX::HandlesVia;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);

has 'toolnames' => (
    is          => 'ro',
    handles_via => 'Array',
    default     => sub {
        return [ 'tb_pj', 'tb_qt', ];
    },
    handles => { all_buttons => 'elements', },
);

has 'tool' => (
    is          => 'rw',
    handles_via => 'Hash',
    default     => sub {
        return {
            tb_pj => {
                tooltip => __ 'Projects',
                icon    => 'preferences-system.png',
                sep     => 'after',
                help    => __ 'Projects',
                type    => '_item_normal',
                id      => '1001',
                state   => {
                    init => 'normal',
                    idle => 'normal',
                }
            },
            tb_qt => {
                tooltip => __ 'Quit',
                icon    => 'system-log-out.png',
                sep     => 'none',
                help    => __ 'Quit the application',
                type    => '_item_normal',
                id      => '1002',
                state   => {
                    init => 'normal',
                    idle => 'normal',
                }
            },
        };
    },
    handles => {
        ids_in_tool => 'keys',
        get_tool    => 'get',
    }
);

1;
