package App::Sqitch::GUI;

use 5.010001;
use Moose;
use namespace::autoclean;
use Path::Class;
#use Data::Printer;
use Wx;
use Wx::Event qw(EVT_CLOSE);
use App::Sqitch;
#use App::Sqitch::Config;
use App::Sqitch::GUI::Config;
use App::Sqitch::GUI::MainFrame;

use MooseX::NonMoose;
extends 'Wx::App';

our $VERSION = '0.001';

sub init_sqitch {
    my $opts = {};

    # 1. Load config.
    # my $config = App::Sqitch::GUI::Config->new( confname => 'sqitch-gui.conf' );
    # say scalar $config->dump;

    # my $project = dir $config->get( key => 'projects.path' );
    # p $project;
    # print "dir is $project\n";

    # 2. Instantiate Sqitch.

    # my $sqitch = App::Sqitch->new($opts);

    # print 'Top dir is:', $sqitch->top_dir, ":\n";

    # my $cmd = 'status';
    # my $cmd_args;

    # # 4. Load config.
    # my $config = App::Sqitch::Config->new;
    # #p $config;

    # # 5. Instantiate Sqitch.
    # $opts->{_engine} = delete $opts->{engine} if $opts->{engine};
    # $opts->{config}  = $config;
    # my $sqitch = App::Sqitch->new($opts);

    # # 6. Instantiate the command object.
    # my $command = App::Sqitch::Command->load({
    #     sqitch  => $sqitch,
    #     command => $cmd,
    #     config  => $config,
    #     args    => $cmd_args,
    # });

    # # 7. Execute command.
    # $command->execute( @{$cmd_args} ) ? 0 : 2;
}

has 'main_frame' => (
    is      => 'rw',
    isa     => 'App::Sqitch::GUI::MainFrame',
    lazy_build => 1,
    handles => {
        menu_bar => 'menu_bar',
    }
);

sub FOREIGNBUILDARGS {
    return ();                     # Wx::App->new() gets no arguments.
}

sub BUILD {
    my $self = shift;

    $self->SetTopWindow($self->main_frame->frame);
    $self->main_frame->frame->Show(1);
    $self->_set_events;
    return $self;
}

sub _build_main_frame {
    my $self = shift;

    my $args = {
        app   => $self,
        title => 'Sqitch::GUI',
    };

    return App::Sqitch::GUI::MainFrame->new( $args );
}

sub _set_events {
    my $self = shift;
    EVT_CLOSE( $self->main_frame->frame, sub { $self->OnClose(@_) } );
    return;
}

sub OnInit {
    my $self = shift;
    Wx::InitAllImageHandlers();
    return 1;
}

sub OnClose {
    my($self, $frame, $event) = @_;
    $event->Skip();
    return;
}

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

1;    # End of App::Sqitch::GUI
