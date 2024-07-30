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

    it 'adds IPA_OUTPUT_PATH to lane context if platform is ios' do
      old_ipa_file = instance_double('File', path: 'old.ipa')
      new_ipa_file = instance_double('File', path: 'new_ipa')

      allow(Fastlane::Actions).to receive(:sh).with("shorebird release ios")
      allow(Dir).to receive(:glob).with('../build/ios/ipa/*.ipa').and_return([old_ipa_file.path, new_ipa_file.path])
      allow(File).to receive(:stat).with(old_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 100))
      allow(File).to receive(:stat).with(new_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 10))

      Fastlane::Actions::ShorebirdReleaseAction.run(platform: "ios")

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]).to eq(new_ipa_file.path)
    end
  end
end
