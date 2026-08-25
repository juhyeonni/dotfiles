# Google Cloud SDK — 설치돼 있을 때만.
#
# completion.zsh.inc 는 무겁다(측정: gcloud + SDKMAN 합쳐 약 40ms).
# gcloud 를 자주 안 쓴다면 completion 줄만 지우는 것으로 대부분을 회수할 수 있다.

if [[ -d $HOME/google-cloud-sdk ]]; then
  [[ -f $HOME/google-cloud-sdk/path.zsh.inc ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
  [[ -f $HOME/google-cloud-sdk/completion.zsh.inc ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
