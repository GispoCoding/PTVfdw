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

Run taulumuod.sql file. In this file there are scripts which create the FDW server and the foreign table allowing us
to fetch data from the JSON API. There are also SQL clauses which create another table (best not to store data in
foreign tables since they are not permanent database objects) and insert
the data from foreign table into it). In addition to that, a bunch of data modification related
SQL clauses are included into the file. Just execute the whole file at once (e.g. via PgAdmin or docker terminal).