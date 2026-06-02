#!/bin/bash
set -euo pipefail

main() {
    # Get the directory of this script (repository root)
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Launch Vim with:
    # 1. -u NONE (skips .vimrc / .gvimrc and sets 'compatible' by default)
    # 2. --cmd "set compatible" (ensures compatible mode is strictly active)
    # 3. -S to source our plugin entry point so :JavimRun is defined
    exec vim -u NONE --cmd "set compatible" --cmd "set rtp+=${script_dir}" -S "${script_dir}/plugin/javim.vim" "$@"
}

main "$@"
