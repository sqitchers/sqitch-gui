package App::Sqitch::GUI::Config;

use 5.010001;
use Moose;
use strict;
use warnings;
use Path::Class;
#use Locale::TextDomain qw(App-Sqitch);
#use App::Sqitch::X qw(hurl);
use utf8;

extends 'App::Sqitch::Config';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
