FROM postgres:10.3-alpine
RUN apk add --no-cache ca-certificates bash py-pip && \
    pip install awscli
ENV AWS_REGION=us-west-2
ENV AWS_DEFAULT_REGION=us-west-2
ENV IAM_ROLE=postgres-backup
COPY vendor/ssm_get_parameter /usr/bin/ssm_get_parameter
COPY entrypoint.sh /docker-entrypoint-initdb.d/docker-entrypoint.sh
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh
RUN chmod +x /usr/bin/ssm_get_parameter
RUN chmod +x /docker-entrypoint-initdb.d/docker-entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
# CMD ["postgres"]
