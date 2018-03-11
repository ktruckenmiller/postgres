FROM elementar/s3-volume
COPY sync.sh /watch
RUN chmod +x /watch

VOLUME /data

ENTRYPOINT ["./watch"]
CMD ["/data"]
