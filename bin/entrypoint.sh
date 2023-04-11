#!/usr/bin/env bash

maldet -u
#maldet -d

echo "to scan a directory run (for example):"
echo "maldet -a /var/www/clients"
echo "to show the last report:"
echo "maldet --report"
echo "to show the last log:"
echo "maldet -l"
echo "to show the report list:"
echo "maldet --report list"

exec "$@"
