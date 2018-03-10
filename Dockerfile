FROM postgres:10.3-alpine
RUN apk update && apk add ca-certificates
ENV AWS_REGION=us-west-2
ENV AWS_DEFAULT_REGION=us-west-2
ENV IAM_ROLE=postgres-backup
COPY vendor/ssm_get_parameter /usr/bin/ssm_get_parameter
COPY vendor/s3-cli /usr/bin/s3-cli
COPY vendor/s3 /usr/bin/s3
COPY sync.sh /docker-entrypoint-initdb.d/sync.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/ssm_get_parameter
RUN chmod +x /docker-entrypoint-initdb.d/sync.sh
RUN chmod +x /usr/bin/s3-cli
RUN chmod +x /usr/bin/s3
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["postgres"]
