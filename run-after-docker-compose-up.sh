#!/bin/bash
DS_CONTAINER_NAME=ds
DOCKER_EXEC="docker exec $DS_CONTAINER_NAME"
$DOCKER_EXEC service supervisor stop
$DOCKER_EXEC psql -hmaster -Upostgres -f /var/www/onlyoffice/documentserver/server/schema/postgresql/removetbl.sql 
$DOCKER_EXEC psql -hmaster -Upostgres -f /var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql 
$DOCKER_EXEC psql -hmaster -Upostgres -c "SELECT master_create_distributed_table('task_result', 'id', 'hash')"
$DOCKER_EXEC psql -hmaster -Upostgres -c "SELECT master_create_distributed_table('doc_changes', 'id', 'hash')"
$DOCKER_EXEC psql -hmaster -Upostgres -c "SELECT master_create_worker_shards('doc_changes', 32, 2)"
$DOCKER_EXEC psql -hmaster -Upostgres -c "SELECT master_create_worker_shards('task_result', 32, 2)"
$DOCKER_EXEC service supervisor start
$DOCKER_EXEC supervisorctl start ds:example