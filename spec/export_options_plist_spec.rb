require 'spec_helper'
require_relative '../lib/fastlane/plugin/shorebird/helper/export_options_plist'

describe Fastlane::Helper::ExportOptionsPlist do
  subject { Fastlane::Helper::ExportOptionsPlist }

  before do
    temp_dir = Dir.mktmpdir('shorebird')
    allow(Dir).to receive(:mktmpdir).with(any_args).and_return(temp_dir)
  end

  describe '#generate_export_options_plist' do
    describe 'from hash' do
      it 'generates an export options plist' do
        export_options = { method: 'app-store' }
        export_options_plist = subject.generate_export_options_plist(export_options)
        expect(export_options_plist).to be_a(String)
        expect(File.exist?(export_options_plist)).to be_truthy
        actual_plist = Plist.parse_xml(export_options_plist)
        expect(actual_plist['method']).to eq('app-store')
        expect(actual_plist['manageAppVersionAndBuildNumber']).to eq(false)
        expect(actual_plist['provisioningProfiles']).to be_nil
      end

      it 'adds provisioning profiles to the export options plist if provided' do
        export_options = { method: 'app-store' }
        provisioning_profile_mapping = { 'com.example.app' => 'com.example.app.provisioning' }
        export_options_plist = subject.generate_export_options_plist(export_options, provisioning_profile_mapping)
        actual_plist = Plist.parse_xml(export_options_plist)
        expect(actual_plist['provisioningProfiles']).to eq(provisioning_profile_mapping)
      end
    end

    describe 'from file' do
      it 'raises an error if the file does not exist' do
        expect do
          subject.generate_export_options_plist("/path/to/not/a/file")
        end.to raise_error("export_options path /path/to/not/a/file does not exist")
      end

      it 'updates the export options plist to ensure that the build number is not managed by Xcode' do
        temp_export_options_plist = File.join(Dir.mktmpdir, 'ExportOptions.plist')
        File.write(temp_export_options_plist, { method: 'app-store' }.to_plist)
        export_options_plist = subject.generate_export_options_plist(temp_export_options_plist)
        actual_plist = Plist.parse_xml(export_options_plist)
        expect(actual_plist['method']).to eq('app-store')
        expect(actual_plist['manageAppVersionAndBuildNumber']).to eq(false)
      end
    end

    it 'defaults to app-store if no method is provided' do
      export_options = {}
      export_options_plist = subject.generate_export_options_plist(export_options)
      actual_plist = Plist.parse_xml(export_options_plist)
      expect(actual_plist['method']).to eq('app-store')
    end

    it 'uses export method from export options plist if provided' do
      export_options = { method: 'ad-hoc' }
      export_options_plist = subject.generate_export_options_plist(export_options)
      actual_plist = Plist.parse_xml(export_options_plist)
      expect(actual_plist['method']).to eq('ad-hoc')
    end
  end
end
