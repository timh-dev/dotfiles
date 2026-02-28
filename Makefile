.PHONY: help link unlink relink brew npm vscode python vim zsh packages clean qmenu

BOLD := \033[1m
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
RESET := \033[0m

help:
	@echo "${BOLD}Dotfiles${RESET}"
	@echo ""
	@echo "  ${GREEN}make link${RESET}       - Symlink dotfiles into ~"
	@echo "  ${GREEN}make unlink${RESET}     - Remove symlinks"
	@echo "  ${GREEN}make relink${RESET}     - Re-symlink dotfiles"
	@echo "  ${YELLOW}make clean${RESET}      - Clean broken symlinks"
	@echo ""
	@echo "  ${BLUE}make brew${RESET}       - Install Homebrew packages"
	@echo "  ${BLUE}make npm${RESET}        - Install npm packages"
	@echo "  ${BLUE}make vscode${RESET}     - Install VSCode extensions"
	@echo "  ${BLUE}make python${RESET}     - Install Python tools"
	@echo "  ${BLUE}make vim${RESET}        - Install Vim plugins"
	@echo "  ${BLUE}make zsh${RESET}        - Install Zsh plugins"
	@echo "  ${BLUE}make qmenu${RESET}      - Build qmenu TUI"
	@echo "  ${BLUE}make packages${RESET}   - Install all packages"

link:
	@./install.sh

unlink:
	@echo "Removing symlinks..."
	@for pkg in */; do \
		pkg=$${pkg%/}; \
		[[ "$$pkg" =~ ^(aliases|functions|packages|scripts|bin)$$ ]] && continue; \
		echo "  Unstowing $$pkg"; \
		stow -D "$$pkg" 2>/dev/null || true; \
	done
	@echo "Done."

relink:
	@echo "Re-linking dotfiles..."
	@for pkg in */; do \
		pkg=$${pkg%/}; \
		[[ "$$pkg" =~ ^(aliases|functions|packages|scripts|bin)$$ ]] && continue; \
		echo "  Restowing $$pkg"; \
		stow -R "$$pkg" 2>/dev/null || true; \
	done
	@echo "Done."

brew:
	@if ! command -v brew &> /dev/null; then \
		echo "Homebrew not installed."; \
		exit 1; \
	fi
	@brew bundle --file=packages/Brewfile

npm:
	@if ! command -v npm &> /dev/null; then \
		echo "npm not installed."; \
		exit 1; \
	fi
	@grep -v '^#' packages/npm-global.txt | grep -v '^$$' | xargs npm install -g

vscode:
	@if ! command -v code &> /dev/null; then \
		echo "VSCode not installed."; \
		exit 1; \
	fi
	@grep -v '^#' packages/vscode-extensions.txt | grep -v '^$$' | xargs -L 1 code --install-extension

python:
	@if ! command -v uv &> /dev/null; then \
		echo "uv not installed."; \
		exit 1; \
	fi
	@grep -v '^#' packages/python-tools.txt | grep -v '^$$' | xargs -L 1 uv tool install

vim:
	@if [[ ! -f "$$HOME/.vim/autoload/plug.vim" ]]; then \
		echo "Installing Vim-Plug..."; \
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi
	@vim +PlugInstall +qall

zsh:
	@ZSH_CUSTOM="$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}"; \
	if [[ ! -d "$$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then \
		git clone https://github.com/zsh-users/zsh-autosuggestions "$$ZSH_CUSTOM/plugins/zsh-autosuggestions"; \
	fi; \
	if [[ ! -d "$$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then \
		git clone https://github.com/zsh-users/zsh-syntax-highlighting "$$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; \
	fi; \
	if [[ ! -d "$$ZSH_CUSTOM/plugins/zsh-bat" ]]; then \
		git clone https://github.com/fdellwing/zsh-bat "$$ZSH_CUSTOM/plugins/zsh-bat"; \
	fi; \
	if [[ ! -d "$$ZSH_CUSTOM/plugins/you-should-use" ]]; then \
		git clone https://github.com/MichaelAquilina/zsh-you-should-use "$$ZSH_CUSTOM/plugins/you-should-use"; \
	fi; \
	if [[ ! -d "$$ZSH_CUSTOM/plugins/zsh-z" ]]; then \
		git clone https://github.com/agkozak/zsh-z "$$ZSH_CUSTOM/plugins/zsh-z"; \
	fi

packages: brew npm vscode python vim zsh qmenu
	@echo "All packages installed."

qmenu:
	@if ! command -v go &> /dev/null; then \
		echo "Go not installed."; \
		exit 1; \
	fi
	@cd scripts/qmenu && go mod tidy && go build -o ../bin/qmenu
	@chmod +x scripts/bin/qmenu

clean:
	@echo "Cleaning broken symlinks..."
	@find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null | \
		grep "dotfiles" | \
		xargs -I {} rm -v {}
	@echo "Done."
