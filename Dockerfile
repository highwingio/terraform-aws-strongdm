FROM quay.io/sdmrepo/relay

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update && \
  apt-get install -y curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/

COPY files/entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/tini", "--"]
# Run your program under Tini
CMD ["entrypoint.sh"]
