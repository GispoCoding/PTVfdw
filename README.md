# PTV_fdw

PostgreSQL Foreign Data Wrapper for JSON API by Digi- ja väestötietoviraston palvelutietovaranto.

Inspired greatly by [geofdw](https://github.com/bosth/geofdw) and [snowplow_fdw](https://github.com/GispoCoding/snowplow_fdw).

# Installation

## Development

1. Install docker and docker-compose.
2. Run `docker-compose up -d --build` (if you are not running with root permissions add `sudo` in the beginning of each command)
3. Install ptvfdw Foreign Data Wrapper with: `docker-compose exec postgis-db bash /scripts/dev_install.sh`
4. Run `docker ps` to find out postgis-db docker name (`<postgis-db-name>` in next)
5. Run `docker cp docker/pg_hba.conf ptvfdw_<postgis-db-name>:/etc/postgresql/12/main/`
6. Run `docker-compose exec postgis-db bash`
7. Run `chown postgres:postgres /etc/postgresql/12/main/pg_hba.conf` and `exit`
8. Restart with `docker-compose restart postgis-db`

If you make any changes to the code, just repeat the installation (steps 3-9). 
Stop database with `docker-compose stop` and start it next time with `docker-compose start`.

# Usage

Run `docker-compose exec postgis-db psql -h localhost -U <username> -d <database-name>` to open the psql terminal in
your Linux-server. Here you can execute SQL-queries etc.
`SELECT *
FROM kunnat` or schedule tasks via pg_cron e.g. by copy pasteing the contents of ajastuskomento_kuntalista.txt to the
psql command line. Note that the text files in this repository perform some more complex scheduled jobs but the basic syntax
for scheduling task to be run once every minute goes as
`SELECT cron.schedule('*/1 * * * *',  $$<SQL-commands-you-wish-to-execute>$$`.

Naturally the execution frequence can be easily altered. The schedule uses the standard cron syntax, in which *
means "run every time period", / determines a "time step size" and a specific number means "but only at this time".
See [crontab_guru](https://crontab.guru/) for more help.

You can monitor the progress of the jobs with
`SELECT * FROM cron.job` or `SELECT *
FROM cron.job_run_details
WHERE jobid=<job-id>;`.

You can unschedule a certain task by running
`SELECT cron.unschedule(<job-id>);`.

If you do not wish to create a scheduled task for updating the contents of the table regularly but rather wish to create
it just once, a handy way to achieve this is to run the taulumuod.sql file. In this file there are scripts which create
the FDW server and the foreign table allowing us to fetch data from the JSON API. There are also SQL clauses which create
another table (best not to store data in foreign tables since they are not permanent database objects) and insert
the data from foreign table into it). In addition to that, a bunch of data modification related
SQL clauses are included into the file. Just execute the whole file at once (e.g. via PgAdmin or docker terminal).
