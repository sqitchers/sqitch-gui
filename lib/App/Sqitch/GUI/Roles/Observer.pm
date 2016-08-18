package App::Sqitch::GUI::Roles::Observer;

# ABSTRACT: Observer role

use Moo::Role;
use namespace::autoclean;

requires 'update';

1;
