require 'fastlane/action'
require_relative '../helper/shorebird_helper'
require 'gym'
require 'plist'
require 'tempfile'

module Fastlane
  module Actions
    class ShorebirdReleaseAction < Action
      def self.run(params)
        platform = params[:platform]
        params[:args] ||= ""

        if platform == "ios"
          if export_options_plist_in_args?(params)
            # If the user is already providing an export options plist, warn
            UI.deprecated("--export-options-plist should not be passed in the args parameter. Please use the export_options parameter instead.")
          else
            provisioning_profile_mapping = Fastlane::Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING]
            export_options_plist_path = Helper::ExportOptionsPlist.generate_export_options_plist(params[:export_options], provisioning_profile_mapping)
            optional_space = (params[:args].end_with?(" ") || params[:args].empty?) ? "" : " "
            params[:args] = params[:args] + "#{optional_space}--export-options-plist #{export_options_plist_path}"
          end
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

      def self.export_options_plist_in_args?(params)
        params[:args].include?("--export-options-plist")
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
