### DJI To Cloud

#### Connect your drone to cloud service provider for real time data analysis.

#### Requirements:
- DJI Mavic 3 (Professional) `https://www.ebay.com/itm/304601807310`
- DJI Matrice 30 & Matrice 30 Dock (Enterprise) ``

#### How to use?
- Setup a RTMP server using `rtsp-installer.sh`.
- Forward all RTMP from DJI to rtsp server;
- Forward video from RTMP to aws kinesis `upload-feed-to-aws-kinesis.sh`
- Forward video from RTMP to gcp vertex ai `upload-feed-into-vertex-ai.sh`
- Forward video from RTMP to azure video analyzer `upload-feed-into-video-analyzer.sh`
- using waypoints automate the missions.
- loop;
- Using aws u can train your own ML model for other purposes too.
- Using waypoints you can automated data collection.

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

#### Why are the other conrollers not supported?
- Since they don't support rtmp.

#### Is it better to use android or ios?
- Android has a bitrate of 5 while ios has a bitrate of 3.

#### What settings should the DJI use?
- Disable cache for videos
- Enable subtitles for videos (location; gps cordnates)... post analysis.
- Record in 4k 60fps; use the auto feature.

Notes:
- Use good wifi when using RTMP
