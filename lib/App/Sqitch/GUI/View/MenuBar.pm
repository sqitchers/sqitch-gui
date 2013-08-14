package App::Sqitch::GUI::View::MenuBar;

use Moose;
use namespace::autoclean;
use Wx qw(:everything);

with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;

extends 'Wx::MenuBar';

use App::Sqitch::GUI::View::MenuBar::App;
use App::Sqitch::GUI::View::MenuBar::Admin;
use App::Sqitch::GUI::View::MenuBar::Help;

has 'menu_app' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::MenuBar::App',
    lazy_build => 1
);

has 'menu_admin' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::MenuBar::Admin',
    lazy_build => 1
);

has 'menu_help' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::View::MenuBar::Help',
    lazy_build => 1
);

has 'menu_list' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        [   qw(
                  menu_app
                  menu_admin
                  menu_help
          )
        ];
    },
    documentation => q{
            If you add a new menu to the bar, be sure to add its name to this list please.
        }
);

sub FOREIGNBUILDARGS {
    return;                       # Wx::Menu->new() takes no arguments
}

sub BUILD {
    my $self = shift;

    $self->Append( $self->menu_app,   "&App");
    $self->Append( $self->menu_admin, "A&dmin");
    $self->Append( $self->menu_help,  "&Help");

    return $self;
}

sub _build_menu_app {
    my $self = shift;
    return App::Sqitch::GUI::View::MenuBar::App->new(
        ancestor => $self,
        app      => $self->app,
        parent   => $self->parent,    # View is the parent.
    );
}

sub _build_menu_admin {
    my $self = shift;
    return App::Sqitch::GUI::View::MenuBar::Admin->new(
        ancestor => $self,
        app      => $self->app,
        parent   => $self->parent,    # View is the parent.
    );
}

sub _build_menu_help {
    my $self = shift;
    return App::Sqitch::GUI::View::MenuBar::Help->new(
        ancestor => $self,
        app      => $self->app,
        parent   => $self->parent,    # View is the parent.
    );
}

sub _set_events { }

__PACKAGE__->meta->make_immutable;

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
