#!/usr/bin/perl -w

use File::Basename;
use DBI;
use MHA::Slave;

my $dirname = dirname(__FILE__);

package MHA::SlaveManager;

sub main {
    my %domainHash = ();   #Hash map for each Domain
    my $confFileName = "$dirname/../../slaves.cnf";
    open(CONF_HANDLE, "<$confFileName") or die "$!\n";
      while (<CONF_HANDLE>) {
        # Read config file line by line
        my @slaveEntry = split(',' , $_);
        my %slaveInfo = ();
        foreach my $confVar (@slaveEntry) {
            chomp $confVar;
            if ($confVar =~ m/(\S*) => (\S*)/) {    
                $slaveInfo{$1} = $2;
            }
        }
        $slave = new MHA::Slave(
            user          => $slaveInfo{'user'},
            password      => $slaveInfo{'password'},
            ip            => $slaveInfo{'ip'},
            port          => $slaveInfo{'port'},
        );

        $gtid = $slave->getLatestGTID();
        my @values = split('-', $gtid);
        if( exists($domainHash{$values[0]}) ) {
            my $oldSeq = $domainHash{$values[0]}{'gtid'};
            my $newSeq = $values[2];
            if($newSeq > $oldSeq) {
                $domainHash{$values[0]}{'slaveIP'} = $slaveInfo{'ip'};
                $domainHash{$values[0]}{'gtid'} = $newSeq;
            }
        }
        else {
            $domainHash{$values[0]}{'slaveIP'} = $slaveInfo{'ip'};
            $domainHash{$values[0]}{'gtid'} = $values[2];
        }
        
    }
    close( CONF_HANDLE );
    foreach my $domain (keys %domainHash ) {
        print "Latest Slave in domain $domain, is: $domainHash{$domain}{'slaveIP'} with GTID Sequence: $domainHash{$domain}{'gtid'}\n";
    }
}

1;
