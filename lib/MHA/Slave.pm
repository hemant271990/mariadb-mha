#!/usr/bin/perl -w
package MHA::Slave;

sub new {
  	my $class = shift;
  	my $self  = {
    	dbh                    => undef,
    	user                   => undef,
    	password               => undef,
    	ip                     => undef,
    	port                   => undef,
    	@_,
    	};
    return bless $self, $class;
}

sub getLatestGTID($) {
    my $self = shift;
    my $gtid = "0-0-0";
    $self->{dbh} = DBI->connect(
        "DBI:mysql:;host=$self->{ip};".
        "port=$self->{port}",
        $self->{user},
        $self->{password},
        { PrintError => 0, RaiseError => 0 }
    )
    or die "Couldn't connect to database: " . DBI->errstr . "\n";

    if ( $self->{dbh} ) {
        my $query = $self->{dbh}->prepare( 'SELECT @@GLOBAL.gtid_slave_pos' )
            or die "Couldn't prepare statement: " . $self->{dbh}->errstr . "\n";

        $query->execute() or die "Couldn't execute statement: " . $query->errstr . "\n";
        my @data = $query->fetchrow_array();
        $gtid = $data[0];
    }
    $self->{dbh}->disconnect;
    return $gtid;
}

1;
