# mariadb-mha
Master fail-over tool for MariaDB with support for GTID.

Currently there are two functionalities for mariadb-mha

1> master_monitor : It regularly checks the availability of mysqld at a given master. Prints an error message when mysqld is unavailable.

How to use:
From bin/ execute master_monitor script.
$> ./master_monitor username password ip port

How it works:
It uses Perl DBI package to connect to a database. DBI->connect() is called at regular intervals.

2> new_master : It returns the IP of the most updated slave that should be promoted as the new master after current master dies.

How to use:
It assumes that a slave.cnf file has a list of all slaves with the details.
From bin/ execute new_master script.
$> ./new_master

How it works:
It connects to each slave and gets the last GTID transaction applied at that slave. To get this GTID it executes the query 'SELECT @@GLOBAL.gtid_slave_pos' and save its result. Returned GTID has three parts, (domain-id)-(server-id)-(sequence).
It parses GTID from each slave, and for each domain-id it returns the IP of the slave whose sequence number is highest.

For further details,
email : hemant271990@gmail.com
