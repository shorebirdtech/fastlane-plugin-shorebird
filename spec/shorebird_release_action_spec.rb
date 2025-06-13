require 'spec_helper'
require_relative '../lib/fastlane/plugin/shorebird/helper/export_options_plist'

describe Fastlane::Actions::ShorebirdReleaseAction do
  subject { Fastlane::Actions::ShorebirdReleaseAction }
  path_to_export_options_plist = '/path/to/export_options.plist'

  before do
    allow(Fastlane::Actions).to receive(:sh).with(anything)
    allow(Fastlane::Helper::ExportOptionsPlist).to receive(:generate_export_options_plist).with(any_args).and_return(path_to_export_options_plist)
  end

  describe '#run' do
    describe 'targeting android' do
      it 'invokes shorebird release with the specified platform' do
        expect(Fastlane::Actions).to receive(:sh).with("shorebird release android")
        subject.run(platform: "android")
      end

      it 'invokes shorebird release with the specified platform and args' do
        expect(Fastlane::Actions).to receive(:sh).with("shorebird release android -- --build-name=1.0.0")
        subject.run(platform: "android", args: "-- --build-name=1.0.0")
      end
    end

    describe 'targeting ios' do
      it 'warns if --export-options-plist is in the args parameter' do
        expect(Fastlane::UI).to receive(:deprecated).with("--export-options-plist should not be passed in the args parameter. Please use the export_options parameter instead.")
        subject.run(platform: "ios", args: "--export-options-plist /my/export_options.plist")
      end

      it 'invokes shorebird release with the specified platform' do
        expect(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))
        subject.run(platform: "ios")
      end

      it 'adds IPA_OUTPUT_PATH to lane context if platform is ios' do
        old_ipa_file = instance_double('File', path: 'old.ipa')
        new_ipa_file = instance_double('File', path: 'new.ipa')

        allow(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))

        allow(Dir).to receive(:glob).with(any_args).and_return([old_ipa_file.path, new_ipa_file.path])
        allow(File).to receive(:stat).with(old_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 100))
        allow(File).to receive(:stat).with(new_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 10))

        subject.run(platform: "ios")

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]).to eq(new_ipa_file.path)
      end
    end
  end
end
