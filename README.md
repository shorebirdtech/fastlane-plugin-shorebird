# Shorebird `fastlane` plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-shorebird)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-shorebird`, add it to your project by running:

```bash
fastlane add_plugin shorebird
```

## About shorebird

This plugin makes it easy to create Shorebird releases and patches.

## Example

This plugin is designed to work with Flutter apps that use Shorebird. 

In your Flutter app's `ios` and/or `android` directories, initialize Fastlane
and add this plugin using `bundle exec fastlane add_plugin shorebird`.

Then, update your `Fastfile` to include the following:

```ruby
lane :release_ios do
  shorebird_release(platform: "ios")
end
```

This will create a new release on Shorebird for the iOS platform.

See https://docs.shorebird.dev/guides/fastlane for more information.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
