#!/bin/sh
pg_dump --username=indietools --dbname=indietools > /backups/$1
