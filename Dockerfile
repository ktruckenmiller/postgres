FROM postgres:10.3-alpine
RUN apk add --no-cache ca-certificates bash curl py-pip && \
    pip install awscli
ENV AWS_REGION=us-west-2
ENV AWS_DEFAULT_REGION=us-west-2
ENV IAM_ROLE=postgres-backup
COPY vendor/. /usr/bin

COPY ngrok.yml /ngrok.yml
COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
RUN chmod +x /backup.sh
RUN chmod +x /usr/bin/ssm_get_parameter
RUN chmod u+x /usr/bin/s3

COPY start-on-ecs.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
# CMD ["postgres"]
