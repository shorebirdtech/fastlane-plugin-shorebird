require 'fastlane/action'
require_relative '../helper/shorebird_helper'

module Fastlane
  module Actions
    class ShorebirdReleaseAction < Action
      def self.run(params)
        platform = params[:platform]
        Fastlane::Actions.sh("shorebird release #{platform} #{params[:args]}".strip)

        if platform == "ios"
          # Get the most recently-created IPA file
          ipa_file = Dir.glob('../build/ios/ipa/*.ipa')
                        .sort_by! { |f| File.stat(f).ctime }
                        .reverse!
                        .first
          puts("Setting IPA_OUTPUT_PATH to #{ipa_file}")
          lane_context[SharedValues::IPA_OUTPUT_PATH] = ipa_file
        end
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
          )
        ]
      end

      def self.is_supported?(platform)
        Helper::ShorebirdHelper.supported_platforms.include?(platform)
      end
    end
  end
end
