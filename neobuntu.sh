set -x
DEPS="gcc make rg unzip"
[ $(which $DEPS | wc -l) == $(echo $DEPS | wc -w) ] || sudo apt install gcc make ripgrep unzip
if [ ! -f ~/nvim/bin/nvim ]; then
	curl -Lo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	tar zxvf /tmp/nvim.tar.gz && mv nvim-linux64 nvim
fi
if [ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" ]; then
	git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
fi
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
if [ ! -f lazygit ]; then
	curl -Lo lazygit.tar.gz \
		"https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	#sudo install lazygit /usr/local/bin
fi
./nvim/bin/nvim
