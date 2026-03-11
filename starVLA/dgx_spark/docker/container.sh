#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONTAINER_NAME="starVLA"
NODE_RANK="node1"   # node1 or node2

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  help                    Show this help message"
    echo "  create                  Create and start container (image → new container)"
    echo "  start                   Start existing container (already created)"
    echo "  enter                   Enter the running container"
    echo "  stop                    Stop the container"
    echo "  remove                  Stop and remove the container"
    echo ""
    echo "Examples:"
    echo "  $0 create               Create and start container"
    echo "  $0 start                Start existing container"
    echo "  $0 enter                Enter the running container"
    echo "  $0 stop                 Stop container"
    echo "  $0 remove               Remove container"
}

is_container_running() {
    docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

is_container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

setup_x11() {
    if [ -n "$DISPLAY" ]; then
        echo "Setting up X11 forwarding..."
        # xhost 제거 (SSH 환경에서 불필요)
        rm -f /tmp/.docker.xauth
        touch /tmp/.docker.xauth
        xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge - 2>/dev/null || true
        chmod 777 /tmp/.docker.xauth
    else
        echo "Warning: DISPLAY is not set. X11 forwarding will not be available."
    fi
}

create_container() {
    setup_x11
    echo "Creating and starting ${CONTAINER_NAME} container..."
    docker compose -f "${SCRIPT_DIR}/docker-compose.${NODE_RANK}.yml" up -d
}

start_container() {
    if is_container_exists; then
        setup_x11
        echo "Starting existing ${CONTAINER_NAME} container..."
        docker compose -f "${SCRIPT_DIR}/docker-compose.${NODE_RANK}.yml" start
    else
        echo "Error: Container does not exist. Run '$0 create' first."
        exit 1
    fi
}

enter_container() {
    setup_x11
    if ! is_container_running; then
        echo "Error: Container is not running"
        exit 1
    fi
    docker exec -it "$CONTAINER_NAME" bash
}

stop_container() {
    if ! is_container_running; then
        echo "Error: Container is not running"
        exit 1
    fi
    echo "Stopping ${CONTAINER_NAME} container..."
    docker compose -f "${SCRIPT_DIR}/docker-compose.${NODE_RANK}.yml" stop
}

remove_container() {
    echo "Warning: This will stop and remove the container. All unsaved data will be lost."
    read -p "Are you sure? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose -f "${SCRIPT_DIR}/docker-compose.${NODE_RANK}.yml" down
        echo "Container removed."
    else
        echo "Operation cancelled."
        exit 0
    fi
}

case "$1" in
    "help")     show_help ;;
    "create")   create_container ;;
    "start")    start_container ;;
    "enter")    enter_container ;;
    "stop")     stop_container ;;
    "remove")   remove_container ;;
    *)
        [ -z "$1" ] && show_help || echo "Error: Unknown command '$1'" && show_help
        exit 1
        ;;
esac