## Install package
```
cd /path/to/SpeedDial/
/path/to/bash install.sh
```

## Enable Dial Generation
- Drag new 'Shell' Geeklet to your desktop
- Paste the following line into the Shell Command:
```cd /path/to/SpeedDial/ && /path/to/bash speed.sh >> speed_dial.log 2>&1 && /path/to/php dial.php```

## Enable Dial Display
- Drag new 'Image' Geeklet to your desktop
- Set local path to: /path/to/SpeedDial/dial.png

## Test
```
cd /path/to/SpeedDial/ && /path/to/bash speed.sh && /path/to/php dial.php
```

## Issues
```
cd /path/to/SpeedDial/ && tail -f speed_dial.log
```
https://downdetector.com/status/speedtest/

## Screenshots
<p float="left">
  <img src="yikes.png" width="400" />
</p>