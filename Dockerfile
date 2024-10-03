# Use the latest Alpine image
FROM alpine:latest

ENV APP_NAME="warp-plus_linux-amd64.zip"
ENV GITHUB_REPO="bepass-org/warp-plus"
ENV GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
ENV INSTALL_DIR="/opt/warp-plus"
ENV RUN_OPTIONS="--gool --scan --bind 0.0.0.0:8086"

RUN apk add --no-cache \
    curl \
    jq \
    unzip

# Download the specific asset (warp-plus_linux-amd64.zip) from the latest GitHub release, unzip it, and make the 'warp-plus' binary executable
RUN mkdir -p $INSTALL_DIR \
    && curl -s $GITHUB_API_URL | jq -r '.assets[] | select(.name == "warp-plus_linux-amd64.zip") | .browser_download_url' \
    | xargs curl -L -o $INSTALL_DIR/$APP_NAME \
    && unzip $INSTALL_DIR/$APP_NAME -d $INSTALL_DIR \
    && chmod 700 $INSTALL_DIR/warp-plus \
    && chown warp-plus:warp-plus $INSTALL_DIR/warp-plus \
    && rm $INSTALL_DIR/$APP_NAME

COPY warp_healthcheck.sh /usr/local/bin/warp_healthcheck.sh

RUN addgroup --system --gid 1001 warp-plus
RUN adduser --system --uid 1001 warp-plus

RUN chown warp-plus:warp-plus /usr/local/bin/warp_healthcheck.sh \
    && chmod 700 /usr/local/bin/warp_healthcheck.sh  # Make it executable for the owner only

WORKDIR $INSTALL_DIR

USER warp-plus

EXPOSE 8086

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD /usr/local/bin/warp_healthcheck.sh

ENTRYPOINT ["sh", "-c", "./warp-plus $RUN_OPTIONS"]