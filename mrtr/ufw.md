# UFW

I use Ubuntu’s Uncomplicated firewall because it is available on Ubuntu and it's very simple.


## Install UFW

if ufw is not installed by default be sure to install it first.

```
$ sudo apt-get install ufw
```


## NAT
If you needed ufw to NAT the connections from the external interface to the internal the solution is pretty straight forward.
In the file /etc/default/ufw change the parameter DEFAULT_FORWARD_POLICY

```
DEFAULT_FORWARD_POLICY="ACCEPT"
```

Also configure /etc/ufw/sysctl.conf to allow ipv4 forwarding (the parameters is commented out by default). Uncomment for ipv6 if you want.

```
net.ipv4.ip_forward=1
#net/ipv6/conf/default/forwarding=1
#net/ipv6/conf/all/forwarding=1
```


The final step is to add NAT to ufw’s configuration. Add the following to /etc/ufw/before.rules just before the filter rules.

```
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]

# Forward traffic through eth0 - Change to match you out-interface
-A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't
# be processed
COMMIT
```


Now enable the changes by restarting ufw.

```
$ sudo ufw disable && sudo ufw enable
```


## FORWARD

For port forwardind just do something like this.

```
# NAT table rules
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# Port Forwardings
-A PREROUTING -i eth0 -p tcp --dport 22 -j DNAT --to-destination 192.168.1.10

# Forward traffic through eth0 - Change to match you out-interface
-A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# don't delete the 'COMMIT' line or these nat table rules won't
# be processed
COMMIT
```