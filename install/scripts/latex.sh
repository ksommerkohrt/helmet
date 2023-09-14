#!/bin/bash
set -e
set -x

sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive  apt-get install --no-install-recommends -y \
	texlive-bibtex-extra \
	texlive-latex-extra \
	texstudio
