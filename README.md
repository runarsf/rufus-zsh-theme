# rufus-zsh-theme
A heavyweight, buggy, slow, unoptimized, new, intense, fun, cool ( and imo pretty good-looking ) oh-my-zsh theme.

I'm looking into adding an optional feature to integrate the theme with my bash todo list (runarsf/drop),
this should come in a very near future.

## Q ( Literally no users, so I don't have FA questions ):
#### Why is it so heavyweight?
* It determines the length of the line to write as the header relative to the pwd length and a few other parameters, then prints each character out one-by-one. While this action is in progress, your terminal won't be able to execute any other commands. On big terminal windows *(tested on fullscreen 2560x1440 with font size 7)*, this can take from 0.25-1 seconds (also depending on your system). This drastically improves on smaller terminal windows. I'm actively looking into how to solve this problem.
#### What does the line do?
* The line after the current pwd is simply for aesthetics, it will resize itself when you change the terminal width or enter a new working directory. This works best with monospaced fonts due to the way it determines the line length.
#### What is `${time}$(git_prompt_info)$(git_prompt_status)$(git_prompt_ahead)$reset_color`?
* This happens when you terminate the write process. If you press ctrl+c while the theme is trying to write the header, the script won't get all it needs to give you the right output, and instead spits out an unformatted version. To fix this, simply wait for about 1.5-2++ seconds and press ctrl+c.
#### HELP! {x} does {y} and {y} is bad!
* Woops, need help with anything (oh-my-)zsh related? Submit an issue at [runarsf/rufus-zsh-theme](https://github.com/runarsf/rufus-zsh-theme/issues/new). Need help with (literally and virtually) **anything** else? Contact me on [Twitter](https://twitter.com/Runar_SF) or [Discord](https://discord.me/shindeiru) *(Rufus#0001)*.

## Installation:
1. Install [zsh](https://en.wikipedia.org/wiki/Z_shell)
2. Install [oh-my-zsh](https://ohmyz.sh/)
3. Copy or make a symlink from 'rufus.zsh-theme' into '$HOME/.oh-my-zsh/custom/themes/'
	* `ln -s ./rufus.zsh-theme ~/.oh-my-zsh/custom/themes/`
	* `cp ./rufus.zsh-theme ~/.oh-my-zsh/custom/themes/`
4. Add or edit the value of 'ZSH_THEME' in $HOME/.zshrc to be 'ZSH_THEME="rufus"'
5. Run 'source ~/.zshrc' in a terminal
6. Enjoy!


## Screenshots
![terminalDark](image.png "theme: runarsf/dotfiles")
![terminalLight](imageLight.png "theme: solarized light")
