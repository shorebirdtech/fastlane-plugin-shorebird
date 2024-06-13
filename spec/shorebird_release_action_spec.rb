require 'spec_helper'

describe Fastlane::Actions::ShorebirdReleaseAction do
  before do
    allow(Fastlane::Actions).to receive(:sh).with(anything)
  end

  describe '#run' do
    it 'invokes shorebird release with the specified platform and args' do
      expect(Fastlane::Actions).to receive(:sh).with("shorebird release ios")
      Fastlane::Actions::ShorebirdReleaseAction.run(platform: "ios")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird release android")
      Fastlane::Actions::ShorebirdReleaseAction.run(platform: "android")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird release ios --dry-run")
      Fastlane::Actions::ShorebirdReleaseAction.run(platform: "ios", args: "--dry-run")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird release android -- --build-name=1.0.0")
      Fastlane::Actions::ShorebirdReleaseAction.run(platform: "android", args: "-- --build-name=1.0.0")
    end
  end
end
