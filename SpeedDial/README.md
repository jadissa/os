## Install package
```
cd /your/path/to/SpeedDial/
/bin/bash install.sh
```

## Make cron
```
crontab -e 
0 */2 * * * cd /your/path/to/SpeedDial/ && /bin/bash speed.sh >> speed_dial.log 2>&1 && /bin/php dial.php
```

## Configure image
Geektool URL should be set to file:///your/path/to/SpeedDial/dial.png

## Test
```
cd /your/path/to/SpeedDial/ && /bin/bash speed.sh && /bin/php dial.php
```

## Issues
```
cd /your/path/to/SpeedDial/ && tail -f speed_dial.log
```
https://downdetector.com/status/speedtest/

## Screenshots
<p float="left">
  <img src="yikes.png" width="400" />
</p>