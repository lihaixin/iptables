FROM alpine

RUN apk add -U iproute2 && ln -s /usr/lib/tc /lib/tc

ENV DURL 45.77.220.151
ENV SURL 103.84.89.149
ENV PORTS 6666
ENV RATE 2mbit
ENV BURST 100kb
ENV LATENCY 50ms
ENV INTERVAL 60

EXPOSE $PORTS/tcp $PORTS/udp

CMD iptables -t nat -F \
    && iptables -t nat -A PREROUTING -i eth0 -p udp --dport $PORTS -j DNAT --to-destination $DURL:$PORTS \
    && iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $PORTS -j DNAT --to-destination $DURL:$PORTS \
    && iptables -t nat -A POSTROUTING -p udp -d $DURL --dport $PORTS -j SNAT --to-source $SURL \
    && iptables -t nat -A POSTROUTING -p tcp -d $DURL --dport $PORTS -j SNAT --to-source $SURL \
    && tc qdisc add dev eth0 root tbf rate $RATE burst $BURST latency $LATENCY \
    && watch -n $INTERVAL tc -s qdisc ls dev eth0
