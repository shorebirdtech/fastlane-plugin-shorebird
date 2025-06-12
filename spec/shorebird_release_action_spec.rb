require 'spec_helper'

describe Fastlane::Actions::ShorebirdReleaseAction do
  action = Fastlane::Actions::ShorebirdReleaseAction

  before do
    allow(Fastlane::Actions).to receive(:sh).with(anything)
  end

  describe '#run' do
    describe 'targeting android' do
      it 'invokes shorebird release with the specified platform' do
        expect(Fastlane::Actions).to receive(:sh).with("shorebird release android")
        action.run(platform: "android")
      end

      it 'invokes shorebird release with the specified platform and args' do
        expect(Fastlane::Actions).to receive(:sh).with("shorebird release android -- --build-name=1.0.0")
        action.run(platform: "android", args: "-- --build-name=1.0.0")
      end
    end

    describe 'targeting ios' do
      it 'invokes shorebird release with the specified platform' do
        expect(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))
        action.run(platform: "ios")
      end

      it 'adds IPA_OUTPUT_PATH to lane context if platform is ios' do
        old_ipa_file = instance_double('File', path: 'old.ipa')
        new_ipa_file = instance_double('File', path: 'new.ipa')

        allow(Fastlane::Actions).to receive(:sh).with(match_regex(/shorebird release ios --export-options-plist .*/))

        allow(Dir).to receive(:glob).with(any_args).and_return([old_ipa_file.path, new_ipa_file.path])
        allow(File).to receive(:stat).with(old_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 100))
        allow(File).to receive(:stat).with(new_ipa_file.path).and_return(instance_double('File::Stat', ctime: Time.now - 10))

        action.run(platform: "ios")

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH]).to eq(new_ipa_file.path)
      end

      describe 'export_options as a hash' do
        it 'raises an error if the file does not exist' do
          expect do
            action.run(platform: "ios", export_options: "/path/to/not/a/file")
          end.to raise_error("export_options path /path/to/not/a/file does not exist")
        end

        # TODO
      end

      describe 'export_options as a file' do
        it 'raises an error if the file does not exist' do
          expect do
            action.run(platform: "ios", export_options: "/path/to/not/a/file")
          end.to raise_error("export_options path /path/to/not/a/file does not exist")
        end

        # TODO
      end
    end
  end
end
