## Supported tags and respective `Dockerfile` links

* [`latest` _(Dockerfile)_](https://github.com/r0zbot/nginx-rtmp-docker/blob/master/Dockerfile)

# nginx-rtmp

[**Docker**](https://www.docker.com/) image with [**Nginx**](http://nginx.org/en/) using the [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module) module for live multimedia (video) streaming, with transcoding support through ffmpeg.

## Description

This is a fork of [**tiangolo's Docker Image**](https://github.com/tiangolo/nginx-rtmp-docker) using Alpine for a smaller image and with added FFmpeg support.

This [**Docker**](https://www.docker.com/) image can be used to create an RTMP server for multimedia / video streaming and/or transcoding using [**Nginx**](http://nginx.org/en/) and [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module), built from the current latest sources (Nginx 1.15.0 and nginx-rtmp-module 1.2.1).

The main purpose (and test case) to build it was to allow streaming from [**OBS Studio**](https://obsproject.com/) to both Twitch and YouTube at the same time, but with different resolutions/bitrate, since YouTube supports transcoding for everyone, and Twitch only does for partner streamers. 

**GitHub repo**: <https://github.com/r0zbot/nginx-rtmp-docker>

**Docker Hub image**: <https://hub.docker.com/r/r0zbot/nginx-rtmp/>

## Details

The default configuration file supports a few modes of operation:

- RTMP Server Only: Streaming to the url `rtmp://<ip_of_host>/live`, you get a simple RTMP stream in -> RTMP stream out, which can be used, for example, to show another OBS instance as source. It can then be viewed (either in VLC or OBS RTMP Source) through the URL `rtmp://<ip_of_host>/live/<key>`, where key is the same key you used when streaming.

- RTMP Transcoding Push: Streaming to the url `rtmp://<ip_of_host>/transcode`, the server will call an instance of FFmpeg with the settings specified in the .env file and push its stream to the URL specified in _TRANSCODE_URL_ with the key specified in _TRANSCODE_KEY_. This could be used, for example, to offload transcoding to a second computer, where you could use a slower compression setting.

- RTMP Transcoding Dual Push: Stream to the url `rtmp://<ip_of_host>/transcode-dual`. Same as above, but it will also push the source stream to the _SOURCE_URL_ using the _SOURCE_KEY_. This could be used for streaming the source to YouTube and a more heavily compressed version to Twitch.

- RTMP Dual Push: Stream to the url `rtmp://<ip_of_host>/dual`. In this mode, it will dual-stream to both _SOURCE_URL_ and _TRANSCODE_URL_ using their respective keys, but without doing any transcoding.


## How to use

First, clone this repository. You will then get access to the default template, `.env` and `docker-compose.yml` files. 
If you wish to use the default use cases, all you need to do is edit the `.env` file with your settings/keys and then run `docker-compose up` in the folder you downloaded it to.

## How to test with OBS Studio and VLC

* Run a container with the command above
* Open [OBS Studio](https://obsproject.com/)
* Click the "Settings" button
* Go to the "Stream" section
* In "Stream Type" select "Custom Streaming Server"
* In the "URL" enter the `rtmp://<ip_of_host>/live` replacing `<ip_of_host>` with the IP of the host in which the container is running. For example: `rtmp://192.168.0.30/live`
* In the "Stream key" use a "key" that will be used later in the client URL to display that specific stream. For example: `test`
* Click the "OK" button
* In the section "Sources" click de "Add" button (`+`) and select a source (for example "Screen Capture") and configure it as you need
* Click the "Start Streaming" button


* Open a [VLC](http://www.videolan.org/vlc/index.html) player (it also works in Raspberry Pi using `omxplayer`)
* Click in the "Media" menu
* Click in "Open Network Stream"
* Enter the URL from above as `rtmp://<ip_of_host>/live/<key>` replacing `<ip_of_host>` with the IP of the host in which the container is running and `<key>` with the key you created in OBS Studio. For example: `rtmp://192.168.0.30/live/test`
* Click "Play"
* Now VLC should start playing whatever you are transmitting from OBS Studio

For testing the transcoding option, you can just replace the _live_ part of the url with _transcoded_. So, for example, if you're streaming to `rtmp://192.168.0.30/transcode` with the key "test", you can see the transcoded version on `rtmp://192.168.0.30/transcoded/test`

## Debugging

If something is not working you can check the logs of the container with:

```bash
docker logs nginx-rtmp
```

## Extending

If you need to modify the configurations you can create a file `nginx.conf.template` and replace the one in this image using a `Dockerfile` that is based on the image, for example:

```Dockerfile
FROM r0zbot/nginx-rtmp

COPY nginx.conf.template /etc/nginx/nginx.conf.template
```

You can start from it and modify it as you need. Here's the [documentation related to `nginx-rtmp-module`](https://github.com/arut/nginx-rtmp-module/wiki/Directives).

## Technical details

* This image is built from the alpine image, which means its small in size. 

* It is built from the official sources of **Nginx** and **nginx-rtmp-module** without adding anything else. (Surprisingly, most of the available images that include **nginx-rtmp-module** are made from different sources, old versions or add several other components).

* The FFmpeg version used is the most recent x64 one available when building, so this will not work on 32 bit or ARM systems at the moment. 

## License

This project is licensed under the terms of the MIT License.
