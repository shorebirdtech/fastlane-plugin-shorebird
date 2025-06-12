require 'spec_helper'
require_relative '../lib/fastlane/plugin/shorebird/helper/export_options_plist'

describe Fastlane::Helper::ExportOptionsPlist do
  subject { Fastlane::Helper::ExportOptionsPlist }

  describe '#generate_export_options_plist' do
    it 'generates an export options plist' do
      export_options = { method: 'app-store' }
      export_options_plist = subject.generate_export_options_plist(export_options)
      expect(export_options_plist).to be_a(String)
    end
  end

  describe 'export_options as a hash' do
    it 'raises an error if the file does not exist' do
      expect do
        subject.generate_export_options_plist("/path/to/not/a/file")
      end.to raise_error("export_options path /path/to/not/a/file does not exist")
    end

    # TODO
  end

  describe 'export_options as a file' do
    it 'raises an error if the file does not exist' do
      expect do
        subject.generate_export_options_plist("/path/to/not/a/file")
      end.to raise_error("export_options path /path/to/not/a/file does not exist")
    end

    # TODO
  end
end
