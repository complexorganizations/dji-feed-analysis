#!/usr/bin/env bash
# https://github.com/complexorganizations/dji-feed-analysis

# Require script to be run as root
function super-user-check() {
    # This code checks to see if the script is running with root privileges.
    # If it is not, it will exit with an error message.
    if [ "${EUID}" -ne 0 ]; then
        echo "Error: You need to run this script as administrator."
        exit
    fi
}

# Check for root
super-user-check

# Get the current system information
function system-information() {
    # CURRENT_DISTRO is the ID of the current system
    # CURRENT_DISTRO_VERSION is the VERSION_ID of the current system
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        CURRENT_DISTRO=${ID}
    fi
}

# Get the current system information
system-information

# Pre-Checks system requirements
function installing-system-requirements() {
    if [ "${CURRENT_DISTRO}" == "debian" ]; then
        if { [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v git)" ] || [ ! -x "$(command -v ffmpeg)" ] || [ ! -x "$(command -v zip)" ] || [ ! -x "$(command -v unzip)" ]; }; then
            if [ "${CURRENT_DISTRO}" == "debian" ]; then
                apt-get update
                apt-get install coreutils git ffmpeg curl openssl tar apt-transport-https ca-certificates gnupg zip unzip -y
            fi
        fi
    else
        echo "Error: ${CURRENT_DISTRO} is not supported."
        exit
    fi
}

# check for requirements
installing-system-requirements

# Only allow certain init systems
function check-current-init-system() {
    # This code checks if the current init system is systemd or sysvinit
    # If it is neither, the script exits
    CURRENT_INIT_SYSTEM=$(ps --no-headers -o comm 1)
    case ${CURRENT_INIT_SYSTEM} in
    *"systemd"* | *"init"*) ;;
    *)
        echo "Error: ${CURRENT_INIT_SYSTEM} init is not supported (yet)."
        exit
        ;;
    esac
}

# Check if the current init system is supported
check-current-init-system

# Checking For Virtualization
function virt-check() {
    # This code checks if the system is running in a supported virtualization.
    # It returns the name of the virtualization if it is supported, or "none" if
    # it is not supported. This code is used to check if the system is running in
    # a virtual machine, and if so, if it is running in a supported virtualization.
    CURRENT_SYSTEM_VIRTUALIZATION=$(systemd-detect-virt --container)
    case ${CURRENT_SYSTEM_VIRTUALIZATION} in
    "docker" | "none") ;;
    *)
        echo "${CURRENT_SYSTEM_VIRTUALIZATION} virtualization is not supported (yet)."
        exit
        ;;
    esac
}

# Virtualization Check
virt-check

# Make sure the script is running inside docker or else exit the script.
function check-inside-docker() {
    if [ ! -f /.dockerenv ]; then
        echo "Error: This script isn't running inside docker."
        exit
    fi
}

# Make sure the application is running inside docker.
check-inside-docker

