#!/bin/bash

PROJ_PATH="$(pwd)/django-notes-app"
DOCKER_USER="vaibhav161202"
DOCKER_PASSWORD="${DOCKER_PASSWORD}"

docker_login() {
    echo "Attempting to log in to Docker Hub as $DOCKER_USER..."
    echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USER" --password-stdin
    if [ $? -eq 0 ]; then
        echo "✅ Login Successful!"
    else
        echo "❌ Docker login failed. Check your credentials."
        exit 1
    fi
}

code_clone() {
    echo "Cloning Django App ...."
    if [ -d "django-notes-app" ]; then
        echo "Repo already exists, skipping clone..."
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git
    fi
}

install_requirements() {
    echo "Installing dependencies ..."
    sudo apt-get update -y
    sudo apt-get install docker.io nginx docker-compose -y
}

required_restart() {
    sudo chown $USER /var/run/docker.sock
    sudo systemctl enable docker
    sudo systemctl restart docker
}

deploy() {
    echo "Starting Deployment with Docker Compose..."
    echo "Navigating to: $PROJ_PATH"
    cd "$PROJ_PATH" || { echo "❌ Directory not found: $PROJ_PATH"; exit 1; }

    echo "Stopping system nginx to free port 80..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx

    sudo docker-compose down
    sudo docker-compose up -d --build

    echo "Checking service status..."
    sudo docker-compose ps
}

echo "************* DEPLOYMENT STARTED ***************"

docker_login

code_clone

if ! install_requirements; then
    echo "❌ Installation failed"
    exit 1
fi

if ! required_restart; then
    echo "❌ System fault identified"
    exit 1
fi

deploy

echo "************* DEPLOYMENT COMPLETED ***************"
