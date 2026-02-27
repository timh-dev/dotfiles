# ============================================================================
# Docker Aliases
# ============================================================================

# Core commands
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dv='docker volume ls'
alias dn='docker network ls'

# Container management
alias dstart='docker start'
alias dstop='docker stop'
alias drestart='docker restart'
alias drm='docker rm'
alias drmf='docker rm -f'

# Image management
alias drmi='docker rmi'
alias dpull='docker pull'
alias dpush='docker push'
alias dbuild='docker build'
alias dtag='docker tag'

# Logs
alias dlogs='docker logs'
alias dlogsf='docker logs -f'

# Exec
alias dexec='docker exec -it'
alias dsh='docker exec -it'

# Docker Compose
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'
alias dcl='docker-compose logs'
alias dclf='docker-compose logs -f'
alias dcps='docker-compose ps'
alias dcb='docker-compose build'
alias dce='docker-compose exec'

# Docker Compose v2
alias dkc='docker compose'
alias dkcu='docker compose up'
alias dkcud='docker compose up -d'
alias dkcd='docker compose down'
alias dkcr='docker compose restart'
alias dkcl='docker compose logs'
alias dkclf='docker compose logs -f'

# ============================================================================
# Docker Functions
# ============================================================================

# Stop all containers
function dstopall() {
    docker stop $(docker ps -q)
}

# Remove all containers
function drmall() {
    docker rm $(docker ps -aq)
}

# Remove all images
function drmiall() {
    docker rmi $(docker images -q)
}

# Clean everything
function dclean() {
    echo "🧹 Cleaning Docker..."
    docker system prune -af --volumes
    echo "✅ Done"
}

# Exec into container with bash/sh
function dsh() {
    local container="$1"
    if [[ -z "$container" ]]; then
        echo "Available containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        return 1
    fi
    docker exec -it "$container" /bin/bash 2>/dev/null || docker exec -it "$container" /bin/sh
}

# Follow logs for container
function dlog() {
    local container="$1"
    if [[ -z "$container" ]]; then
        echo "Available containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}"
        return 1
    fi
    docker logs -f "$container"
}

# Show container stats
function dstats() {
    docker stats --no-stream
}

# Inspect container
function dinspect() {
    docker inspect "$1" | less
}

# Show container IP
function dip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

# Remove dangling images
function dcleanimg() {
    docker rmi $(docker images -f "dangling=true" -q)
}

# Remove stopped containers
function dcleanc() {
    docker rm $(docker ps -aq -f status=exited)
}

# Docker build with tag
function dbld() {
    local tag="${1:-.}"
    docker build -t "$tag" .
}

# Run container with cleanup
function drun() {
    docker run --rm -it "$@"
}
