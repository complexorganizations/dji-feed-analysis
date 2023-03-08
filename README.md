### DJI feed analysis

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

### Note: If you can code, please join the discord, Your code will save the lives of actual people.
### Discord: https://discord.gg/Zrd68kbK

#### Connect your drone to cloud service provider for real time data analysis.

#### Requirements:
- Professional: DJI Mavic 3 `https://www.ebay.com/itm/304601807310`
- Enterprise: DJI Matrice 30 & Dock ``
- AWS & Google Cloud & Azure

### Overall Setup:
- Setup RTSP server.
- Forward all the fotage from drone to RTSP server.
- Forward all fotage from RTSP to CSP.

#### Terraform: comming soon.

#### How to install RTSP server with CSP connector?
``` bash
curl https://raw.githubusercontent.com/complexorganizations/dji-feed-analysis/main/installer.sh -o installer.sh
chmod +x installer.sh
bash installer.sh
rm -f installer.sh
```

#### Use Case:
- Find out a person's or an object's real-time coordinates.
- large-scale field scanning and automatically mapping the locations of things (People & Cars...).

#### Why are only these drone supported?
- Currently only these drones are supported since the flight path can be fully automated using [FlightHub](https://www.dji.com/flighthub-2)

#### How to stream the video feed from your DJI drone to the cloud?
- DJI APP > Settings > Transmission > Live Streaming Platforms > RTMP > `rtmp://localhost:1935/drone_0?user=Administrator&pass=Password`

#### How to transfer waypoints from DJI flight hub to controller?
- ``

#### How to watch the stream live via vlc?
- VLC APP > Media > Open Network Stream > `rtsp://Administrator:Password@localhost:8554/drone_0`

#### Which controlls are supported?
- RC-N1
- DJI RC Pro

#### Why are the other conrollers not supported?
- DJI RC ***Includes Screen***

#### Is it better to use android or ios?
- Android has a bitrate of 5 while ios has a bitrate of 3.

#### What settings should the DJI use?
- Disable cache for videos *Useless storage*
- Enable subtitles for videos (location; gps cordnates)... post analysis.
- Record in 4k 60fps; use the auto feature.

Notes:
- Make sure you have 30 MBPS Upload & 30 MBPS Download when connecting to the RTMP server.
