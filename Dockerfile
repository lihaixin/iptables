FROM alpine

RUN apk add -U iproute2 && ln -s /usr/lib/tc /lib/tc

ENV URL us21.xingke.info
ENV PORTS 6666
ENV RATE 1mbit
ENV BURST 100kb
ENV LATENCY 50ms
ENV INTERVAL 60

EXPOSE $PORTS/tcp $PORTS/udp

CMD iptables -t nat -F \
    && iptables -t nat -A PREROUTING -i eth0 -p udp --dport $PORTS -j DNAT --to-destination $URL:$PORTS \
    && iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $PORTS -j DNAT --to-destination $URL:$PORTS \
    && tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY \
    && watch -n $INTERVAL tc -s qdisc ls dev eth0
