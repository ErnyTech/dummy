# Copyright Ernesto Castellotti <ernesto@castellotti.net>
# SPDX-License-Identifier: GPL-3.0-only

FROM debian:sid-slim AS builder
MAINTAINER Ernesto Castellotti <mail@ernestocastellotti.it>

RUN apt-get update && apt-get install -y gdc-13
COPY dummy.d ./
RUN gdc-13 -fno-druntime -nodefaultlibs -nostartfiles -fno-stack-protector -static -O3 -ffunction-sections -Wl,--gc-sections dummy.d -o dummy

FROM scratch
MAINTAINER Ernesto Castellotti <mail@ernestocastellotti.it>
COPY --from=builder dummy /
CMD ["/dummy"]
