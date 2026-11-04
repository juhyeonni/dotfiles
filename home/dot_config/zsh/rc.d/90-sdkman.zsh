# SDKMAN (JVM toolchain) — only when installed.
#
# Numbered 90 because SDKMAN prepends itself to PATH and must therefore come after the other
# runtimes (its own docs say it "must be at the end").
#
# Cost: ~10ms at startup (__sdkman_export_candidate_home +
# __sdkman_prepend_candidate_to_path). If you do no JVM work,
# `rm -rf ~/.sdkman` alone turns this file into a no-op.

if [[ -s $HOME/.sdkman/bin/sdkman-init.sh ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
