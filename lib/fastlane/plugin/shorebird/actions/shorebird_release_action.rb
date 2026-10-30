require 'fastlane/action'
require_relative '../helper/shorebird_helper'
require 'gym'
require 'plist'
require 'tempfile'

module Fastlane
  module Actions
    module SharedValues
      SHOREBIRD_MACOS_APP_OUTPUT_PATH = :SHOREBIRD_MACOS_APP_OUTPUT_PATH
    end

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

        write_output_path(params)
      end

      def self.write_output_path(params)
        case params[:platform]
        when "ios"
          lane_context[SharedValues::IPA_OUTPUT_PATH] = most_recent_ipa_file
        when "macos"
          lane_context[SharedValues::SHOREBIRD_MACOS_APP_OUTPUT_PATH] = most_recent_macos_app(flavor_from_args(params[:args]))
        end
      end

      def self.most_recent_ipa_file
        most_recent_file(ipa_path_pattern)
      end

      def self.most_recent_macos_app(flavor)
        most_recent_file(macos_app_path_pattern(flavor))
      end

      # The value of --flavor (as --flavor=<x> or --flavor <x>) among the
      # shorebird arguments, ignoring anything after a bare -- separator.
      def self.flavor_from_args(args)
        shorebird_args = args.to_s.split(/(?:^|\s)--(?:\s|$)/, 2).first.to_s
        shorebird_args[/(?:^|\s)--flavor(?:=|\s+)(\S+)/, 1]
      end

      def self.most_recent_file(pattern)
        Dir.glob(pattern)
           .sort_by! { |f| File.stat(f).mtime }
           .reverse!
           .first
      end

      # Traverses up the directory tree until it finds a pubspec.yaml file.
      # If no parent directory contains a pubspec.yaml file, we assume we are
      # not in a Flutter project and raise an error.
      def self.project_root
        current_dir = Dir.pwd
        current_dir = File.expand_path('..', current_dir) until File.exist?(File.join(current_dir, 'pubspec.yaml')) || (current_dir == '/')
        # If we've reached the root directory, we've failed to find a pubspec.yaml file.
        if current_dir == '/'
          raise "Could not find pubspec.yaml in the directory tree"
        end

        current_dir
      end

      # .ipa path relative to the project root
      def self.ipa_path_pattern
        File.join(project_root, 'build/ios/ipa', '*.ipa')
      end

      # .app path relative to the project root. Flavored builds are written to
      # Release-<flavor> instead of Release.
      def self.macos_app_path_pattern(flavor)
        build_dir = flavor ? "Release-#{flavor}" : 'Release'
        File.join(project_root, 'build/macos/Build/Products', build_dir, '*.app')
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
            description: "Which platform to release to (ios,android,macos)",
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

      def self.output
        [
          ['IPA_OUTPUT_PATH', 'The path to the .ipa created by an ios release'],
          ['SHOREBIRD_MACOS_APP_OUTPUT_PATH', 'The path to the .app created by a macos release']
        ]
      end

      def self.is_supported?(platform)
        Helper::ShorebirdHelper.supported_platforms.include?(platform)
      end
    end
  end
end
