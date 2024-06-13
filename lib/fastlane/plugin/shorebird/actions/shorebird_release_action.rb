require 'fastlane/action'
require_relative '../helper/shorebird_helper'

module Fastlane
  module Actions
    class ShorebirdReleaseAction < Action
      def self.run(params)
        Fastlane::Actions.sh("shorebird release #{params[:platform]} #{params[:args]}".strip)
      end

      def self.description
        "Create a Shorebird release"
      end

      def self.authors
        Helper::ShorebirdHelper.authors
      end

      def self.details
        "Create a Shorebird release for the given platform."
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
