#!/bin/bash

ORG_ARGS="$*"

SCRIPTS_DIR=$(dirname "$0")
MAIN_SCRIPT_NAME=$(basename "$0")

CREATE_TABLES_SQL="$SCRIPTS_DIR/exported/create-tables.sql"
DESIGN_PNG="$SCRIPTS_DIR/exported/db-design.png"
DESIGN_FILE="$SCRIPTS_DIR/design.dbm"
mkdir -p "$SCRIPTS_DIR/exported"


STORED_SQL_FUNCTIONALITIES_DIR="$SCRIPTS_DIR/stored-sql-functionalities/"
PERSISTENCE_SQL_DIR="$SCRIPTS_DIR/persistence"

usage () {
  cat << USAGE >&2

This script is intended to deploy database for development as well as for production.
It requires 5 parameters provided via argument, env file, env vars (descending priority).
It must be run as postgres or using 'sudo -H -u postgres bash -c "$MAIN_SCRIPT_NAME [ARGS]"'
Usage:

    ./$MAIN_SCRIPT_NAME [--env <ENV_FILE>] [--host <DB_HOST>] [--port <DB_PORT>] [--db <DB_NAME>] [--username <DB_USERNAME>] [--password <DB_PASSWORD>] [<OTHER_OPTS>]

    Possible env vars (also in env file) have to be named exactly the same as upper placeholders.
    Parameters specified via script arguments override those specified via env vars.

    <OTHER_OPTS> can be:
      1. --main-sql-modify-daemon - run watchdog on db definition in $SCRIPTS_DIR/exported/create-tables.sql, if any change db is recreated
      2. --other-sql-modify-daemon - as upper but on files in $SCRIPTS_DIR/stored-sql-functionalities/
      3. --export - if specified before deploying DB update sql db design using pgmodeler design.dbm file
      4. --only-export - do only export
      5. --drop - if specified drop DB before creation

USAGE
exit 1;
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            usage;
        ;;
        --env)
          ENV_FILE="$2"
          shift 2;
        ;;
        --main-sql-modify-daemon)
          MAIN_SQL_MODIFY_DAEMON='true';
          shift 1;
        ;;
        --other-sql-modify-daemon)
          OTHER_SQL_MODIFY_DAEMON='true';
          shift 1;
        ;;
        --export)
            EXPORT='true';
            shift 1;
            ;;
        --only-export)
            EXPORT='true';
            ONLY_EXPORT='true';
            shift 1;
        ;;
        --drop)
          DROP='true';
          shift 1;
        ;;
        --rerun)
          RERUN='true';
          shift 1;
        ;;
        -h|--host)
            __DB_HOST="$2";
            shift 2;
            ;;
        -p|--port)
            __DB_PORT="$2";
            shift 2;
            ;;
        -d|--db)
            __DB_NAME="$2"
            shift 2;
            ;;
        -u|--username)
            __DB_USERNAME="$2";
            shift 2;
            ;;
        -P|--password)
            __DB_PASSWORD="$2";
            shift 2;
            ;;

        *)
            usage;
            ;;
    esac
done



if [ ! "$RERUN" = 'true' ]; then
  if [ "$EXPORT" = 'true' ]; then
    if ! command -v "pgmodeler-cli" &> /dev/null; then
      echo "Could not find pgmodeler-cli, continuing with existing sql file"
      sleep 1
    else
      echo 'exporting fresh sql file from design'
      pgmodeler-cli --input "$DESIGN_FILE" --export-to-file --output "$CREATE_TABLES_SQL"
      pgmodeler-cli --input "$DESIGN_FILE" --export-to-png --output "$DESIGN_PNG"
      DB_DESIGN_EXPORT_DONE="true"
    fi

    if [ "$ONLY_EXPORT" = 'true' ]; then
      if [ "$DB_DESIGN_EXPORT_DONE" = "true" ]; then
        exit 0;
      else
        exit 1;
      fi
    fi
  fi


  if [ "$CONVERT" = 'true' ] && ! $CONVERT_SCRIPT; then
      echo "converting mock.ipynb to python script was not successful"
      sleep 1
  fi
