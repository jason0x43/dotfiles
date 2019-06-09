#!/bin/bash

# Fix terminal definition so C-H works properly in neovim.
# See https://github.com/neovim/neovim/issues/2048#issuecomment-78045837
infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
tic /tmp/$TERM.ti
rm /tmp/$TERM.ti
