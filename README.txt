Example usage:

/--------\                                           /------\
| Office |-------------------------------------------| Home |
\--------/                                           \------/
(static IP)                                      (dynamic IP)
with Bind/named DNS server
+ webserver(apache)+php
+ ntpd-client
www.example.com                             najib.dyndns.example.com
*configure as dyndns server                 *configure dyndns client script 
                                             and cron schedule to run the script
