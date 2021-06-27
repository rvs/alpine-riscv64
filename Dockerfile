FROM alpine:edge as build

ENV APORTS /home/builder/aports 

RUN apk add abuild curl tar make linux-headers patch g++ git gcc ncurses-dev autoconf file
RUN printf "export JOBS=$(getconf _NPROCESSORS_ONLN)\nexport MAKEFLAGS=-j$(getconf _NPROCESSORS_ONLN)\n" >> /etc/abuild.conf

RUN adduser -G abuild -D builder
RUN su builder -c 'git config --global user.email "builder@projecteve.dev" && git config --global user.name "Project EVE"'
RUN su builder -c 'abuild-keygen -a -n'
RUN su builder -c 'mkdir /home/builder/packages'
RUN cp /home/builder/.abuild/*.pub /etc/apk/keys

# RUN su builder -c 'git clone --depth 1 https://github.com/rvs/aports.git $APORTS'
RUN su builder -c 'git clone --depth 1 https://git.alpinelinux.org/aports/ $APORTS'

# before we run the build - lets setup our future rootfs
RUN mkdir -p /rootfs/etc/apk/keys
RUN cp /etc/apk/keys/* /home/builder/.abuild/*.rsa.pub /rootfs/etc/apk/keys
RUN cp /etc/passwd* /etc/shadow* /etc/group* /rootfs/etc/
RUN printf "/home/builder/packages/main\n/home/builder/packages/community\n" > /rootfs/etc/apk/repositories
RUN tar -C / -cf - home/builder | tar -C /rootfs -xf -
RUN rm -rf /home/builder/packages && ln -s /rootfs/home/builder/packages /home/builder/packages

# we generate the following set of "steps" to shorten the time
# to fix the issues if the build fails mid point
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 0'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 5'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 10'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 15'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 20'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 25'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 30'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 35'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 40'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 45'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 50'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 55'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 60'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 65'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 70'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 75'

# FIXME: strictly speaking this shouldn't be needed
RUN apk add chrpath
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 80'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 85'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 90'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 95'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 100'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 110'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 120'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 130'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 140'
RUN busybox su builder -c 'cd $APORTS && sh -x ./scripts/bootstrap.sh riscv64 150'

WORKDIR /

RUN apk add --arch riscv64 -X /home/builder/packages/main --no-cache --initdb -p /rootfs busybox-static apk-tools-static
RUN chroot /rootfs /bin/busybox.static --install -s /bin
RUN chroot /rootfs /sbin/apk.static add apk-tools busybox alpine-baselayout alpine-base abuild

# now build the final image
FROM scratch

COPY --from=build /rootfs/ /

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
USER builder
WORKDIR /home/builder
CMD sh
