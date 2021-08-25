# Description
Linux Malware Detection (LMD) dockerized on Ubuntu.
The project is located [here](https://github.com/rfxn/linux-malware-detect).

# Docker run
(Work In Progress)
docker run --rm -it -v /dir/to/scan:/scan neomediatech/lmd

and then scan:

/usr/local/maldetect/maldet -a /scan

# CLI usage
You can run it through the 'maldet' command, the '--help'
option gives a detailed summary of usage options:

    -b, --background
      Execute operations in the background, ideal for large scans
      e.g: maldet -b -r /home/?/public_html 7

    -u, --update [--force]
       Update malware detection signatures from rfxn.com

    -d, --update-ver [--force]
       Update the installed version from rfxn.com

    -m, --monitor USERS|PATHS|FILE
       Run maldet with inotify kernel level file create/modify monitoring
       If USERS is specified, monitor user homedirs for UID's > 500
       If FILE is specified, paths will be extracted from file, line spaced
       If PATHS are specified, must be comma spaced list, NO WILDCARDS!
       e.g: maldet --monitor users
       e.g: maldet --monitor /root/monitor_paths
       e.g: maldet --monitor /home/mike,/home/ashton

    -k, --kill
       Terminate inotify monitoring service

    -r, --scan-recent PATH DAYS
       Scan files created/modified in the last X days (default: 7d, wildcard: ?)
       e.g: maldet -r /home/?/public_html 2

    -a, --scan-all PATH
       Scan all files in path (default: /home, wildcard: ?)
       e.g: maldet -a /home/?/public_html

    -c, --checkout FILE
       Upload suspected malware to rfxn.com for review & hashing into signatures

    -l, --log
       View maldet log file events

    -e, --report SCANID email
       View scan report of most recent scan or of a specific SCANID and optionally
       e-mail the report to a supplied e-mail address
       e.g: maldet --report
       e.g: maldet --report list
       e.g: maldet --report 050910-1534.21135
       e.g: maldet --report SCANID user@domain.com

    -E, --dump-report SCANID
       Similar to -e/--report except dumps the report to stdout instead.
       e.g: maldet --dump-report
       e.g: maldet --dump-report 050910-1534.21135

    -s, --restore FILE|SCANID
       Restore file from quarantine queue to orginal path or restore all items from
       a specific SCANID
       e.g: maldet --restore /usr/local/maldetect/quarantine/config.php.23754
       e.g: maldet --restore 050910-1534.21135

    -q, --quarantine SCANID
       Quarantine all malware from report SCANID
       e.g: maldet --quarantine 050910-1534.21135

    -n, --clean SCANID
       Try to clean & restore malware hits from report SCANID
       e.g: maldet --clean 050910-1534.21135

    -U, --user USER
       Set execution under specified user, ideal for restoring from user quarantine or
       to view user reports.
       e.g: maldet --user nobody --report
       e.g: maldet --user nobody --restore 050910-1534.21135

    -co, --config-option VAR1=VALUE,VAR2=VALUE,VAR3=VALUE
       Set or redefine the value of conf.maldet config options
       e.g: maldet --config-option email_addr=you@domain.com,quarantine_hits=1

    -p, --purge
       Clear logs, quarantine queue, session and temporary data.
