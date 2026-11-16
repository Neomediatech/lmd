#!/usr/bin/env bash

export PATH="$PATH:/usr/local/maldetect"

# optional: extra LMD config, e.g. LMD_CONFIG="email_addr=me@x.it,quarantine_hits=1"
if [ -n "${LMD_CONFIG:-}" ]; then
  maldet -co "$LMD_CONFIG"
fi

# LMD 2.x hands ClamAV signatures to clamscan only if the official ClamAV
# database (main.cvd/cld) is present; the _base image ships without it, so
# fetch/refresh it (incremental when /var/lib/clamav is a persistent volume)
if [ "${LMD_UPDATE_CLAMAV:-1}" != "0" ]; then
  freshclam --quiet || echo "WARNING: freshclam failed, ClamAV official signatures may be missing" >&2
fi

# update LMD signatures; do not abort if offline
if [ "${LMD_UPDATE_SIGS:-1}" != "0" ]; then
  maldet -u || echo "WARNING: signature update failed, using bundled signatures" >&2
fi

echo "to scan a directory run (for example):"
echo "maldet -a /scan"
echo "to show the last report:"
echo "maldet --report"
echo "to show the last log:"
echo "maldet -l"
echo "to show the report list:"
echo "maldet --report list"

exec "$@"
