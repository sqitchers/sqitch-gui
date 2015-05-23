package App::Sqitch::GUI::View::MenuBar;

use 5.010;
use strict;
use warnings;
use Moo;
use App::Sqitch::GUI::Types qw(
    ArrayRef
    SqitchGUIViewMenuBarAdmin
    SqitchGUIViewMenuBarApp
    SqitchGUIViewMenuBarHelp
);
#use Wx qw(:everything);

use App::Sqitch::GUI::View::MenuBar::App;
use App::Sqitch::GUI::View::MenuBar::Admin;
use App::Sqitch::GUI::View::MenuBar::Help;

with 'App::Sqitch::GUI::Roles::Element';

extends 'Wx::MenuBar';

has 'menu_app' => (
    is      => 'rw',
    isa     => SqitchGUIViewMenuBarApp,
    lazy    => 1,
    builder => '_build_menu_app',
);

has 'menu_admin' => (
    is      => 'rw',
    isa     => SqitchGUIViewMenuBarAdmin,
    lazy    => 1,
    builder => '_build_menu_admin',
);

has 'menu_help' => (
    is      => 'rw',
    isa     => SqitchGUIViewMenuBarHelp,
    lazy    => 1,
    builder => '_build_menu_help'
);

# If you add a new menu to the bar, be sure to add its name to this list
has 'menu_list' => (
    is      => 'rw',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [ qw(
                  menu_app
                  menu_admin
                  menu_help
          ) ];
    },
);

sub FOREIGNBUILDARGS {
    return ();                    # Wx::Menu->new() takes no arguments
}

sub BUILD {
    my $self = shift;
    say "BUILDing";
    $self->Append( $self->menu_app,   "&App");
    $self->Append( $self->menu_admin, "A&dmin");
    $self->Append( $self->menu_help,  "&Help");
    return $self;
}

sub _build_menu_app {
    my $self = shift;
    say "_build_menu_app";
    my $menu_app = App::Sqitch::GUI::View::MenuBar::App->new(
        ancestor => $self->ancestor,
        app      => $self->app,
        parent   => $self->parent,    # View is the parent.
    );
    say "_build_menu_app done";
    return $menu_app;
}

sub _build_menu_admin {
    my $self = shift;
    say "_build_menu_admin";
    my $menu_admin = App::Sqitch::GUI::View::MenuBar::Admin->new(
        ancestor => $self->ancestor,
        app      => $self->app,
        parent   => $self->parent,    # View is the parent.
    );
    say "_build_menu_admin done";
    return $menu_admin;
}

sub _build_menu_help {
    my $self = shift;
    say "_build_menu_help";
    my $menu_help = App::Sqitch::GUI::View::MenuBar::Help->new(
        app      => $self->app,
        ancestor => $self->ancestor,
        parent   => $self->parent,    # View is the parent.
    );
    say "_build_menu_help";
    return $menu_help;
}

sub _set_events { }

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

None known.

Please report any bugs or feature requests to the author.

=head1 ACKNOWLEDGMENTS

GUI with Wx and Moose heavily inspired/copied from the LacunaWaX
project:

https://github.com/tmtowtdi/LacunaWaX

Copyright: Jonathan D. Barton 2012-2013

Thank you!

=head1 LICENSE AND COPYRIGHT

  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::View::MenuBar
