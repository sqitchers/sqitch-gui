package App::Sqitch::GUI::Roles::Observer;

# ABSTRACT: Observer role

use Moo::Role;
use namespace::autoclean;

requires 'update';

1;

__END__

=encoding utf8

=head1 SYNOPSIS

    with 'App::Sqitch::GUI::Roles::Observer';

    sub update {
        my ( $self, $subject ) = @_;
        # do something with $subject...
        return;
    }

=head1 DESCRIPTION

Basic Moo role to implement the Observer Pattern.

=head1 INTERFACE

=head2 ATTRIBUTES

=head2 INSTANCE METHODS

=head3 update

The C<update> method has to be implemented by the class, that consumes
this role.  The object being observed is the only argument.

=cut