# Global variables
AMAZON_KINESIS_VIDEO_STREAMS_LATEST_RELEASE=$(curl -s https://api.github.com/repos/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp/releases/latest | grep zipball_url | cut -d'"' -f4)
AMAZON_KINESIS_VIDEO_STREAMS_FILE_NAME=$(echo "${AMAZON_KINESIS_VIDEO_STREAMS_LATEST_RELEASE}" | cut --delimiter="/" --fields=6)
AMAZON_KINESIS_VIDEO_STREAMS_GST_STREAMER_CONFIG="${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}/src/gstreamer/gstkvssink.cpp"
AMAZON_KINESIS_VIDEO_STREAMS_KVS_LOG_PATH="${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}/kvs_log_configuration"
AMAZON_KINESIS_VIDEO_STREAMS_OPEN_SOURCE_LOCAL_LIB_PATH="${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}/open-source/local/lib"
AMAZON_KINESIS_VIDEO_STREAMS_PATH="${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH}/kvs_gstreamer_sample"
AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH="${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}/build"
AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH="/etc/${AMAZON_KINESIS_VIDEO_STREAMS_FILE_NAME}"
AMAZON_KINESIS_VIDEO_STREAMS_TEMP_DOWNLOAD_PATH="/tmp/${AMAZON_KINESIS_VIDEO_STREAMS_FILE_NAME}.zip"

CSP_CONNECTOR_LATEST_RELEASE=$(curl -s https://api.github.com/repos/complexorganizations/csp-connector/releases/latest | grep browser_download_url | cut --delimiter='"' --fields=4 | grep $(dpkg --print-architecture) | grep linux)
CSP_CONNECTOR_APPLICATION="${CSP_CONNECTOR_PATH}/csp-connector"
CSP_CONNECTOR_CONFIG="${CSP_CONNECTOR_PATH}/config.json"
CSP_CONNECTOR_LATEST_FILE_NAME=$(echo "${CSP_CONNECTOR_LATEST_RELEASE}" | cut --delimiter="/" --fields=9)
CSP_CONNECTOR_PATH="/etc/csp-connector"
CSP_CONNECTOR_SERVICE="/etc/systemd/system/csp-connector.service"
CSP_CONNECTOR_TEMP_DOWNLOAD_PATH="/tmp/${CSP_CONNECTOR_LATEST_FILE_NAME}"

GOOGLE_CLOUD_VISION_AI_LATEST_RELEASE=$(curl -s https://api.github.com/repos/google/visionai/releases/latest | grep browser_download_url | cut --delimiter='"' --fields=4)
GOOGLE_CLOUD_VISION_AI_LEAST_FILE_NAME=$(echo "${GOOGLE_CLOUD_VISION_AI_LATEST_RELEASE}" | cut --delimiter="/" --fields=9)
GOOGLE_CLOUD_VISION_AI_TEMP_DOWNLOAD_PATH="/tmp/${GOOGLE_CLOUD_VISION_AI_LEAST_FILE_NAME}"

RTSP_SIMPLE_SERVER_LATEST_RELEASE=$(curl -s https://api.github.com/repos/aler9/rtsp-simple-server/releases/latest | grep browser_download_url | cut --delimiter='"' --fields=4 | grep $(dpkg --print-architecture) | grep linux)
RTSP_CONFIG_FILE_GITHUB_URL="https://raw.githubusercontent.com/complexorganizations/dji-feed-analysis/main/csp-connector/rtsp-simple-server.yml"
RTSP_SIMPLE_SERVER_CONFIG="${RTSP_SIMPLE_SERVER_PATH}/rtsp-simple-server.yml"
RTSP_SIMPLE_SERVER_LASTEST_FILE_NAME=$(echo "${RTSP_SIMPLE_SERVER_LATEST_RELEASE}" | cut --delimiter="/" --fields=9)
RTSP_SIMPLE_SERVER_PATH="/etc/rtsp-simple-server"
RTSP_SIMPLE_SERVER_SERVICE="/etc/systemd/system/rtsp-simple-server.service"
RTSP_SIMPLE_SERVER_TEMP_DOWNLOAD_PATH="/tmp/${RTSP_SIMPLE_SERVER_LASTEST_FILE_NAME}"
RTSP_SIMPLE_SERVICE_APPLICATION="${RTSP_SIMPLE_SERVER_PATH}/rtsp-simple-server"

# Install rtsp application.
function install-rtsp-application() {
    if [ ! -d "${RTSP_SIMPLE_SERVER_PATH}" ]; then
        mkdir -p "${RTSP_SIMPLE_SERVER_PATH}"
        curl -L "${RTSP_SIMPLE_SERVER_LATEST_RELEASE}" -o "${RTSP_SIMPLE_SERVER_TEMP_DOWNLOAD_PATH}"
        tar -xvf "${RTSP_SIMPLE_SERVER_TEMP_DOWNLOAD_PATH}" -C "${RTSP_SIMPLE_SERVER_PATH}"
        rm -f "${RTSP_SIMPLE_SERVER_TEMP_DOWNLOAD_PATH}"
        curl -L "${RTSP_CONFIG_FILE_GITHUB_URL}" -o "${RTSP_SIMPLE_SERVER_CONFIG}"
        chmod +x ${RTSP_SIMPLE_SERVICE_APPLICATION}
        if [ ! -f "${RTSP_SIMPLE_SERVER_SERVICE}" ]; then
            # This code creates the service file
            # The service file is stored in /etc/systemd/system/rtsp-simple-server.service
            echo "[Unit]
Wants=network.target
[Service]
ExecStart=${RTSP_SIMPLE_SERVICE_APPLICATION} ${RTSP_SIMPLE_SERVER_CONFIG}
[Install]
WantedBy=multi-user.target" >${RTSP_SIMPLE_SERVER_SERVICE}
            if [[ "${CURRENT_INIT_SYSTEM}" == *"systemd"* ]]; then
                systemctl daemon-reload
                systemctl enable rtsp-simple-server
                systemctl start rtsp-simple-server
            elif [[ "${CURRENT_INIT_SYSTEM}" == *"init"* ]]; then
                service rtsp-simple-server start
            fi
        fi
    fi
}

# Install the rtsp server.
install-rtsp-application

# Build the application.
function build-kensis-application() {
    if [ ! -d "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}" ]; then
        apt-get install build-essential pkg-config cmake m4 libssl-dev libcurl4-openssl-dev liblog4cplus-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base-apps gstreamer1.0-plugins-bad gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools -y
        curl -L "${AMAZON_KINESIS_VIDEO_STREAMS_LATEST_RELEASE}" -o "${AMAZON_KINESIS_VIDEO_STREAMS_TEMP_DOWNLOAD_PATH}"
        unzip "${AMAZON_KINESIS_VIDEO_STREAMS_TEMP_DOWNLOAD_PATH}" -d "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}"
        rm -f "${AMAZON_KINESIS_VIDEO_STREAMS_TEMP_DOWNLOAD_PATH}"
        # Change the path to the log file so the correct path is build everytime.
        # sed -i "s|../kvs_log_configuration|${AMAZON_KINESIS_VIDEO_STREAMS_KVS_LOG_PATH}|g" ${AMAZON_KINESIS_VIDEO_STREAMS_GST_STREAMER_CONFIG}
        mkdir -p "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH}"
        cmake -DBUILD_GSTREAMER_PLUGIN=TRUE -S "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_PATH}" -B "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH}"
        make -C "${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH}"
        # Add the path to the .profile file so that it can be used in the future
        echo -e "export GST_PLUGIN_PATH=${AMAZON_KINESIS_VIDEO_STREAMS_PRODUCER_BUILD_PATH}:$GST_PLUGIN_PATH\nexport LD_LIBRARY_PATH=${AMAZON_KINESIS_VIDEO_STREAMS_OPEN_SOURCE_LOCAL_LIB_PATH}:$LD_LIBRARY_PATH" >>~/.profile
        source ~/.profile
    fi
}

# Build the application.
build-kensis-application

# Run the application.
# AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} ${AMAZON_KINESIS_VIDEO_STREAMS_PATH} ${KINESIS_STREAM} "${RTSP_SERVER}"

# Install Google Cloud
function install-google-cloud() {
    if { [ ! -x "$(command -v gcloud)" ] || [ ! -x "$(command -v vaictl)" ]; }; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        apt-get update
        apt-get install google-cloud-cli -y
        # gcloud auth login --no-launch-browser
        # gcloud auth application-default login --no-launch-browser
        # gcloud services enable visionai.googleapis.com
        # Install Google cloud vision ai
        curl -L "${GOOGLE_CLOUD_VISION_AI_LATEST_RELEASE}" -o "${GOOGLE_CLOUD_VISION_AI_TEMP_DOWNLOAD_PATH}"
        apt-get install "${GOOGLE_CLOUD_VISION_AI_TEMP_DOWNLOAD_PATH}"
        rm -f "${GOOGLE_CLOUD_VISION_AI_TEMP_DOWNLOAD_PATH}"
    fi
}

# Install Google Cloud
install-google-cloud

# Feed the data into google cloud vision ai
# vaictl -p github-code-snippets -l us-central1 -c application-cluster-0 --service-endpoint visionai.googleapis.com send rtsp to streams dji-stream-0 --rtsp-uri rtsp://Administrator:Password@localhost:8554/drone_0

# Install the cloud connector.
function install-cps-connetor() {
    if [ ! -d "${CSP_CONNECTOR_PATH}" ]; then
        mkdir -p "${CSP_CONNECTOR_PATH}"
        curl -L "${CSP_CONNECTOR_LATEST_RELEASE}" -o "${CSP_CONNECTOR_TEMP_DOWNLOAD_PATH}"
        tar -xvf "${CSP_CONNECTOR_TEMP_DOWNLOAD_PATH}" -C "${CSP_CONNECTOR_PATH}"
        rm -f "${CSP_CONNECTOR_TEMP_DOWNLOAD_PATH}"
        chmod +x "${CSP_CONNECTOR_APPLICATION}"
        if [ ! -f "${CSP_CONNECTOR_SERVICE}" ]; then
            # This code creates the service file
            # The service file is stored in /etc/systemd/system/csp-connector.service
            echo "[Unit]
Wants=network.target
[Service]
ExecStart=${CSP_CONNECTOR_APPLICATION} -config=${CSP_CONNECTOR_CONFIG}
[Install]
WantedBy=multi-user.target" >${CSP_CONNECTOR_SERVICE}
            if [[ "${CURRENT_INIT_SYSTEM}" == *"systemd"* ]]; then
                systemctl daemon-reload
                systemctl enable csp-connector
                systemctl start csp-connector
            elif [[ "${CURRENT_INIT_SYSTEM}" == *"init"* ]]; then
                service csp-connector start
            fi
        fi
    fi
}

# Install the cloud connector
# install-cps-connetor

### Record a stream in the middleware instead of CSP
# ffmpeg -i rtsp://Administrator:Password@localhost:8554/drone_0 -c copy output.mp4

# Download and install youtube downloader
# curl -L https://github.com/yt-dlp/yt-dlp/releases/download/2023.03.04/yt-dlp_linux -o /usr/bin/yt-dlp
# chmod +x ./usr/bin/yt-dlp
# yt-dlp -S ext:mp4:m4a https://www.youtube.com/watch?v=lWqylqgAwgU
# mv DJI\ Mavic\ 3\ -\ Making\ Of\ ＂A\ Journey\ Above＂\ \[lWqylqgAwgU\].mp4 output.mp4

### Feed a test video into RTSP server.
# ffmpeg -re -stream_loop -1 -i output.mp4 -c copy -f rtsp rtsp://Administrator:Password@localhost:8554/test_0

# Install Go Language
# curl -LO https://get.golang.org/$(uname)/go_installer && chmod +x go_installer && ./go_installer && rm go_installer
