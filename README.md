najibnsupdate
=============

dyndns/dynamic DNS update client
+ server (Bind/named) configuration howto

- support multi hostname for one client (one IP).
- support multi hostname for one clinet (different IP for different hostname (different location).
- only request update (to DNS/bind server) if client IP changed.
- only request the update once for multi hostname if same IP (location) for the hostnames.
- use standard DNS server (Bind/named); we provide the documentation on howto setup the server for dyndns.
- use standard nsupdate tool from Bind/named to update request.
- 