## Description
[Linux Malware Detect (LMD)](https://github.com/rfxn/linux-malware-detect) v2.x with ClamAV, dockerized on Alpine
(base: `clamav/clamav:1.5_base`). Images are published on Docker Hub (`neomediatech/lmd`) and GHCR (`ghcr.io/neomediatech/lmd`).

## Tags
| Tag | Meaning |
|---|---|
| `latest` | Newest stable ClamAV (`clamav/clamav:latest_base`, now 1.5.x) + LMD 2.x |
| `1.5_base` | ClamAV 1.5 base + LMD 2.x |
| `1.4_base` | Legacy: ClamAV 1.4 base + LMD 1.6.x (no longer updated) |

LMD and clamav-unofficial-sigs are resolved to their latest GitHub release at build time, so nothing has to be bumped by hand: run the build workflow with `force-build=true` to pick up a new LMD release. The LMD version is shown by `maldet --version`.
Old Ubuntu-based images (`22.04`, LMD 1.6.x) on Docker Hub are deprecated.

## Docker run
Scan a directory (signatures are updated at every start):

`docker run --rm -v /dir/to/scan:/scan:ro neomediatech/lmd maldet -a /scan`

To retain signatures, logs and reports between runs (recommended: avoids re-downloading the ClamAV database):

```
LPATH="/srv/docker/containers/lmd/data"
docker run --rm -v /dir/to/scan:/scan \
  -v $LPATH/clamav/:/var/lib/clamav/ \
  -v $LPATH/sigs/:/usr/local/maldetect/sigs/ \
  -v $LPATH/sess/:/usr/local/maldetect/sess/ \
  -v $LPATH/logs/:/usr/local/maldetect/logs/ \
  neomediatech/lmd maldet -a /scan
```

Note: in this image `scan_ignore_root` is set to `0` (stock LMD skips files owned by root).
JSON output of the last scan: `maldet --json-report newest`.

## Environment variables
| Variable | Default | Description |
|---|---|---|
| `LMD_UPDATE_CLAMAV` | `1` | Run `freshclam` at start. LMD 2.x needs the official ClamAV DB (`main.cvd`) to pass signatures to `clamscan`; set `0` only if you mount an already populated `/var/lib/clamav` |
| `LMD_UPDATE_UNOFFICIAL` | `1` | Run `clamav-unofficial-sigs` at start (Sanesecurity and InterServer signatures; URLhaus is disabled because abuse.ch no longer publishes its ClamAV file, no key/registration needed; providers requiring keys are disabled) |
| `LMD_UPDATE_SIGS` | `1` | Run `maldet -u` at start |
| `LMD_CONFIG` | empty | LMD options passed to `maldet -co`, e.g. `quarantine_hits=1,email_addr=me@example.com` |

## CLI usage
Run `maldet --help` for the full list of options (scan, monitor, quarantine, restore, reports, JSON output).
