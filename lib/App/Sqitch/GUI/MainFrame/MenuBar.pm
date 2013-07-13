package App::Sqitch::GUI::MainFrame::MenuBar;

use Moose;
use Wx qw(:everything);
with 'App::Sqitch::GUI::Roles::Element';

use MooseX::NonMoose::InsideOut;
extends 'Wx::MenuBar';

use App::Sqitch::GUI::MainFrame::MenuBar::App;
use App::Sqitch::GUI::MainFrame::MenuBar::Help;

has 'menu_app' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::MenuBar::App',
    lazy_build => 1
);

has 'menu_help' => (
    is         => 'rw',
    isa        => 'App::Sqitch::GUI::MainFrame::MenuBar::Help',
    lazy_build => 1
);

has 'menu_list' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        [   qw(
                  menu_app
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

    $self->Append( $self->menu_app, "&App");
    # $self->Append( $self->menu_edit,   "&Edit");
    # $self->Append( $self->menu_tools,  "&Tools");
    $self->Append( $self->menu_help, "&Help");

    return $self;
}

sub _build_menu_app {
    my $self = shift;
    return App::Sqitch::GUI::MainFrame::MenuBar::App->new(
        ancestor => $self,
        app      => $self->app,
        parent   => $self->parent,    # MainFrame is the parent.
    );
}

sub _build_menu_help {
    my $self = shift;
    return App::Sqitch::GUI::MainFrame::MenuBar::Help->new(
        ancestor => $self,
        app      => $self->app,
        parent   => $self->parent,    # MainFrame is the parent.
    );
}

sub _set_events { }

no Moose;
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

Thank you!

=head1 LICENSE AND COPYRIGHT

Copyright:
  Jonathan D. Barton 2012-2013
  Stefan Suciu       2013

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation.

=cut

1;    # End of App::Sqitch::GUI::MainFrame::MenuBar
