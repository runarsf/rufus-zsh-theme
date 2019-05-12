#!/bin/bash

for file in *.zsh-theme; do
	echo "ln -s $(pwd)/$file $HOME/.oh-my-zsh/custom/themes/$file"
	ln -s $(pwd)/$file $HOME/.oh-my-zsh/custom/themes/$file
done
