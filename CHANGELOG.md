# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project uses [Semantic Versioning](https://semver.org/).

## [1.4.0] - 2026-11-11

### Added

- `netparasite` command: `list`, `status`, `doctor`, `tether`, `get`, and
  `netparasite LINK CMD` to run one command on one link through an
  `LD_PRELOAD` shim that binds its sockets to that interface.
- `netparasite pin DEST LINK` / `unpin`: persistent per-destination routes,
  applied by a NetworkManager dispatcher hook and a systemd path unit and
  timer, active only while the link is online.

### Fixed

- Multipath route: links without internet (captive portal, no signal) are
  left out, and the route is rebuilt only after NetworkManager has updated
  the metrics following a connectivity change.

## [1.3.0] - 2026-11-11

### Added

- `multidl` runs on macOS. Links come from the primary and scoped default
  routes in `netstat -rn -f inet`, tunnels (`utun*`, `ipsec*`) are skipped,
  and each connection is scoped to its interface with `IP_BOUND_IF` (no root).
- USB links on macOS are recognized by their hardware port name, and Android
  tethering through adb asks for NCM, which macOS supports natively.

### Notes

- Tested on macOS 26 behind Cloudflare WARP: link detection, tunnel filtering
  and `IP_BOUND_IF` connections work; WARP refuses traffic outside its tunnel
  and blocked range downloads, so a full multi-link download is not verified yet.

## 1.2 and earlier

No changelog was kept. `multidl` ran on Linux and Windows 10+, and the
system-wide multipath route on Linux.
