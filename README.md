# PTV_fdw

PostgreSQL Foreign Data Wrapper for JSON API by Digi- ja väestötietoviraston palvelutietovaranto.

Inspired greatly by [geofdw](https://github.com/bosth/geofdw) and [snowplow_fdw](https://github.com/GispoCoding/snowplow_fdw).

# Installation

1. Install docker and docker-compose.
2. Run git clone `https://`
3. Run `cd PTVfdw`
4. Run `docker-compose up -d --build` (if you are not running with root permissions add `sudo` in the beginning of each command)
5. Install ptvfdw Foreign Data Wrapper with: `docker-compose exec postgis-db bash /scripts/dev_install.sh`
6. Run `docker ps` to find out postgis-db docker name (`<postgis-db-name>` in next)
7. Run `docker cp docker/pg_hba.conf ptvfdw_<postgis-db-name>:/etc/postgresql/12/main/`
8. Run `docker-compose exec postgis-db bash`
9. Run `chown postgres:postgres /etc/postgresql/12/main/pg_hba.conf` and `exit`
10. Restart with `docker-compose restart postgis-db`

If you make any changes to the code, just repeat the installation (steps 3-9). 
Stop database with `docker-compose stop` and start it next time with `docker-compose start`.

# Usage

Run `docker-compose exec postgis-db psql -h localhost -U <username> -d <database-name>` to open the psql terminal from
your Linux server. There you can execute SQL queries like `SELECT * FROM kunnat` or schedule jobs via pg_cron e.g.
by copy&pasting the contents of ajastuskomento_kuntalista.txt to the psql commandline.

> Note that the text files in this repository perform some more complex scheduled jobs!
>> ajastuskomento_kuntalista.txt contains the commands for creating the postgis table about municipalities in Finland
> (code + municipality name in Finnish, Swedish and English). This is a quick job so start testing with this!
> 
>> ajastuskomento_kaikki.txt contains the commands to fetch all kinds of information about service points located
> either in Varsinais-Suomi or Satakunta region.

The basic syntax  for scheduling task to be run once every minute goes as

`SELECT cron.schedule('*/1 * * * *',  $$<SQL-commands-you-wish-to-execute>$$`.

Naturally the execution frequency can be easily altered. The schedule uses the standard cron syntax, in which *
means "run every time period", / determines a "time step size" and a specific number means "but only at this time".
See [crontab_guru](https://crontab.guru/) for more help.

You can list the scheduled jobs with `SELECT * FROM cron.job`.

To take a closer look on some jobs progress, run `SELECT * FROM cron.job_run_details WHERE jobid=<job-id>;`.

You can unschedule a certain task by running `SELECT cron.unschedule(<job-id>);`.

> Note that the scheduled jobs will keep on running until you unschedule them!

## Utilizing PTV_fdw without scheduling

If you do not wish to create a scheduled task for updating the contents of the table regularly but rather wish to create
it just once, a handy way to achieve this is to run the taulumuod.sql file. In this file there are scripts which create
the FDW server and the foreign table allowing us to fetch data from the JSON API. There are also SQL clauses which create
another table (best not to store data in foreign tables since they are not permanent database objects) and insert
the data from foreign table into it). In addition to that, a bunch of data modification related
SQL clauses are included into the file. Just execute the whole file at once (e.g. via PgAdmin or docker terminal).
