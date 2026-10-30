# ccgo

## Versioning rule

Any change to `bin/` or `lib/` that users would receive MUST ship with a version bump. Before
finishing such a change, remind the user and do the full release:

1. Bump `CCGO_VERSION` in `lib/ccgo.sh` (patch for fixes/preset tweaks, minor for features).
2. Commit and push, then `git tag vX.Y.Z && git push origin vX.Y.Z`.
3. `gh release create vX.Y.Z --title vX.Y.Z --notes "..."`.
4. Update `Formula/ccgo.rb`: the `url` tag and `sha256`
   (`curl -fsSL https://github.com/serhii-ilin/ccgo/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`).
5. Commit and push the formula, then verify: `brew update && brew upgrade ccgo && ccgo --version`.

README-only changes do not need a release. Never commit API keys.
