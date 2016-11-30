FROM postgres:9.6.1-alpine
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
RUN chmod 700 /backup.sh
RUN chmod 700 /restore.sh
