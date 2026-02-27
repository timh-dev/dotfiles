.PHONY: help install uninstall restow bootstrap brew npm vscode python vim zsh packages clean qmenu

help:
	@echo "${BOLD}Dotfiles Management${RESET}"
	@echo ""
	@echo "  ${GREEN}make bootstrap${RESET}  - First-time setup (installs everything)"
	@echo "  ${GREEN}make install${RESET}    - Stow all packages"
	@echo "  ${GREEN}make uninstall${RESET}  - Unstow all packages"
	@echo "  ${GREEN}make restow${RESET}     - Restow all packages"
	@echo ""
	@echo "  ${BLUE}make brew${RESET}       - Install Homebrew packages"
	@echo "  ${BLUE}make npm${RESET}        - Install npm packages"
	@echo "  ${BLUE}make vscode${RESET}     - Install VSCode extensions"
	@echo "  ${BLUE}make python${RESET}     - Install Python tools"
	@echo "  ${BLUE}make vim${RESET}        - Install Vim plugins"
	@echo "  ${BLUE}make zsh${RESET}        - Install Zsh plugins"
	@echo "  ${BLUE}make qmenu${RESET}      - Build qmenu TUI"
	@echo "  ${BLUE}make packages${RESET}   - Install all packages"
	@echo ""
	@echo "  ${YELLOW}make clean${RESET}      - Clean up broken symlinks"

BOLD := \033[1m
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
RESET := \033[0m

bootstrap: install brew zsh packages qmenu
	@echo "✅ Bootstrap complete! Restart your terminal."

install:
	@./install.sh

uninstall:
	@echo "🗑️  Unstowing packages..."
	@for pkg in */; do \
		pkg=$${pkg%/}; \
		[[ "$$pkg" =~ ^(aliases|functions|packages|scripts|configs|bin)$$ ]] && continue; \
		echo "📌 Unstowing $$pkg..."; \
		stow -D "$$pkg" 2>/dev/null || true; \
	done
	@echo "✅ Done"

restow:
	@echo "🔄 Restowing packages..."
	@for pkg in */; do \
		pkg=$${pkg%/}; \
		[[ "$$pkg" =~ ^(aliases|functions|packages|scripts|configs|bin)$$ ]] && continue; \
		echo "📌 Restowing $$pkg..."; \
		stow -R "$$pkg" 2>/dev/null || true; \
	done
	@echo "✅ Done"

brew:
	@echo "🍺 Installing Homebrew packages..."
	@if ! command -v brew &> /dev/null; then \
		echo "❌ Homebrew not installed. Run 'make bootstrap' first."; \
		exit 1; \
	fi
	@brew bundle --file=packages/Brewfile
	@echo "✅ Homebrew packages installed"

npm:
	@echo "📦 Installing npm packages..."
	@if ! command -v npm &> /dev/null; then \
		echo "❌ npm not installed. Run 'make brew' first."; \
		exit 1; \
	fi
	@grep -v '^#' packages/npm-global.txt | grep -v '^$$' | xargs npm install -g
	@echo "✅ npm packages installed"

vscode:
	@echo "💻 Installing VSCode extensions..."
	@if ! command -v code &> /dev/null; then \
		echo "❌ VSCode not installed. Run 'make brew' first."; \
		exit 1; \
	fi
	@grep -v '^#' packages/vscode-extensions.txt | grep -v '^$$' | xargs -L 1 code --install-extension
	@echo "✅ VSCode extensions installed"

python:
	@echo "🐍 Installing Python tools..."
	@if ! command -v uv &> /dev/null; then \
		echo "❌ uv not installed. Run 'make brew' first."; \
		exit 1; \
	fi
	@grep -v '^#' packages/python-tools.txt | grep -v '^$$' | xargs -L 1 uv tool install
	@echo "✅ Python tools installed"

vim:
	@echo "📝 Installing Vim plugins..."
	@if [[ ! -f "$$HOME/.vim/autoload/plug.vim" ]]; then \
		echo "📥 Installing Vim-Plug..."; \
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
			https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
	fi
	@vim +PlugInstall +qall
	@echo "✅ Vim plugins installed"

zsh:
	@echo "🐚 Installing Zsh plugins..."
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
	@echo "✅ Zsh plugins installed"

packages: brew npm vscode python
	@echo "✅ All packages installed"

qmenu:
	@echo "🎨 Building qmenu TUI..."
	@if ! command -v go &> /dev/null; then \
		echo "❌ Go not installed. Run 'make brew' first."; \
		exit 1; \
	fi
	@cd scripts/qmenu && go mod tidy && go build -o ../bin/qmenu
	@chmod +x scripts/bin/qmenu
	@echo "✅ qmenu built"

clean:
	@echo "🧹 Cleaning broken symlinks..."
	@find ~ -maxdepth 3 -type l ! -exec test -e {} \; -print 2>/dev/null | \
		grep "dotfiles" | \
		xargs -I {} rm -v {}
	@echo "✅ Cleanup complete"
