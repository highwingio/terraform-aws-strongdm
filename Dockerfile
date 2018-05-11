FROM quay.io/sdmrepo/relay

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
COPY files/entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/tini", "--"]
# Run your program under Tini
CMD ["entrypoint.sh"]

# something like this as a command..
#docker run -it --restart=always  -e SDM_ADMIN_TOKEN=$SDM_ADMIN_TOKEN1 --entrypoint=/bin/bash quay.io/sdmrepo/relay -c "sdm status >/dev/null; sdm relay create > /tmp/key; export SDM_RELAY_TOKEN=\$(cat /tmp/key); unset SDM_ADMIN_TOKEN ; sdm relay"
