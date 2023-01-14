#!/bin/bash

RESOURCES_DIR="src/main/resources/db"
DESIGN_PATH="$RESOURCES_DIR/design.dbm"
CREATE_TABLES_SQL="$RESOURCES_DIR/create-tables.sql"
DESIGN_PNG="$RESOURCES_DIR/db-design.png"

if ! git diff --cached --quiet -- "$DESIGN_PATH"; then
  if ! pgmodeler-cli --input $DESIGN_PATH --export-to-file --output $CREATE_TABLES_SQL; then
      echo "Could not fulfil hook requirements <= cannot export sql and image from $DESIGN_PATH";
      exit 1;
  fi
  if ! pgmodeler-cli --input $DESIGN_PATH --export-to-png --output $DESIGN_PNG; then
    echo "Could not fulfil hook requirements <= cannot export sql and image from $DESIGN_PATH";
    exit 1;
  fi

  git add $DESIGN_PNG
  git add $CREATE_TABLES_SQL
fi
