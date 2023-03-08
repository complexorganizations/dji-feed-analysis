### DJI feed analysis

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

### Note: If you can code, please join the discord, Your code will save the lives of actual people.
### Discord: https://discord.gg/Zrd68kbK

#### Connect your drone to cloud service provider for real time deep data analysis.
#### 100% fully automated drone using flight hub and automated vision using cloud services providers.

#### Requirements:
- Professional: DJI Mavic 3 `https://www.ebay.com/itm/304601807310`
- Enterprise: DJI Matrice 30 & Dock ``
- AWS & Google Cloud & Azure

#### Use Case:
- Use computer vision to instantly find people, vehicles, and other things on a coordinate system.
- For the highest operator safety, fully autonomous drone flying is preferred.

### Overall Setup:
- Establish a RTMP server and deploy cloud resources using terraform.
- Use RTMP to send all of the DJI drone's data to the cloud service providers.

#### Terraform: comming soon.

#### How to install RTSP server with CSP connector?
``` bash
curl https://raw.githubusercontent.com/complexorganizations/dji-feed-analysis/main/installer.sh -o installer.sh
chmod +x installer.sh
bash installer.sh
rm -f installer.sh
```

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
- DJI RC ***The one with the screen build in is NOT supported.***

#### Is it better to use android or ios?
- Android has a bitrate of 5 while ios has a bitrate of 3. ***Android***

#### What settings should the DJI use?
- Disable cache for videos *Useless storage*
- Enable subtitles for videos (location; gps cordnates)... post analysis.
- Record in 4k 60fps; use the auto feature.

#### Which cloud services are used?
- Amazon Virtual Private Cloud
- Amazon Elastic Load Balancer (ELB)
- Amazon Elastic Compute Cloud
- Amazon S3
- Amazon Interactive Video Service
- Amazon Kinesis Video Streams

- Virtual Private Cloud (VPC) | Google Cloud
- Cloud Load Balancing | Google Cloud
- Compute Engine Virtual Machines (VMs) | Google Cloud
- Vertex AI Vision | Google Cloud
- Cloud Storage | Google Cloud

Notes:
- Make sure you have 30 MBPS Upload & 30 MBPS Download when connecting to the RTMP server.
