use strict;
use warnings;
use v5.10;

package MM::Test::Model::User;

sub new {
    my ( $class, %options ) = @_;
    return bless \%options, $class;
}

sub save {
    my ( $self ) = @_;
    my $rc = $self->dbh->do(
        q{INSERT INTO user VALUES( ?, ?, strftime( '%s', 'now' ) ) },
        undef,
        $self->{name},
        $self->{email},
    );
}

sub delete {
    my ( $self ) = @_;
    my $rc = $self->dbh->do(
        q{DELETE FROM user where name=?},
        undef,
        $self->{name},
    );
}

sub list {
    my ( $self ) = @_;
    my $list = $self->dbh->selectall_arrayref(
        q{select * from user},
        { Slice => {}
    } );
    return $list;
}

sub dbh {
    my ( $self ) = @_;
    return $self->{dbh};
}

1;