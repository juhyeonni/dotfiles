# SDKMAN (JVM 툴체인) — 설치돼 있을 때만.
#
# 90번인 이유: SDKMAN 은 PATH 를 자기 앞쪽에 밀어 넣으므로 다른 런타임보다
# 뒤에 와야 한다(공식 안내도 "must be at the end").
#
# 비용: 시작 시 약 10ms (__sdkman_export_candidate_home +
# __sdkman_prepend_candidate_to_path). JVM 작업을 안 한다면
# `rm -rf ~/.sdkman` 만으로 이 파일은 자동으로 no-op 이 된다.

if [[ -s $HOME/.sdkman/bin/sdkman-init.sh ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
