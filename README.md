<h1> Tor Deploy CLI 🧅 </h1>

A simple CLI script to deply Tor guard/middle nodes and obsf4 bridges.

Supported Distros:

- Debian Bullseye
- Ubunutu Bionic

Disclaimer:

- Make sure your server is <a href="https://github.com/gomidee/Hardening">hardened</a>
- For further details and troubleshooting follow the <a href="https://community.torproject.org/onion-services/setup/">official guide</a>
-  Use at your own risk

---
USAGE

-b --bridge      Deploy obfs4 Tor bridge

-r --relay       Deploy middle/guard Relay

-s --start       Run Tor systemD service

-l --logs        Display Tor logs"
