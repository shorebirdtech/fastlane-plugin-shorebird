require 'spec_helper'

describe Fastlane::Actions::ShorebirdPatchAction do
  before do
    allow(Fastlane::Actions).to receive(:sh).with(anything)
  end

  describe '#run' do
    it 'invokes shorebird patch with the specified platform and args' do
      expect(Fastlane::Actions).to receive(:sh).with("shorebird patch ios")
      Fastlane::Actions::ShorebirdPatchAction.run(platform: "ios")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird patch android")
      Fastlane::Actions::ShorebirdPatchAction.run(platform: "android")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird patch ios --release-version=1.2.3+4")
      Fastlane::Actions::ShorebirdPatchAction.run(platform: "ios", args: "--release-version=1.2.3+4")

      expect(Fastlane::Actions).to receive(:sh).with("shorebird patch android -- --build-name=1.0.0")
      Fastlane::Actions::ShorebirdPatchAction.run(platform: "android", args: "-- --build-name=1.0.0")
    end
  end
end
