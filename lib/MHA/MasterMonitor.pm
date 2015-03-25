#!/usr/bin/perl -w

package MHA::MasterMonitor;

use MHA::CheckHealth;

sub main {
    my ($user, $password, $ip, $port) = @_;

    $master_health = new MHA::CheckHealth(
      user           => $user,
      password       => $password,
      ip             => $ip,
      port           => $port,
    );
    
    $master_health->test_until_disconnects();
}

1;
