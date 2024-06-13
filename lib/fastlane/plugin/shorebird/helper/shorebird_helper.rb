require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class ShorebirdHelper
      # class methods that you define here become available in your action
      # as `Helper::ShorebirdHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the shorebird plugin helper!")
      end

      def self.authors
        ["bryanoltman"]
      end

      def self.supported_platforms
        [:ios, :android]
      end
    end
  end
end
