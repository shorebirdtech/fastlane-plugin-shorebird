# Releasing

Pushing a `v<VERSION>` tag publishes the gem to
[RubyGems](https://rubygems.org/gems/fastlane-plugin-shorebird) through the
[Release workflow](.github/workflows/release.yml), using RubyGems
[trusted publishing](https://guides.rubygems.org/trusted-publishing/). No
RubyGems password or OTP is needed.

1. Open a PR that bumps `VERSION` in `lib/fastlane/plugin/shorebird/version.rb`
   and adds a section for it at the top of `CHANGELOG.md`. Land it.
2. Tag the landed version-bump commit (its SHA from the merged PR, not
   whatever local `main` points at) and push the tag:
   ```
   git fetch origin
   git tag v<VERSION> <bump commit SHA>
   git push origin v<VERSION>
   ```
3. Watch the run at
   https://github.com/shorebirdtech/fastlane-plugin-shorebird/actions/workflows/release.yml.
   It fails if the tag doesn't match `VERSION`, isn't on `main`, or the tests
   fail. If it fails:
   - Before "Run release rake task" (a check, the tests, or trusted
     publishing credentials): nothing was published. Fix the cause and use
     "Re-run failed jobs". If the tag is on the wrong commit, delete it
     (`git push --delete origin v<VERSION>` and `git tag -d v<VERSION>`) and
     tag again.
   - At "Run release rake task" or later: check
     https://rubygems.org/gems/fastlane-plugin-shorebird/versions. If the
     version is listed, it is published; don't re-run, since RubyGems refuses
     to push the same version twice. Otherwise, re-run.
4. Create the GitHub release from the tag:
   ```
   gh release create v<VERSION> --generate-notes
   ```

The gem's RubyGems owner is the `shorebird` account (contact@shorebird.dev).
Its trusted publisher is this repository's `release.yml` workflow in the
`release` environment, which only `v*` tags can deploy to. The account's MFA
recovery codes are in 1Password.
