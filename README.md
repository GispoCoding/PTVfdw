# PTV_fdw

PostgreSQL Foreign Data Wrapper for JSON API by Digi-
ja väestötietoviraston palvelutietovaranto.

Sponsors: Lounaistieto, Varsinais-Suomen liitto.

Inspired greatly by [geofdw](https://github.com/bosth/geofdw)
and [snowplow_fdw](https://github.com/GispoCoding/snowplow_fdw).

### Updates

29.7.2022 Replaced multicorn with https://github.com/pgsql-io/multicorn2 

# Installation

1. Install docker and docker compose
2. Clone this repository to your Linux server
3. Go to the correct folder (`cd PTVfdw`)
4. Run `docker compose up -d --build`
5. Install ptvfdw Foreign Data Wrapper with `docker compose exec postgis-db bash /scripts/dev_install.sh`
6. Run `docker ps` to find out postgis-db docker name (`<postgis-db-name>` in next)
7. Run `docker cp docker/pg_hba.conf <postgis-db-name>:/etc/postgresql/12/main/`
8. Run `docker compose exec postgis-db bash`
9. Run `chown postgres:postgres /etc/postgresql/12/main/pg_hba.conf` and `exit`
10. Restart with `docker compose restart postgis-db`

> If you are not running with root permissions add `sudo` in the beginning
> of each command!

If you make any changes to the code, just repeat the installation (steps 4-10).

Stop database with `docker compose stop` and start it next time
with `docker compose start`.

# Usage

Go to the correct folder if you are not there already (`cd PTVfdw`).
Run `docker compose exec postgis-db psql -h localhost -U <username> -d <database-name>`
in order to open the psql terminal from your Linux server. From psql terminal
you can execute SQL queries like `SELECT * FROM kunnat;` or schedule jobs
via pg_cron.

The basic syntax  for scheduling task to be run, e.g. once in every minute,
goes as

`SELECT cron.schedule('*/1 * * * *',  $$<SQL-commands-you-wish-to-execute>$$);`.

Naturally the execution frequency can be easily altered. The schedule uses
the standard cron syntax, in which * means "run every time period", / determines
a "time step size" and a specific number means "but only at this time".
See [crontab_guru](https://crontab.guru/) for more help.

You can list the scheduled jobs with `SELECT * FROM cron.job;`.

To take a closer look on some jobs progress,
run `SELECT * FROM cron.job_run_details WHERE jobid=<job-id>;`.

You can unschedule a certain task by running `SELECT cron.unschedule(<job-id>);`.

> Note that the scheduled jobs will keep on running until you unschedule them!

> Note also that running `docker compose stop` or `docker compose down` will
> lead to the failure of the scheduled tasks unless you restart the
> docker container before the execution time of the scheduled task comes!

## Scheduling via calling plpgsql function

In order to schedule jobs via calling the function, it must exist. You can
create a function through inserting a bunch of commands to the psql terminal
by obeying the following structure:

```
create function <function-name>()
returns void
language plpgsql
as
$$
begin
 drop server if exists dev_fdw cascade;
 drop foreign table if exists <foreign-table-name>;
 drop table if exists <table-name>;

 create server dev_fdw foreign data wrapper multicorn options ( wrapper 'ptvfdw.ptvForeignDataWrapper' );

 create foreign table <foreign-table-name>(
  id int,
  name varchar
  ) server dev_fdw options(
  url '<url-to-json-api-containing-the-desired-data');

 create table <table-name>(
  id int,
  name varchar
 );

 insert into <table-name>(id, name) select id, name from <foreign-table-name>;
 
 drop foreign table if exists <foreign-table-name>;

end;
$$;
```

There are two text files in this repository which contain the commands for
creating a job for
1) creating and updating the contents of the postgis table about
municipalities in Finland (code + municipality name in Finnish, Swedish
and English)
> kunnatupdate.txt
2) creating and updating the contents of the postgis table containing all
kinds of information about service points located either in Varsinais-Suomi
or Satakunta region.
> ptvupdate.txt

If you wish to create scheduled jobs with either one of these jobs, just
copy-paste the contents of the corresponding text file to the psql terminal
and hit **ENTER**.

After the function exists, you can create a scheduled task e.g. via

`SELECT cron.schedule('00 */1 * * *', $$select kunnatupdate()$$);`

> This job executes the kunnatupdate function once in every hour; starting
> always at :00.

If you wish to execute a test run, we recommend to use kunnatupdate.txt
since it is quick job to execute. In contrast to that, running a scheduled
job executing ptvupdate function takes around 20 minutes. Naturally the
performance would get much better if the area of interest would be smaller.

If you wish to delete a plpgsql function you have created earlier (e.g.
kunnatupdate), just run `DROP function kunnatupdate();`.

## Scheduling without plpgsql functions

The usage of plpgsql functions is not necessary. If you wish, you can also
alter the SQL commands directly into the scheduling command like

```
SELECT cron.schedule('*/1 * * * *',  $$drop server if exists dev_fdw cascade;
drop foreign table if exists <foreign-table-name>;
drop table if exists <table-name>;

create server dev_fdw foreign data wrapper multicorn options ( wrapper 'ptvfdw.ptvForeignDataWrapper' );

create foreign table <foreign-table-name>(
 id int,
 name varchar
 ) server dev_fdw options(
 url '<url-to-json-api-containing-the-desired-data');

create table <table-name>(
 id int,
 name varchar
);

insert into <table-name>(id, name) select id, name from <foreign-table-name>;

drop foreign table if exists <foreign-table-name>;$$);
```

## Utilizing PTV_fdw without scheduling

If you do not wish to create a scheduled task for updating the contents
of the table regularly but rather wish to create it just once, a handy way
to achieve this is to run the taulumuod.sql file. In this file there are
scripts which create the FDW server and the foreign table allowing us to
fetch data from the JSON API. There are also SQL clauses which create another
table (best not to store data in foreign tables since they are not permanent
database objects) and insert the data from foreign table into it). In addition
to that, a bunch of data modification related SQL clauses are included into the
file. Just execute the whole file at once (e.g. via PgAdmin or psql terminal).
