package App::Sqitch::GUI::Config;

use Moose;
use namespace::autoclean;
use Path::Class;
#use Locale::TextDomain qw(App-Sqitch);
#use App::Sqitch::X qw(hurl);
use utf8;

extends 'App::Sqitch::Config';

__PACKAGE__->meta->make_immutable;

1;
