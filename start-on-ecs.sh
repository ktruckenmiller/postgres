#!/usr/bin/env bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ "${1:0:1}" = '-' ]; then
	set -- postgres "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'postgres' ] && [ "$(id -u)" = '0' ]; then
	mkdir -p "$PGDATA"
	chown -R postgres "$PGDATA"
	chmod 700 "$PGDATA"

  echo "Settings creds...."
  export POSTGRES_DB=$(ssm_get_parameter $SSM_PATH/db_name)
  export POSTGRES_USER=$(ssm_get_parameter $SSM_PATH/db_user)
  export POSTGRES_PASSWORD=$(ssm_get_parameter $SSM_PATH/db_password)
  echo "Finding file"
  export FILE_NAME=${FILE_NAME:-$(aws s3 ls s3://$S3_BUCKET$SSM_PATH/ | sort | tail -n 1 | awk '{print $4}')}
  echo "Download file from bucket: $S3_BUCKET with a prefix of $S3_PREFIX/$FILE_NAME"
  s3 get --bucket $S3_BUCKET --prefix $S3_PREFIX --file-name $FILE_NAME
  chown -R postgres:postgres $FILE_NAME
  echo "Done downloading"

	echo "Starting ngrok"
	ngrok tcp 5432 --remote-addr=1.tcp.ngrok.io:20622 -authtoken $(ssm_get_parameter ngrok.token) -log=stdout &


	mkdir -p /var/run/postgresql
	chown -R postgres /var/run/postgresql
	chmod 775 /var/run/postgresql

	# Create the transaction log directory before initdb is run (below) so the directory is owned by the correct user
	if [ "$POSTGRES_INITDB_WALDIR" ]; then
		mkdir -p "$POSTGRES_INITDB_WALDIR"
		chown -R postgres "$POSTGRES_INITDB_WALDIR"
		chmod 700 "$POSTGRES_INITDB_WALDIR"
	fi

	exec su-exec postgres "$BASH_SOURCE" "$@"
fi







if [ "$1" = 'postgres' ]; then
	mkdir -p "$PGDATA"
	chown -R "$(id -u)" "$PGDATA" 2>/dev/null || :
	chmod 700 "$PGDATA" 2>/dev/null || :

	# look specifically for PG_VERSION, as it is expected in the DB dir
	if [ ! -s "$PGDATA/PG_VERSION" ]; then
		file_env 'POSTGRES_INITDB_ARGS'
		if [ "$POSTGRES_INITDB_WALDIR" ]; then
			export POSTGRES_INITDB_ARGS="$POSTGRES_INITDB_ARGS --waldir $POSTGRES_INITDB_WALDIR"
		fi
		eval "initdb --username=postgres $POSTGRES_INITDB_ARGS"

		# check password first so we can output the warning before postgres
		# messes it up
		file_env 'POSTGRES_PASSWORD'
		if [ "$POSTGRES_PASSWORD" ]; then
			pass="PASSWORD '$POSTGRES_PASSWORD'"
			authMethod=md5
		else
			# The - option suppresses leading tabs but *not* spaces. :)
			cat >&2 <<-'EOWARN'
				****************************************************
				WARNING: No password has been set for the database.
				         This will allow anyone with access to the
				         Postgres port to access your database. In
				         Docker's default configuration, this is
				         effectively any other container on the same
				         system.

				         Use "-e POSTGRES_PASSWORD=password" to set
				         it in "docker run".
				****************************************************
			EOWARN

			pass=
			authMethod=trust
		fi

		{
			echo
			echo "host all all all $authMethod"
		} >> "$PGDATA/pg_hba.conf"

		# internal start of server in order to allow set-up using psql-client
		# does not listen on external TCP/IP and waits until start finishes
		PGUSER="${PGUSER:-postgres}" \
		pg_ctl -D "$PGDATA" \
			-o "-c listen_addresses='localhost'" \
			-w start

		file_env 'POSTGRES_USER' 'postgres'
		file_env 'POSTGRES_DB' "$POSTGRES_USER"

		psql=( psql -v ON_ERROR_STOP=1 )

		if [ "$POSTGRES_DB" != 'postgres' ]; then
			"${psql[@]}" --username postgres <<-EOSQL
				CREATE DATABASE "$POSTGRES_DB" ;
			EOSQL
			echo
		fi

		if [ "$POSTGRES_USER" = 'postgres' ]; then
			op='ALTER'
		else
			op='CREATE'
		fi
		"${psql[@]}" --username postgres <<-EOSQL
			$op USER "$POSTGRES_USER" WITH SUPERUSER $pass;
		EOSQL
		echo

		psql+=( --username "$POSTGRES_USER" --dbname  "$POSTGRES_DB" )

		echo
    "${psql[@]}" --username postgres -v ON_ERROR_STOP=1 <<-EOSQL
      CREATE USER rdsadmin WITH SUPERUSER $pass;
      GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER
		EOSQL

    "${psql[@]}" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $FILE_NAME
    echo

		PGUSER="${PGUSER:-postgres}" \
		pg_ctl -D "$PGDATA" -m fast -w stop

		echo
		echo 'PostgreSQL init process complete; connecting to dns...'
		echo
    export IP_ADDRESS=${LOCAL_IP:-$(curl http://169.254.169.254/latest/meta-data/local-ipv4)}
	fi
fi

function stop {
	echo "Stopping..."
	sleep 20
	pg_ctl stop -m smart
}
trap stop SIGHUP SIGINT SIGTERM
"$@" &
