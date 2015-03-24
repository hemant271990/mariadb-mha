#!/usr/bin/perl -w
package MHA::CheckHealth;

use DBI;

sub new {
  my $class = shift;
  my $self  = {
    dbh                    => undef,
#    interval               => 2,
    user                   => undef,
    password               => undef,
    ip                     => undef,
#    hostname               => undef,
    port                   => undef,
	recheckInterval		   => 3,
#    ssh_user               => undef,
#    workdir                => undef,
#    status_handler         => undef,
#    secondary_check_script => undef,
#    logger                 => undef,
#    logfile                => undef,

    # internal (read/write) variables
    _tstart            => undef,
    _already_monitored => 0,
    _need_reconnect    => 1,
    _last_ping_fail    => 1,
    _sec_check_invoked => 0,
    _sec_check_pid     => undef,
    _ssh_check_invoked => 0,
    _ssh_check_pid     => undef,
    @_,
  };
  return bless $self, $class;
}

sub connect($) {
	my $self = shift;
#	my $log  = $self->{logger};
	$self->{dbh} = DBI->connect(
    	"DBI:mysql:;host=$self->{ip};". 
		"port=$self->{port}",
    	$self->{user}, 
		$self->{password}, 
		{ PrintError => 0, RaiseError => 0 }
  	);

	if ( !$self->{dbh} ) {
		my $msg = "Got error on MySQL connect: ";
    	$msg .= $DBI::err if ($DBI::err);
	    $msg .= " ($DBI::errstr)" if ($DBI::errstr);
    	print $msg."\n";
    	return ( 1, $DBI::err );
	}
	else {
		return 0;
	}
}

sub test_until_disconnects($) {
	my $self = shift;
	while (1)
    {
        my ( $rc, $mysql_err ) = $self->connect();
		if($rc == 1)
		{
			if ($mysql_err) {
				print $mysql_err."\n";
			}
		}
		else {
			print "Running...\n";
		}
		$self->sleep_until();		
	}
}


sub sleep_until {
  my $self    = shift;
  sleep( $self->{recheckInterval} );
}

1;
