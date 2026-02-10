# Changelog

## 2.0.0

- **Breaking:** Replace `listen_ports` with separate `listen_tcp_ports` and `listen_udp_ports` lists
- Add independent TCP and UDP port interception (can proxy TCP-only, UDP-only, or both)
- Add startup validation requiring at least one port list to be non-empty
- Omit `tcp:` / `udp:` config sections from daemon when the respective port list is empty
