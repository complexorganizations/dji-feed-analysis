### DJI To Cloud

# Made in 🗽 for ✊

#### Connect your drone to cloud service provider for real time data analysis.

#### Requirements:
- Professional: DJI Mavic 3 `https://www.ebay.com/itm/304601807310`
- Enterprise: DJI Matrice 30 & Dock ``

#### How to use?
```
curl https://raw.githubusercontent.com/complexorganizations/dji-feed-analysis/main/installer.sh -o installer.sh
chmod +x installer.sh
bash installer.sh
rm -f installer.sh
```

- Using waypoints automate the drone completely.

#### Use Case:
- Get the location of people.
- Get the location of objects in real time.

#### Why are only these drone supported?
- Currently only these drones are supported since the flight path can be fully automated.

#### How to connect your drone to the cloud?
- Settings > Transmission > Live Streaming Platforms > RTMP > `rtmp://localhost:1935/drone_0?user=Administrator&pass=Password`

#### How to transfer waypoints from DJI FH to device?
- ``

#### How to watch the stream live via vlc?
- `rtsp://Administrator:Password@localhost:8554/drone_0`

#### Which controlls are supported?
- RC-N1
- DJI RC Pro

#### Why are the other conrollers not supported?
- DJI RC

#### Is it better to use android or ios?
- Android has a bitrate of 5 while ios has a bitrate of 3.

#### What settings should the DJI use?
- Disable cache for videos
- Enable subtitles for videos (location; gps cordnates)... post analysis.
- Record in 4k 60fps; use the auto feature.

Notes:
- Use good wifi when using RTMP
