package main

import (
	"flag"
	"os"
	"sync"
)

var (
	applicationConfigFile   = "config.json"
	applicationLogFile      = "app.log"
	rtspServerStatusChannel = make(chan bool)
	rtspServerWaitGroup     sync.WaitGroup
	TestJSONValue           = AutoGenerated{}
)

// The layout for the json stuff.
type AutoGenerated struct {
	Num0 struct {
		Host                      string `json:"host"`
		AmazonKinesisVideoStreams struct {
			AwsAccessKeyID     string `json:"aws_access_key_id"`
			AwsSecretAccessKey string `json:"aws_secret_access_key"`
			AwsDefaultRegion   string `json:"aws_default_region"`
			KinesisStream      string `json:"kinesis_stream"`
		} `json:"amazon_kinesis_video_streams"`
		GoogleCloudVertexAiVision struct {
			ProjectName   string `json:"project_name"`
			GcpRegion     string `json:"gcp_region"`
			VertexStreams string `json:"vertex_streams"`
		} `json:"google_cloud_vertex_ai_vision"`
	} `json:"0"`
}

func init() {
	// Check if the config file exists in the current directory
	if fileExists(applicationConfigFile) == false {
		// Write a config file in the current directory if it doesn't exist
		writeToFile(applicationConfigFile, []byte(encodeStructToJSON(AutoGenerated{})))
		// Exit the application since the config file was written just now and content will not be in that file.
		exitTheApplication("Error: Just created the default configuration; please edit the configuration and launch the program again.")
	}
	// Check if there are any user provided flags in the request.
	if len(os.Args) > 1 {
		// Check if the config path is provided.
		tempUpdate := flag.String("config", "config.json", "The location of the config file.")
		flag.Parse()
		applicationConfigFile = *tempUpdate
	}
	// Print the sha256 of the file
	// fmt.Println(sha256OfFile(applicationConfigFile))
	// Check if the config file has not been modified
	if sha256OfFile(applicationConfigFile) == "0cb4e37fe05a3c6d5eb2a5778214e017c98b6a646e8b7e6ae21d6d33bba83c35f93ce87cfa552a366a4f5237dcecf4556c85d3db7338ad59173095b100ce421b" {
		// The file has not been modified
		exitTheApplication("Error: The config file has not been modified, Please modify it and try again.")
	}
	// Can check for rtsp server but
	// what u can easily do is run rtsp server on one server and run this on another server.
	// The list of app required for this to work.
	// kensis // google cloud vision ai.
	requiredApplications := []string{"vaictl"}
	// Check if the required application are present in the system
	for _, app := range requiredApplications {
		if commandExists(app) == false {
			exitTheApplication("Error: " + app + "is not installed in your system, Please install it and try again.")
		}
	}
	// Check if the config has the correct format and all the info is correct.
	if jsonValid(readFileAndReturnAsBytes(applicationConfigFile)) == false {
		exitTheApplication("Error: The config file is not a valid json file.")
	}
	// Now import the json into the application.
	TestJSONValue := unmarshalJSONIntoStruct([]byte(readFileAndReturnAsBytes(applicationConfigFile)), &AutoGenerated{})
	// Make sure the length of the json is not 0
	if len(TestJSONValue.(*AutoGenerated).Num0.Host) == 0 {
		exitTheApplication("Error: The host value is not set in the config file.")
	}
	// Make sure non of the values are deafult; if it is than exit.

	// Validate all the data thats imported in the app; test run the connection if possible.

	// Check if the rtsp server is alive and responding to requests
	rtspServerWaitGroup.Add(1)
	go checkRTSPServerAliveInBackground(TestJSONValue.(*AutoGenerated).Num0.Host, rtspServerStatusChannel)
}
