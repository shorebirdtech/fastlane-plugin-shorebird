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
      def setup_build_dir(root_dir)
        FileUtils.touch(File.join(root_dir, 'pubspec.yaml'))
        FileUtils.mkdir_p(File.join(root_dir, 'build/ios/ipa'))
        FileUtils.touch(File.join(root_dir, 'build/ios/ipa/old.ipa'))
        FileUtils.touch(File.join(root_dir, 'build/ios/ipa/new.ipa'))

        # Make old.ipa be less recently created than new.ipa.
        File.utime(Time.now - 1000, Time.now - 1000, File.join(root_dir, 'build/ios/ipa/old.ipa'))
        File.utime(Time.now, Time.now, File.join(root_dir, 'build/ios/ipa/new.ipa'))
      end

      before do
        @tmp_dir = Dir.mktmpdir
        setup_build_dir(@tmp_dir)
        Dir.chdir(@tmp_dir)
      end

      it 'warns if --export-options-plist is in the args parameter' do
        expect(Fastlane::UI).to receive(:deprecated).with("--export-options-plist should not be passed in the args parameter. Please use the export_options parameter instead.")
        subject.run(platform: "ios", args: "--export-options-plist /my/export_options.plist")
      end

      it 'invokes shorebird release with the specified platform' do
        expect(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))
        subject.run(platform: "ios")
      end

      it 'adds IPA_OUTPUT_PATH to lane context if platform is ios' do
        allow(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))
        subject.run(platform: "ios")
        # We use end_with because the tmp_dir we get from Dir.mktmpdir is actually
        # different than the one we get put in through Dir.chdir.
        # tmp_dir is in /var/folders/...
        # Trying to move to that directory puts us in /private/var/folders/...
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]).to end_with(File.join(@tmp_dir, 'build/ios/ipa/new.ipa'))
      end

      it 'finds ipa path if run in a subdirectory' do
        Dir.chdir(File.join(@tmp_dir, 'build/ios'))
        allow(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))
        subject.run(platform: "ios")
        # We use end_with because the tmp_dir we get from Dir.mktmpdir is actually
        # different than the one we get put in through Dir.chdir.
        # tmp_dir is in /var/folders/...
        # Trying to move to that directory puts us in /private/var/folders/...
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]).to end_with(File.join(@tmp_dir, 'build/ios/ipa/new.ipa'))
      end

      it 'raises an error if no pubspec.yaml is found' do
        FileUtils.rm(File.join(@tmp_dir, 'pubspec.yaml'))
        expect { subject.run(platform: "ios") }.to raise_error("Could not find pubspec.yaml in the directory tree")
      end
    end
  end
end
