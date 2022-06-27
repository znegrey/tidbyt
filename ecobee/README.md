# Ecobee for Tidbyt
[Tidbyt](https://tidbyt.com) app to show [Ecobee](https://www.ecobee.com) temperature.

AppID: ecobee

This assumes you have already setup your Tidbyt Development Environment via [Pixlet](https://github.com/tidbyt/pixlet).

## Ecobee API
This app uses the [Ecobee API](https://www.ecobee.com/home/developer/api/introduction/index.shtml).

You will need an [Ecobee Developer Account](https://www.ecobee.com/en-us/developers/) for this to work. (Note, at the time of this writing, the [Ecobee Developer Portal](https://www.ecobee.com/home/developer/loginDeveloper.jsp) doesn't seem to support 2fa, so you'll have to disable that to log in successfully). Once you have a Developer Account, follow the [instructions](https://www.ecobee.com/home/developer/api/examples/ex1.shtml) to get an API Key.

You also need to get an ecobeePin: https://www.ecobee.com/home/developer/api/examples/ex1.shtml.

### Variables
See above to get your Ecobee API Key
```
ECOBEE_API_KEY=''
TEMP_REFRESH_TOKEN=''
```

# Run locally
```
pixlet serve --watch ./ecobee.star
```
Visit http://localhost:8080.


### todo
To test the Ecobee OAuth stuff locally (it requires an https redirect), see https://ngrok.com.
Start it with:
```
ngrok http 8080
```

# Run on Tidbyt
run once:
```
pixlet render ./ecobee.star
pixlet push --api-token $TIDBYT_API_TOKEN $TIDBYT_DEVICE_ID ./ecobee.webp
```
push as install:
```
pixlet push --api-token $TIDBYT_API_TOKEN --installation-id "ecobee" $TIDBYT_DEVICE_ID ./ecobee.webp
```