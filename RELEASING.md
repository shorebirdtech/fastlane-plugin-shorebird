# Releasing

Pushing a `v<VERSION>` tag publishes the gem to
[RubyGems](https://rubygems.org/gems/fastlane-plugin-shorebird) through the
[Release workflow](.github/workflows/release.yml), using RubyGems
[trusted publishing](https://guides.rubygems.org/trusted-publishing/). No
RubyGems password or OTP is needed.

1. Open a PR that bumps `VERSION` in `lib/fastlane/plugin/shorebird/version.rb`
   and adds a section for it at the top of `CHANGELOG.md`. Land it.
2. Tag the landed commit and push the tag:
   ```
   git checkout main && git pull
   git tag v<VERSION>
   git push origin v<VERSION>
   ```
3. Watch the run at
   https://github.com/shorebirdtech/fastlane-plugin-shorebird/actions/workflows/release.yml.
   It fails if the tag doesn't match `VERSION`, isn't on `main`, or the tests
   fail. To retry a failed run, use "Re-run failed jobs" on the run; don't
   delete and re-push the tag.
4. Create the GitHub release from the tag:
   ```
   gh release create v<VERSION> --generate-notes
   ```

The gem's RubyGems owner is the `shorebird` account (contact@shorebird.dev).
Its trusted publisher is this repository's `release.yml` workflow in the
`release` environment, which only `v*` tags can deploy to. The account's MFA
recovery codes are in 1Password.
