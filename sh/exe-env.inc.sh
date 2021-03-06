#!/usr/bin/env sh

function path_prepend() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=$1:${PATH}
}

function path_append() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=${PATH}:$1
}

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    path_prepend /home/linuxbrew/.linuxbrew/sbin
    path_prepend /home/linuxbrew/.linuxbrew/bin
elif [ -x ~/.linuxbrew/bin/brew ]; then
    path_prepend ${HOME}/.linuxbrew/sbin
    path_prepend ${HOME}/.linuxbrew/bin
fi
path_prepend /usr/local/sbin
path_prepend /usr/local/bin
path_prepend ${HOME}/.local/sbin
path_prepend ${HOME}/.local/bin

if which brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
    path_prepend ${HOMEBREW_PREFIX}/sbin
    path_prepend ${HOMEBREW_PREFIX}/bin

    for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip make; do
        path_prepend ${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin
    done
    path_prepend ${HOMEBREW_PREFIX}/opt/curl/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/gettext/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/unzip/bin
    path_prepend ${HOMEBREW_PREFIX}/opt/zip/bin

    unset HOMEBREW_PREFIX
fi
