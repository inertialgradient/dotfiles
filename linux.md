## Steps to add to the bootstrap

1. Pop! Shop: Install dropbox
2. Command-line installations

```
echo ------- apt ---------
sudo ubuntu-drivers autoinstall
sudo apt install nvidia-cuda-toolkit ruby vim zsh xclip gnome-tweaks gnome-sushi

echo ------- emacs ---------
brew unlink emacs
brew install poppler
sudo apt install libvterm-dev
sudo add-apt-repository ppa:ubuntuhandbook1/emacs
sudo apt update
sudo apt install emacs emacs-gtk emacs-common

echo ------- toshy ---------
bash -c "$(curl -L https://raw.githubusercontent.com/RedBearAK/toshy/main/scripts/bootstrap.sh ||
 wget -O - https://raw.githubusercontent.com/RedBearAK/toshy/main/scripts/bootstrap.sh)"

echo ------- vim ---------
sudo apt-get install libx11-dev libxt-dev libxpm-dev libgtk2.0-dev
brew install --build-from-source ~/.dotfiles/scripts/vim.rb

echo ------- kitty ---------
~/.dotfiles/lib/install-kitty

echo ------- flatpak ---------
flatpak install brave extensionmanager
```

## Merge config and data home dirs

NB: May need to remove toshy first then `g co --` the config file after
overwriting.

```
mv ~/.config/* $XDG_CONFIG_HOME
ln -s $XDG_CONFIG_HOME ~/.config

mv ~/.local/share/* $XDG_DATA_HOME
ln -s $XDG_DATA_HOME ~/.local/share
```

## Set keyboard delay and repeat interval

Accessibility > Keyboard

## Keybinding config

```
cat keybindings.conf | dconf load /
```

### Disable standalone super key

Locate and edit the COSMIC extension's main JavaScript file, often named
`extension.js`.

The path is likely

```
/usr/share/gnome-shell/extensions/pop-cosmic@system76.com/extension.js 
```

Search for this line and comment it out:

``` javascript
overview_toggle(overlay_key_action);
```

## Apps

- Toshy: https://github.com/RedBearAK/toshy
- Emacs: Built with sqlite3 support for magit
- Vim: Built with clipboard support (`--with-x` build flag)

## TeX

May take several hours to complete:
https://www.tug.org/texlive/quickinstall.html

```
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

zcat < install-tl-unx.tar.gz | tar xf -

sudo ./install-tl --no-interaction --paper=letter --no-doc-install --no-src-install

sudo ln -s /usr/local/texlive/[YYYY] /usr/local/texlive/current
```

## Deprecated Installs

### input-remapper-2

https://github.com/sezanzeb/input-remapper
```
wget https://github.com/sezanzeb/input-remapper/releases/download/2.1.1/input-remapper-2.1.1.deb
sudo apt install -f ./input-remapper-2.1.1.deb
```

### Ulauncher

https://ulauncher.io

```
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install ulauncher
```
