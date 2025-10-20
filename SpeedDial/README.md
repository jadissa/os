## Install package
```
cd /your/path/to/SpeedDial/
/bin/bash install.sh
```

## Make cron
```
crontab -e 
0 * * * * cd /your/path/to/SpeedDial/ && /bin/bash speed.sh >> speed_dial.log 2>&1
cat speed_dial.log
```

## Install image
Geektool URL should be set to file:///your/path/to/SpeedDial/dial.png

## Issues
https://downdetector.com/status/speedtest/