require 'fastlane/action'
require_relative '../helper/shorebird_helper'
require 'gym'
require 'plist'
require 'tempfile'

module Fastlane
  module Actions
    class ExportOptionsPlistGenerator
      def self.generate(export_options)
        tmp_path = Dir.mktmpdir('shorebird')
        plist_path = File.join(tmp_path, "ExportOptions.plist")
        File.write(plist_path, export_options.to_plist)
        plist_path
      end
    end

    class ShorebirdReleaseAction < Action
      def self.run(params)
        platform = params[:platform]
        params[:args] ||= ""

        if platform == "ios"
          export_options_plist_path = generate_export_options_plist(params[:export_options])
          optional_space = (params[:args].end_with?(" ") || params[:args].empty?) ? "" : " "
          params[:args] = params[:args] + "#{optional_space}--export-options-plist #{export_options_plist_path}"
        end

        command = "shorebird release #{platform} #{params[:args]}".strip
        Fastlane::Actions.sh(command)

        if platform == "ios"
          lane_context[SharedValues::IPA_OUTPUT_PATH] = most_recent_ipa_file
        end
      end

      def self.most_recent_ipa_file
        Dir.glob('../build/ios/ipa/*.ipa')
           .sort_by! { |f| File.stat(f).ctime }
           .reverse!
           .first
      end

      def self.generate_export_options_plist(export_options)
        export_options_hash = {}
        if export_options.kind_of?(Hash)
          export_options_hash = export_options
          export_options_hash[:method] = "app-store"
          provisioning_profile_mapping = Fastlane::Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING]
          if provisioning_profile_mapping
            # If match has provided provisioning profiles, put them in the export options plist
            export_options_hash[:provisioningProfiles] = provisioning_profile_mapping
            export_options_hash[:signingStyle] = 'manual'
          end
        elsif export_options.kind_of?(String)
          export_options_path = File.expand_path(export_options)
          unless File.exist?(export_options_path)
            raise "export_options path #{export_options_path} does not exist"
          end

          export_options_hash = Plist.parse_xml(export_options_path)
        end

        # If manageAppVersionAndBuildNumber is not false, Shorebird won't
        # work. If set to true (or not provided), Xcode will change the build
        # number *after* the release is created, causing the app to be
        # unpatchable.
        export_options_hash[:manageAppVersionAndBuildNumber] = false
        export_options_hash.compact!

        ExportOptionsPlistGenerator.generate(export_options_hash)
      end

      def self.description
        "Create a Shorebird release"
      end

      def self.authors
        Helper::ShorebirdHelper.authors
      end

      def self.details
        "Create a Shorebird release for the provided platform with the given arguments."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :platform,
            description: "Which platform to release to (ios,android)",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :args,
            description: "The argument string to pass to shorebird release",
            optional: true,
            type: String,
            default_value: ""
          ),
          FastlaneCore::ConfigItem.new(
            key: :export_options,
            description: "Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options",
            optional: true,
            type: Hash,
            skip_type_validation: true,
            default_value: {}
          )
        ]
      end

      def self.is_supported?(platform)
        Helper::ShorebirdHelper.supported_platforms.include?(platform)
      end
    end
  end
end
