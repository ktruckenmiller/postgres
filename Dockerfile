FROM postgres:9.6.1-alpine
RUN apk update && apk add ca-certificates
ENV AWS_REGION=us-west-2
ENV AWS_DEFAULT_REGION=us-west-2
COPY vendor/ssm_get_parameter /usr/bin/ssm_get_parameter
COPY vendor/s3 /usr/bin/s3
COPY backup.sh /usr/bin/backup.sh
COPY restore.sh /usr/bin/restore.sh
RUN chmod +x /usr/bin/ssm_get_parameter
RUN chmod +x /usr/bin/s3
RUN chmod +x /usr/bin/backup.sh
RUN chmod +x /usr/bin/restore.sh
