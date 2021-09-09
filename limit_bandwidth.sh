#!/bin/sh
# limits are GiB or TiB

INTERFACE=`ip route | grep "default via" |awk '{ print $5}'`

# is vnstatd running?

pgrep vnstatd || vnstatd --config /etc/vnstat.conf --daemon

# get vnstat bandwidth

VNSTAT=`vnstat -i $INTERFACE --oneline`
DATATX=`echo $VNSTAT | cut -d ";" -f 10 | cut -d " " -f 1`
DATAALL=`echo $VNSTAT | cut -d ";" -f 11 | cut -d " " -f 1`
DATATXTYPE=`echo $VNSTAT | cut -d ";" -f 10 | cut -d " " -f 2`

# 超过流量总量,限速到1m,月初重置
if [ ! -f /tmp/limit ]; then
   if [ "$DATATXTYPE" = "$MAXLIMTYPE" ]; then
        if [ $(bc <<< "$DATATX >= $MAXTX") -eq 1 ]; then
                echo "WARNING TX bytes bandwidth limit hit!"
                tc qdisc add dev $INTERFACE root tbf rate $RATE burst $BURST latency $LATENCY
                touch /tmp/limit
        fi
        
        if [ $(bc <<< "$DATAALL >= $MAXALL") -eq 1 ]; then
                echo "WARNING TX and RX bytes bandwidth limit hit!"
                tc qdisc add dev $INTERFACE root tbf rate $RATE burst $BURST latency $LATENCY
                touch /tmp/limit
        fi
   fi
fi

if [ `date +%d` = 01 ]; then
        tc qdisc del dev $INTERFACE root tbf rate $RATE burst $BURST latency $LATENCY
        rm -rf /tmp/limit
fi
