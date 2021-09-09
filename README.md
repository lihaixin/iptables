iptables
========

![](https://badge.imagelayers.io/vimagick/iptables:latest.svg)

- _iptables_: filter ports (allow: 53/UDP, 80/TCP, 443/TCP)
- _tc_: control traffic via [tbf][1]

## RUN

	docker run -d --restart=always --name=iptables --cap-add=NET_ADMIN lihaixin/iptables
	
	
	
```
shadowsocks:
  image: lihaixin/shadowsocks-libev
  environment:
    - DNS_ADDR=8.8.8.8
    - METHOD=chacha20
    - PASSWORD=9MLSpPmNt
  net: container:iptables
  restart: always

iptables:
  image: lihaixin/iptables
  ports:
    - "8388:8388"
  environment:
    - TCP_PORTS=80,443
    - UDP_PORTS=53
    - RATE=4mbit
    - BURST=4kb
    - LIMIT_PORT=8388
  cap_add:
    - NET_ADMIN
  restart: always

```

[1]: http://linux.die.net/man/8/tc-tbf
