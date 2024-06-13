require 'fastlane/action'
require_relative '../helper/shorebird_helper'

module Fastlane
  module Actions
    class ShorebirdPatchAction < Action
      def self.run(params)
        sh("shorebird patch #{params[:platform]} #{params[:args]}")
      end

      def self.description
        "Create a Shorebird patch"
      end

      def self.authors
        ["Bryan Oltman"]
      end

      def self.details
        # TODO
        "Create a Shorebird patch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :platform,
            description: "Which platform to patch (ios,android)",
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
        [:ios, :android].include?(platform)
      end
    end
  end
end
