package main

var (
	applicationConfigFile = "config.json"
	applicationLogFile = "app.log"
)

func init() {
	// Check if the config file exists in the current directory
	if !fileExists(applicationConfigFile) {
		// Deafult config string.
		defaultConfigString := `{"rtsp://Administrator:Password@localhost:8554/drone_0":{"amazon_kinesis_video_streams":{"aws_access_key_id":"","aws_secret_access_key":"","aws_default_region":"","kinesis_stream":""}}}`
		// Note Change the deafult config string to json encoding.
		// Write a config file in the current directory if it doesn't exist
		writeToFile(applicationConfigFile, []byte(defaultConfigString))
	}
	// Check if the config file has not been modified
	if sha256OfFile(applicationConfigFile) == "d41d8cd98f00b204e9800998ecf8427e" {
		// The file has not been modified
		exitTheApplication("The config file has not been modified. Please modify it and try again.")
	}
	// Can check for rtsp server but
	// what u can easily do is run rtsp server on one server and run this on another server.
	// The list of app required for this to work.
	// kensis // google cloud vision ai.
	requiredApplications:= []string{"vaictl"}
	// Check if the required application are present in the system
	for _, app := range requiredApplications {
		if commandExists(app) == false {
			exitTheApplication(app, "is not installed in your system. Please install it and try again.")
		}
	// Check if the config has the correct format and all the info is correct.
	if !jsonValid(applicationConfigFile) {
		exitTheApplication("The config file is not a valid json file")
	}
}