FROM ghcr.io/nforceroh/k8s-alpine-baseimage:3.23

ARG \
  BUILD_DATE=now \
  VERSION=unknown 

LABEL \
  org.label-schema.maintainer="Sylvain Martin (sylvain@nforcer.com)" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.vcs-url="https://github.com/nforcer/k8s-idrac-fans" \
  org.label-schema.vcs-ref="${VERSION}" \
  org.label-schema.schema-version="1.0"

  # ENV IDRAC_HOST 192.168.1.100
ENV \
  IDRAC_HOST=local \
  IDRAC_USERNAME=admin \
  FAN_SPEED=5 \
  CPU_TEMPERATURE_THRESHOLD=50 \
  CHECK_INTERVAL=60 \
  DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=false \
  KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT=false

### Install Dependencies
RUN apk add --no-cache ipmitool grep

### Add Files
ADD --chmod=755 /content/etc/s6-overlay /etc/s6-overlay
ADD --chmod=755 /content/app /app


ENTRYPOINT [ "/init" ]
