#!/usr/bin/env bash

# --- Visual Feedback Setup ---
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { printf "${CYAN}${BOLD}💡 INFO:${NC} %s\n" "$1"; }
log_success() { printf "${GREEN}${BOLD}✅ SUCCESS:${NC} %s\n" "$1"; }
log_error() { printf "${RED}${BOLD}❌ ERROR:${NC} %s\n" "$1"; exit 1; }
log_warn() { printf "${YELLOW}${BOLD}⚠️ WARN:${NC} %s\n" "$1"; }

# --- Security & Validation ---
# Ensure Docker is installed
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install it to continue."
fi

# Ensure Docker daemon is running
if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running. Please start Docker Desktop or the docker engine."
fi

# User credentials for volumes if needed
export CURRENT_UID=$(id -u)
export CURRENT_GID=$(id -g)

# --- Load Environment Variables ---
if [ -f .env ]; then
  log_info "Loading environment variables from .env"
  while IFS='=' read -r key value || [ -n "$key" ]; do
    [[ "$key" =~ ^#.* ]] || [[ -z "$key" ]] && continue
    # Remove leading/trailing whitespace and quotes from value
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'\'']//' -e 's/["'\'']$//')
    export "$key=$value"
  done < .env
fi

# --- Configuration ---
DRY_RUN=false
START_TIME=$SECONDS

# Help message
show_help() {
  printf "${BOLD}Usage:${NC} %s {up|restart|stop|down|build|logs|reset|clean} [options]\n" "$0"
  printf "\n"
  printf "${BOLD}Options:${NC}\n"
  printf "  -p, --profile <name>  Supports multiple profiles. Example: --profile develop --profile stage\n"
  printf "  -d, --dir <path>      Directories to remove for the 'clean' command.\n"
  printf "  -s, --service <name>  Specific docker-compose service name.\n"
  printf "  --dry-run             Show commands without executing them.\n"
  printf "  -h, --help            Show this help information.\n"
  printf "\n"
  printf "${BOLD}Environment Variables (optional):${NC}\n"
  printf "  APP_PROFILES          List of profiles (e.g., '--profile dev --profile stage').\n"
  printf "  APP_CLEAN_DIRS        Directories to clean separated by spaces.\n"
}

# --- Argument Processing ---
while [[ $# -gt 0 ]]; do
  case $1 in
    up|restart|stop|down|build|logs|reset|clean)
      COMMAND="$1"
      shift
      ;;
    -p|--profile)
      PROFILES+=("--profile $2")
      shift 2
      ;;
    -d|--dir)
      CLEAN_DIRS+=("$2")
      shift 2
      ;;
    -s|--service)
      SERVICE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      if [[ -n "$COMMAND" && "$1" != -* ]]; then
         PROFILES+=("--profile $1")
         shift
      else
         printf "${RED}Error: Unknown argument '%s'${NC}\n" "$1"
         show_help
         exit 1
      fi
      ;;
  esac
done

if [[ -z "$COMMAND" ]]; then
  show_help
  exit 1
fi

# --- Parameter Resolution ---
P_ARGS=""

if [[ ${#PROFILES[@]} -gt 0 ]]; then
    # Convert array to space-separated string
    P_ARGS="${PROFILES[*]}"
elif [[ -n "$APP_PROFILES" ]]; then
    P_ARGS="$APP_PROFILES"
elif [[ "$COMMAND" == "down" || "$COMMAND" == "clean" || "$COMMAND" == "reset" ]]; then
    P_ARGS="--profile develop --profile stage --profile main"
else
    P_ARGS="--profile develop"
fi

if [[ ${#CLEAN_DIRS[@]} -eq 0 ]]; then
    if [[ -n "$APP_CLEAN_DIRS" ]]; then
        CLEAN_DIRS=($APP_CLEAN_DIRS)
    else
        CLEAN_DIRS=("app/dist" "app/node_modules")
    fi
fi

# --- Execution Engine ---
# IMPORTANT: We use $P_ARGS WITHOUT quotes to allow the shell to split arguments.
execute_compose() {
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] docker compose $P_ARGS $*"
    else
        log_info "Executing: docker compose $P_ARGS $*"
        docker compose $P_ARGS "$@"
    fi
}

case "$COMMAND" in
  "up")
    execute_compose up $SERVICE -d && log_success "Application started."
    ;;
  "restart")
    execute_compose restart $SERVICE && log_success "Application restarted."
    ;;
  "stop")
    execute_compose stop $SERVICE && log_success "Application stopped."
    ;;
  "down")
    execute_compose down $SERVICE --volumes && log_success "Stack removed."
    ;;
  "build")
    execute_compose build $SERVICE --no-cache && log_success "Build completed."
    ;;
  "logs")
    log_info "Showing logs for: $P_ARGS $SERVICE"
    docker compose $P_ARGS logs $SERVICE -f
    ;;
  "reset")
    log_warn "Resetting environment..."
    execute_compose down $SERVICE --volumes
    execute_compose up $SERVICE -d && log_success "Environment reset."
    docker compose $P_ARGS logs $SERVICE -f
    ;;
  "clean")
    log_warn "Cleaning stack and local files..."
    execute_compose down $SERVICE --volumes
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would remove: ${CLEAN_DIRS[*]}"
    else
        log_info "Removing directories: ${CLEAN_DIRS[*]}"
        rm -rf "${CLEAN_DIRS[@]}"
    fi
    log_success "Cleanup finished."
    ;;
esac

# Execution Summary
ELAPSED_TIME=$(($SECONDS - $START_TIME))
printf "${CYAN}${BOLD}⏱️  Summary:${NC} Task completed in ${YELLOW}${ELAPSED_TIME}s${NC}\n"


