FROM debian
MAINTAINER Gerolf Ziegenhain "gerolf.ziegenhain@gmail.com"
ENV DEBIAN_FRONTEND noninteractive

# Following 'How do I add or remove Dropbox from my Linux repository?' - https://www.dropbox.com/en/help/246
RUN apt-get update
RUN echo nameserver 1.1.1.1 > /etc/resolv.conf
RUN apt-get -y install gnupg2
RUN apt-get -y install libatomic1
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E
#RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E

# Fix according to https://www.dropboxforum.com/t5/Dropbox-installs-integrations/Headless-install-on-Debian-libglapi-so-0-cannot-open-shared/td-p/396457
RUN apt-get -y install libc6 libglapi-mesa libxdamage1 libxfixes3 libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1


RUN echo 'deb http://linux.dropbox.com/debian buster main' > /etc/apt/sources.list.d/dropbox.list \
	&& apt-get -qqy update 
# Note 'ca-certificates' dependency is required for 'dropbox start -i' to succeed
RUN apt-get -qqy install ca-certificates curl python3-gpg dropbox \
	# Perform image clean up.
	&& apt-get -qqy autoclean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	# Create service account and set permissions.
	&& groupadd dropbox \
	&& useradd -m -d /dbox -c "Dropbox Daemon Account" -s /usr/sbin/nologin -g dropbox dropbox

# Dropbox is weird: it insists on downloading its binaries itself via 'dropbox
# start -i'. So we switch to 'dropbox' user temporarily and let it do its thing.
USER dropbox
RUN mkdir -p /dbox/.dropbox /dbox/.dropbox-dist /dbox/Dropbox /dbox/base \
	&& echo y | dropbox start -i

# Switch back to root, since the run script needs root privs to chmod to the user's preferrred UID
USER root

# Dropbox has the nasty tendency to update itself without asking. In the processs it fills the
# file system over time with rather large files written to /dbox and /tmp. The auto-update routine
# also tries to restart the dockerd process (PID 1) which causes the container to be terminated.
RUN mkdir -p /opt/dropbox \
	# Prevent dropbox to overwrite its binary
	&& mv /dbox/.dropbox-dist/dropbox-lnx* /opt/dropbox/ \
	&& mv /dbox/.dropbox-dist/dropboxd /opt/dropbox/ \
	&& mv /dbox/.dropbox-dist/VERSION /opt/dropbox/ \
	&& rm -rf /dbox/.dropbox-dist \
	&& install -dm0 /dbox/.dropbox-dist \
	# Prevent dropbox to write update files
	&& chmod u-w /dbox \
	&& chmod o-w /tmp \
	&& chmod g-w /tmp \
	# Prepare for command line wrapper
	&& mv /usr/bin/dropbox /usr/bin/dropbox-cli

# Install init script and dropbox command line wrapper
COPY run /root/
COPY dropbox /usr/bin/dropbox

# Fix for large amount of files
# cf. https://superuser.com/questions/1221215/dropbox-unable-to-monitor-dropbox-folder
#RUN echo fs.inotify.max_user_watches=100000 | tee -a /etc/sysctl.conf

#USER 1000

WORKDIR /dbox/Dropbox
EXPOSE 17500
VOLUME ["/dbox/.dropbox", "/dbox/Dropbox"]
ENTRYPOINT ["/root/run"]

# TBD: Health check via: dropbox running
