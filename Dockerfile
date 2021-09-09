#
# Dockerfile for iptables
#

FROM alpine

RUN apk add -U iproute2 tini vnstat \
  && ln -s /usr/lib/tc /lib/tc \
  && sed -i '/UseLogging/s/2/0/' /etc/vnstat.conf \
  && sed -i '/RateUnit/s/1/0/' /etc/vnstat.conf \
  && echo '*/5 * * * * bash /limit_bandwidth.sh >/etc/vnstat.log 2>&1' >>/var/spool/cron/crontabs/root \
  && chown root:cron /var/spool/cron/crontabs/root \
  && chmod 600 /var/spool/cron/crontabs/root

ENV LIMIT_PORT 8388
ENV LIMIT_CONN 5
ENV TCP_PORTS 80,443
ENV UDP_PORTS 53
ENV RATE 1mbit
ENV BURST 1kb
ENV LATENCY 50ms
ENV INTERVAL 60

ENV MAXTX="950"
ENV MAXALL="1000"
ENV MAXLIMTYPE="GiB"

EXPOSE $LIMIT_PORT

CMD crond && vnstatd -d \
    && iptables -F \
    && iptables -A INPUT -p tcp -m state --state NEW --dport $LIMIT_PORT -m connlimit --connlimit-above $LIMIT_CONN -j DROP \
    && iptables -A OUTPUT -p tcp -m state --state NEW -m multiport ! --dports $TCP_PORTS -j DROP \
    && iptables -A OUTPUT -p udp -m state --state NEW -m multiport ! --dports $UDP_PORTS -j DROP \
    && tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY \
    && watch -n $INTERVAL tc -s qdisc ls dev eth0
