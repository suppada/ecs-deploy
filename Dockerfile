FROM fedora:latest
RUN dnf -y update && dnf -y install httpd
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]