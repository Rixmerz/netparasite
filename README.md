# netparasite

Use the internet connection of every device around you at the same time.

Plug a phone in over USB, keep your laptop on Wi-Fi, and both links carry
traffic together. Each extra phone, or any computer that shares its internet
over a cable, adds another link.

A single Wi-Fi card can only join one network at a time, and a single TCP
connection always rides one link. So netparasite works at two levels:

| Tool | What it does | Gain |
|---|---|---|
| `multidl` | Downloads one file over every link at once with parallel HTTP range requests | One big download gets the sum of all links |
| `multipath/` | ECMP default route: each new connection of the whole system goes out a different link | Browsers, updates, anything with many connections |

## Requirements

- `multidl`: Linux 5.7+, macOS or Windows 10+, Python 3.9+, no extra packages
- System-wide route: Linux only
- NetworkManager, for the system-wide route
- `adb` (android-tools), optional, to switch on USB tethering automatically

## multidl

```sh
install -m 755 multidl ~/.local/bin/multidl
multidl https://example.com/big.iso
multidl https://example.com/big.iso --cap usb=500   # stop after 500 MB on USB links
multidl https://example.com/big.iso -i wlan0 -i usb0 # pick links by hand
```

What it does by itself:

- Finds every interface with a default route. Android phones with USB
  debugging authorized get tethering turned on through adb.
- Drops links that leave through the same public IP (a phone tethering the
  same Wi-Fi you are already on adds nothing).
- Splits the file into chunks sized from each link's measured speed, steals
  work from slow links at the end, and opens more connections per link only
  while they keep paying off.
- Backs off when a server answers 429/503 and remembers, per server and per
  link, how many connections worked. State lives in
  `~/.local/state/multidl/state.json`; `--forget` starts from scratch.

The server must support HTTP range requests.

### macOS

```sh
install -m 755 multidl ~/.local/bin/multidl
multidl https://example.com/big.iso
```

Links come from `netstat -rn -f inet`: the primary default route plus the
scoped one (flag `I`) macOS keeps for every other service with a router, so a
phone tethering over USB next to Wi-Fi shows up as a second link. Tunnels
(`utun*`, `ipsec*`) are skipped: a VPN is not an uplink of its own. Each
connection is scoped to its interface with `IP_BOUND_IF`, which needs no root.
USB links are recognized by their hardware port name (`networksetup
-listallhardwareports`, for example "iPhone USB"). Android tethering through adb
asks for NCM, which macOS supports natively (Android 11+); RNDIS needs a
third-party driver. There is no system-wide route on macOS.

Traffic bound to a physical interface leaves outside any VPN. A corporate
client that enforces its tunnel (Cloudflare WARP, Zscaler and similar) refuses
those connections, and may block range downloads even through the tunnel; use
`multidl` on a network you control.

### Windows

```powershell
python multidl https://example.com/big.iso
```

Links come from `Get-NetRoute` (every interface with a default route), and each
connection is bound to its interface's IPv4 address. Android tethering through
adb works the same way if `adb.exe` is on the PATH. State lives in
`%LOCALAPPDATA%\multidl\state.json`. There is no system-wide route on Windows;
apps such as Speedify or Connectify Dispatch cover that.

## System-wide multipath route

```sh
sudo sh multipath/install.sh     # install
sudo sh multipath/uninstall.sh   # remove
```

A NetworkManager dispatcher script adds one extra default route (metric 50)
that spreads connections across every link with a default route, and
rebuilds it whenever a link comes up or goes down. NetworkManager's own routes
stay untouched. `net.ipv4.fib_multipath_hash_policy = 1` hashes by port, so
different connections to the same host can still use different links.

Caveats:

- One connection stays on one link. A single-stream download does not get
  faster; use `multidl` for that.
- Sites that pin a login to an IP may ask you to sign in again.
- Links are weighted equally. Phone tethering is not switched on
  automatically outside `multidl`; enable it on the phone.
- Every link with a default route is used, including one that shares the
  same upstream as another.

## Adding links

- Android phone: USB cable, USB debugging on, tethering via `multidl` or the
  phone's settings.
- Another computer: an Ethernet cable plus internet connection sharing on that
  computer (Windows: adapter properties, Sharing tab). A plain USB-A to USB-A
  cable does not work between two computers.
- A second Wi-Fi network: a USB Wi-Fi adapter.

## License

MIT
