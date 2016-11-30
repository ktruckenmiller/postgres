FROM postgres:9.6.1-alpine
ADD . /
RUN chmod 700 /backup.sh
RUN chmod 700 /restore.sh
RUN chmod 700 /standup.sh
