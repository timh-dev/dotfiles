# ============================================================================
# Python & UV Aliases
# ============================================================================

# Python shortcuts
alias py='python3'
alias py2='python2'
alias pip='pip3'
alias ipy='ipython'

# UV (Modern Python package manager)
alias uv='uv'
alias uvs='uv sync'
alias uvi='uv add'
alias uvr='uv remove'
alias uvl='uv lock'
alias uvrun='uv run'
alias uvx='uvx'

# Virtual environments (UV style)
alias venv='uv venv'
alias deact='deactivate'

# Requirements
alias pipi='pip install -r requirements.txt'
alias pipf='pip freeze > requirements.txt'
alias pipup='pip install --upgrade pip'

# Django
alias dj='python manage.py'
alias djrun='python manage.py runserver'
alias djmig='python manage.py migrate'
alias djmake='python manage.py makemigrations'
alias djshell='python manage.py shell'
alias djtest='python manage.py test'

# Flask
alias flask='flask'
alias flaskrun='flask run'
alias flaskshell='flask shell'

# Jupyter
alias jn='jupyter notebook'
alias jl='jupyter lab'
alias jc='jupyter console'

# Testing
alias pytest='pytest'
alias pyt='pytest -v'
alias pytc='pytest --cov'
alias pytw='pytest --watch'

# Linting/Formatting
alias black='black'
alias isort='isort'
alias flake='flake8'
alias mypy='mypy'
alias ruff='ruff'

# Python server
alias serve='python -m http.server'
alias serve8='python -m http.server 8000'

# JSON formatting
alias json='python -m json.tool'

# ============================================================================
# Python Functions
# ============================================================================

# Create UV project
function uvnew() {
    local name="${1:-.}"
    uv init "$name"
    cd "$name" 2>/dev/null || return
    echo "✅ Created UV project: $name"
}

# Create and activate venv with UV
function mkvenv() {
    local name="${1:-.venv}"
    uv venv "$name"
    source "$name/bin/activate"
    echo "✅ Created and activated: $name"
}

# Smart activate (finds venv automatically)
function act() {
    if [[ -f ".venv/bin/activate" ]]; then
        source .venv/bin/activate
        echo "✅ Activated: .venv"
    elif [[ -f "venv/bin/activate" ]]; then
        source venv/bin/activate
        echo "✅ Activated: venv"
    elif [[ -f "env/bin/activate" ]]; then
        source env/bin/activate
        echo "✅ Activated: env"
    else
        echo "❌ No virtual environment found"
        return 1
    fi
}

# Install from requirements with UV
function uvreq() {
    if [[ -f "requirements.txt" ]]; then
        uv pip install -r requirements.txt
    elif [[ -f "pyproject.toml" ]]; then
        uv sync
    else
        echo "❌ No requirements.txt or pyproject.toml found"
        return 1
    fi
}

# Quick Python script runner
function pyrun() {
    python3 -c "$@"
}

# Profile Python script
function pyprof() {
    python3 -m cProfile -s cumulative "$@"
}

# Python debugger
function pydb() {
    python3 -m pdb "$@"
}

# Find Python package location
function pyfind() {
    python3 -c "import $1; print($1.__file__)"
}

# List installed packages
function pylist() {
    if command -v uv >/dev/null 2>&1; then
        uv pip list
    else
        pip list
    fi
}

# Upgrade all packages
function pyupall() {
    if command -v uv >/dev/null 2>&1; then
        uv pip list --outdated | tail -n +3 | awk '{print $1}' | xargs -n1 uv pip install -U
    else
        pip list --outdated | tail -n +3 | awk '{print $1}' | xargs -n1 pip install -U
    fi
}

# Create requirements from imports
function pyreqgen() {
    pipreqs . --force
}

# Python version info
function pyinfo() {
    echo "Python: $(python3 --version)"
    echo "Pip: $(pip3 --version)"
    if command -v uv >/dev/null 2>&1; then
        echo "UV: $(uv --version)"
    fi
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Venv: $VIRTUAL_ENV"
    fi
}
