# Releasing

The gem is published to [RubyGems](https://rubygems.org/gems/fastlane-plugin-shorebird)
under the `shorebird` account (contact@shorebird.dev), which requires MFA.

1. Open a PR that bumps `VERSION` in `lib/fastlane/plugin/shorebird/version.rb`
   and adds a section for it at the top of `CHANGELOG.md`. Land it.
2. Check out the updated `main` with a clean working tree:
   ```
   git checkout main && git pull
   bundle install
   ```
3. Sign in to RubyGems as `shorebird` (once per machine; prompts for the OTP):
   ```
   gem signin
   ```
4. Build, tag, push the tag and publish the gem (prompts for the OTP):
   ```
   bundle exec rake release
   ```
   This creates and pushes the `v<VERSION>` tag and runs `gem push`.
5. Create the GitHub release from the tag:
   ```
   gh release create v<VERSION> --generate-notes
   ```
6. Check that the new version is listed at
   https://rubygems.org/gems/fastlane-plugin-shorebird.
