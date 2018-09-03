iptables for docker nat
========


## RUN

	docker run -d --restart=always --name=iptables.nat.us21 -p 6021:6666/tcp -p 6021:66666/udp --cap-add=NET_ADMIN lihaixin/iptables:nat


