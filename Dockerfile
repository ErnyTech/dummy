# Copyright Ernesto Castellotti <ernesto@castellotti.net>
# SPDX-License-Identifier: GPL-3.0-only

FROM debian:12-slim AS builder
MAINTAINER Ernesto Castellotti <mail@ernestocastellotti.it>

COPY dummy.d ./
RUN apt-get update && apt-get install -y gdc
RUN gdc -fno-druntime -nodefaultlibs -nostartfiles -fno-stack-protector -static -O3 dummy.d -o dummy

FROM scratch
MAINTAINER Ernesto Castellotti <mail@ernestocastellotti.it>
COPY --from=builder dummy /
CMD ["/dummy"]
