# tidbyt
Play with the [tidbyt.dev](https://tidbyt.dev) stuff for the [Tidbyt](https://tidbyt.com).

# Setup
See the [Pixlet](https://github.com/tidbyt/pixlet) Getting started documentation:
```
brew install tidbyt/tidbyt/pixlet
```

## Environment variables
Per the Pixlet docs: "To get the ID and API key for a device, open the settings for the device in the Tidbyt app on your phone, and tap Get API key" and set these env vars:
```
export TIDBYT_DEVICE_ID=''
export TIDBYT_API_TOKEN=''
```

# Run locally
```
pixlet serve --watch ./hello.star
```
Visit http://localhost:8080.

# Run on Tidbyt
run once:
```
pixlet render ./hello.star
pixlet push --api-token $TIDBYT_API_TOKEN $TIDBYT_DEVICE_ID ./hello.webp
```
push as install:
```
pixlet push --api-token $TIDBYT_API_TOKEN --installation-id "zHello" $TIDBYT_DEVICE_ID ./hello.webp
```



