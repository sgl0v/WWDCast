
# WWDCast

[![Build Status](https://www.bitrise.io/app/08e3f4df4a3bb96a/status.svg?token=w30mFKoUI1f7Xzd7M8xS0Q)](https://www.bitrise.io/app/08e3f4df4a3bb96a)

The unofficial WWDC app, that makes it possible to cast WWDC videos and sessions on your ChromeCast.

If you would like to test the latest changes, you can join the **TestFlight** beta by sending your e-mail address to [@sgl0v](mailto:maxscheglov@gmail.com).

## Features

You can watch WWDC videos on your ChromeCast. Just select a video, click the play and choose your device from the list. The app becomes the remote control to play, pause, seek, rewind, stop, and otherwise control the media.

![screen1](./.github/screen1.png)
![screen2](./.github/screen2.png)

## Building the app

**Building requires Xcode 9.3 or later.**

To get started, you will need to install [Carthage](https://github.com/Carthage/Carthage) (`brew install carthage`). Then run these instructions:

```sh
git clone https://github.com/sgl0v/WWDCast.git
cd WWDCast
carthage update --platform iOS
```

Eventually you should open the `WWDCast.xcworkspace` and build/run WWDCast.

## License

WWDCast is licensed under MIT. However, **please do not ship this app** under your own account, paid or free.

## Contributing

Your ideas for improving this app are greatly appreciated. The best way to contribute is by submitting a pull request. I'll do my best to respond to you as soon as possible. You can also submit a new Github issue if you find bugs or have questions.
