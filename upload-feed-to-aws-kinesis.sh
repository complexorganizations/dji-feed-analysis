sudo apt-get install pkg-config cmake m4 git build-essential jq -y
sudo apt-get install libssl-dev libcurl4-openssl-dev liblog4cplus-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools -y
cd /etc/
git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp.git
mkdir -p /etc/amazon-kinesis-video-streams-producer-sdk-cpp/build
cd /etc/amazon-kinesis-video-streams-producer-sdk-cpp/build
cmake -DBUILD_GSTREAMER_PLUGIN=TRUE ..
make
echo "export GST_PLUGIN_PATH=/etc/amazon-kinesis-video-streams-producer-sdk-cpp/build
export LD_LIBRARY_PATH=/etc/amazon-kinesis-video-streams-producer-sdk-cpp/open-source/local/lib" >> ~/.profile
source ~/.profile
AWS_ACCESS_KEY_ID=KEY AWS_SECRET_ACCESS_KEY=KEY AWS_DEFAULT_REGION=us-east-1 ./kvs_gstreamer_sample dji-stream-0 rtsp://admin:password@$(curl --ipv4 --connect-timeout 5 --tlsv1.3 --silent 'https://api.ipengine.dev' | jq -r '.network.ip'):8554/drone_0