fi

if [ -n "$ENV_FILE" ]; then
  source "$ENV_FILE"
fi


#### Parameteres concretization
DB_NAME=${__DB_NAME:-${DB_NAME:?"DB_NAME not set"}}
DB_USERNAME=${__DB_USERNAME:-${DB_USERNAME:?"DB_USERNAME not set"}}
DB_PASSWORD=${__DB_PASSWORD:-${DB_PASSWORD:?"DB_PASSWORD not set"}}
DB_HOST=${__DB_HOST:-${DB_HOST:?"DB_HOST not set"}}
DB_PORT=${__DB_PORT:-${DB_PORT:?"DB_PORT not set"}}


if [ ! $(whoami) = 'postgres' ]; then
  echo "script must be run as postgres or using: 'sudo -H -u postgres bash -c \"$MAIN_SCRIPT_NAME [ARGS]\"'" >&2;
  echo "trying to execute script using sudo..., press any key to continue or crt+C to terminate"
  read
  sudo -H -u postgres LOCAL_USER=$(whoami) \
    bash -c "$0 $ORG_ARGS --rerun"
  exit 0;
fi



# disconnect everyone from database in order to recreate it //if dev locally it might be helpful
terminate() {
  psql -c "select pg_terminate_backend(pid) from pg_stat_activity where datname='$DB_NAME';"
}
drop() {
  psql -c "DROP DATABASE IF EXISTS \"$DB_NAME\""
  psql -c "DROP USER IF EXISTS \"$DB_USERNAME\""
}

create_main() {
  psql -c "CREATE USER \"$DB_USERNAME\" WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
  psql -c "CREATE DATABASE \"$DB_NAME\" OWNER '$DB_USERNAME'"
  (export PGPASSWORD=$DB_PASSWORD; psql -U "$DB_USERNAME" -d "$DB_NAME" -a -f "$CREATE_TABLES_SQL")
}

exec_all_sql() {
  DIR="$1"
  if [ -d "$DIR" ]; then
      for p in $(find "$DIR" -name "*.sql") ; do
        echo "use of $p"
        psql -d "$DB_NAME" -a -f "$p"
      done;
    fi
}

create_other() {
  exec_all_sql "$STORED_SQL_FUNCTIONALITIES_DIR"
  exec_all_sql "$PERSISTENCE_SQL_DIR"
}

terminate
if [ "$DROP" = 'true' ]; then
  drop
fi
create_main
create_other


if [ "$MAIN_SQL_MODIFY_DAEMON" = 'true' ]; then
  inotifywait --monitor --recursive --event modify "$SCRIPTS_DIR/exported/" |
    while read file_path file_event file_name; do
      echo ${file_path}${file_name} event: ${file_event};
      mkdir -p "$SCRIPTS_DIR/cache/dumps"
      SWP_DUMP="$SCRIPTS_DIR/cache/dumps/.dump.swp"
      pg_dump --data-only --format=tar -d "$DB_NAME" --file="$SWP_DUMP";
      terminate
      psql -c "DROP SCHEME public CASCADE;";
      psql -c "CREATE SCHEME public;";
      create_main
      create_other
      pg_restore --data-only -d "$DB_NAME" "$SWP_DUMP";
      echo ${file_path}${file_name} event: ${file_event};
    done &
fi
if [ "$OTHER_SQL_MODIFY_DAEMON" = 'true' ]; then
  inotifywait --monitor --recursive --event modify "$STORED_SQL_FUNCTIONALITIES_DIR" |
    while read file_path file_event file_name; do
      echo ${file_path}${file_name} event: ${file_event};
      psql -d "$DB_NAME" -a -f "${file_path}${file_name}";
      echo ${file_path}${file_name} event: ${file_event};
    done &
fi
