# iDRAC Fans

This image runs the Dell fan controller from
[Dell iDRAC Fan Controller](https://github.com/tigerblue77/Dell_iDRAC_fan_controller).
It polls server temperatures and applies a configured static fan speed, falling
back to Dell's automatic fan profile when CPU temperature crosses the
configured threshold. The image is based on
[`ghcr.io/nforceroh/alpine-base:3.24`](https://github.com/nforceroh/alpine-base)
and supervises the controller with s6-overlay.

> **Caution:** This container changes physical server fan behavior through IPMI.
> Use only with a supported Dell PowerEdge system, validate the speed and
> temperature threshold for your hardware, and monitor the logs after startup.

## Configuration

| Variable | Image default | Description |
| --- | --- | --- |
| `IDRAC_HOST` | `local` | Use local IPMI access when `local`; otherwise connect to this remote iDRAC host |
| `IDRAC_USERNAME` | `admin` | Remote iDRAC/IPMI username |
| `IDRAC_PASSWORD` | unset | Remote iDRAC/IPMI password; provide as a runtime secret |
| `IDRAC_USER` | unset | Compatibility fallback username when `IDRAC_USERNAME` is empty |
| `FAN_SPEED` | `5` | Target static fan speed as a percentage (or hexadecimal value such as `0x05`) |
| `CPU_TEMPERATURE_THRESHOLD` | `50` | Temperature in Celsius above which Dell's dynamic fan profile is restored |
| `CHECK_INTERVAL` | `60` | Seconds between temperature checks |
| `DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE` | `false` | On older supported server generations, disable Dell's third-party PCIe card cooling response |
| `KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT` | `false` | Keep the third-party card cooling setting when the container exits |

When `IDRAC_HOST=local`, the container needs access to a host IPMI device
(`/dev/ipmi0`, `/dev/ipmi/0`, or `/dev/ipmidev/0`). For remote management, set
the remote host and credentials instead.

## Usage

For local IPMI access:

```sh
docker run -d --name idrac-fans \
  --restart unless-stopped \
  --device /dev/ipmi0 \
  -e IDRAC_HOST=local \
  -e FAN_SPEED=5 \
  -e CPU_TEMPERATURE_THRESHOLD=50 \
  -e CHECK_INTERVAL=60 \
  ghcr.io/nforceroh/idrac-fans:latest
```

For remote iDRAC access, omit the local IPMI device and provide
`IDRAC_HOST`, `IDRAC_USERNAME`, and `IDRAC_PASSWORD` using runtime
configuration. Do not put real passwords in a committed Compose file.

Logs report the server model, sensor readings, target speed, and active
cooling profile:

```sh
docker logs -f idrac-fans
```

## Local development

```sh
make build   # build ghcr.io/nforceroh/idrac-fans:dev
make test    # build and run tests/run_tests.sh
```

The smoke test checks the s6 entrypoint and boot behavior; hardware-specific
fan control requires an actual supported Dell system. CI publishing is
handled by [`nforceroh/.github`](https://github.com/nforceroh/.github).
