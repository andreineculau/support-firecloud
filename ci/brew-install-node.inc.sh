#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing NodeJS packages..."
else
    echo_do "brew: Installing NodeJS packages..."

    # force node bottle on CI, compiling node fails or takes forever
    NODE_FORMULA=node
    [[ "${CI:-}" != "true" ]] || {
        cd $(brew --repo homebrew/core)
        git fetch --depth 1000
        BREW_TEST_BOT=BrewTestBot
        BREW_REPO_SLUG=Homebrew/homebrew-core
        [[ "$(uname -s)" != "Linux" ]] || {
            BREW_TEST_BOT=LinuxbrewTestBot
            BREW_REPO_SLUG=Homebrew/linuxbrew-core
        }
        NODE_BOTTLE_COMMIT=$(
            git log -1 \
                --first-parent \
                --pretty=format:"%H" \
                --author ${BREW_TEST_BOT} \
                --grep update \
                --grep bottle \
                Formula/node.rb
        )
        [[ "${NODE_BOTTLE_COMMIT}" = "" ]] || \
            NODE_FORMULA="https://raw.githubusercontent.com/${BREW_REPO_SLUG}/${NODE_BOTTLE_COMMIT}/Formula/node.rb"
    }

    # if we specify a node version via .travis.yml (ignore 'node' because that means latest),
    # do not override it by installing the latest node version via homebrew
    [[ "${TRAVIS_NODE_VERSION:-}" = "node" ]] || [[ -z "${TRAVIS_NODE_VERSION:-}" ]] || {
        echo_info "TRAVIS_NODE_VERSION=${TRAVIS_NODE_VERSION} wants a specific version of node installed."
        echo_skip "brew: Installing node..."
        NODE_FORMULA=
    }

    BREW_FORMULAE="$(cat <<-EOF
${NODE_FORMULA}
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE

    # allow npm upgrade to fail on WSL; fails with EACCESS
    IS_WSL=$([[ -e /proc/version ]] && cat /proc/version | grep -q -e "Microsoft" && echo true || echo false)
    npm install --global --force npm@6 || ${IS_WSL}
    npm install --global json@9

    echo_done

    echo_do "brew: Testing NodeJS packages..."
    exe_and_grep_q "node --version | head -1" "^v"
    exe_and_grep_q "npm --version | head -1" "^6\."
    exe_and_grep_q "json --version | head -1" "^json 9\."
    echo_done
fi
