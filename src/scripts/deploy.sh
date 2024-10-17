#!/bin/bash

# Проверяем переданы ли аргументы
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <project_folder_name> <github_repo>"
    exit 1
fi

# Имя проекта в pm2
PROJECT_NAME="$1"

# Путь к папке проекта
PROJECT_PATH="$HOME/git/$PROJECT_NAME"

# GitHub репозиторий проекта
GITHUB_REPO="https://github.com/$2.git"

# Лог-файл
LOG_FILE="$PROJECT_PATH/deployment.log"

# Функция для установки зависимостей и запуска проекта
install_and_run_project() {
    echo "🛠 Cloning project from GitHub..."
    git clone $GITHUB_REPO $PROJECT_PATH

    cd $PROJECT_PATH

    echo "🛠 Starting project..."
    ./ci_start.sh $PROJECT_NAME "true"

    echo "🛠 Deployment successful. Project is up and running!"
}

# Функция для обновления проекта и зависимостей, а затем его перезапуска
update_and_restart_project() {
    cd $PROJECT_PATH

    echo "🛠 Stopping project with pm2..."
    ./ci_stop.sh $PROJECT_NAME

    echo "🛠 Pulling latest changes from GitHub..."
    git pull

    echo "🛠 Starting project..."
    ./ci_start.sh $PROJECT_NAME "false"

    echo "🛠 Deployment successful. Project is up and running!"
}

# Перенаправляем весь вывод в файл
{
    # Проверяем наличие папки проекта
    if [ -d "$PROJECT_PATH" ]; then
        update_and_restart_project
    else
        install_and_run_project
    fi
} | tee -a $LOG_FILE
