module Fastlane
  module Helper
    class ExportOptionsPlist
      # Generates an export options plist for use with Shorebird.
      # In addition to handling data produced by match, it also updates the
      # export options to ensure that the build number is not managed by Xcode
      # and that the release method is set to app-store.
      #
      # @param export_options [Hash, String] The export options to use. If a hash, it will be used directly. If a string, it will be parsed as a plist file.
      # @param provisioning_profile_mapping [Hash] The provisioning profile mapping from match. If provided, the provisioning profiles will be added to the export options plist.
      # @return [String] The path to the generated export options plist.
      def self.generate_export_options_plist(export_options, provisioning_profile_mapping = nil)
        export_options_hash = {}
        if export_options.kind_of?(Hash)
          export_options_hash = export_options
          export_options_hash[:method] = "app-store"
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

        tmp_path = Dir.mktmpdir('shorebird')
        plist_path = File.join(tmp_path, "ExportOptions.plist")
        File.write(plist_path, export_options_hash.to_plist)
        plist_path
      end
    end
  end
end
