FROM alpine:edge

RUN apk add abuild curl tar make linux-headers patch g++ git gcc ncurses-dev autoconf file
RUN adduser -G abuild -D builder
RUN su builder -c 'abuild-keygen -a -n'
RUN cp /home/builder/.abuild/*.pub /etc/apk/keys

RUN git clone --depth 1 https://git.alpinelinux.org/aports

RUN chown -R builder:abuild /aports

RUN printf "export JOBS=$(getconf _NPROCESSORS_ONLN)\nexport MAKEFLAGS=-j$(getconf _NPROCESSORS_ONLN)\n" >> /etc/abuild.conf

COPY aports.patch /tmp/
RUN cd /aports && patch -p1 < /tmp/aports.patch

# we generate the following set of "steps" to shorten the time
# to fix the issues if the build fails mid point
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 0'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 5'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 10'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 15'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 20'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 25'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 30'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 35'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 40'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 45'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 50'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 55'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 60'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 65'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 70'
RUN busybox su builder -c 'cd /aports && sh -x ./scripts/bootstrap.sh riscv64 71'
