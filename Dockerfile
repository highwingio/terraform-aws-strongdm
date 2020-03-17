FROM quay.io/sdmrepo/relay

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

COPY files/entrypoint.sh /bin/entrypoint.sh

ARG GIT_COMMIT_SHA
ENV GIT_COMMIT_SHA ${GIT_COMMIT_SHA}

RUN echo $GIT_COMMIT_SHA > built-from-git-commit-sha

ENTRYPOINT ["/tini", "--"]
# Run your program under Tini
CMD ["entrypoint.sh"]
