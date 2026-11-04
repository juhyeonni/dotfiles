# Google Cloud SDK — only when installed.
#
# completion.zsh.inc is heavy (measured: ~40ms for gcloud + SDKMAN combined).
# If you rarely use gcloud, deleting just the completion line reclaims most of it.

if [[ -d $HOME/google-cloud-sdk ]]; then
  [[ -f $HOME/google-cloud-sdk/path.zsh.inc ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
  [[ -f $HOME/google-cloud-sdk/completion.zsh.inc ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
