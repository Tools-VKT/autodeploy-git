# 🤖 autodeploy-git

Простой бекенд для принятия **webhook'ов** от Github с последующим деплоем на сервере.

На самом сервере понадобиться [`pm2`](https://pm2.keymetrics.io/docs/usage/quick-start/) (для запуска проектов) и `git`. `git` не сможет копировать приватные репозитории, поэтому может потребовать авторизация в аккаунте (по команде `gh auth login`)

Пример для `Ubuntu` установки пакетов:
```
npm install pm2@latest -g
apt-get install git
```

Для установки `gh` в `Ubuntu`:
```bash
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
```

## 💻 Как поднять?
1. Копируем репозиторий с бекендом:
```
git clone https://github.com/reyzitwo/autodeploy-git.git <dir-name>
```
2. Устанавливаем зависимости в проекте:
```
npm i
```
3. Создаем файл `.env` по примеру из `.env.example`, в качестве ключа указываем любую строку. Пригодится нам для проверки, что запрос действительно был отправлен от лица **Github**.
4. Запускаем бекенд:
```
npm start:prod
```
5. Готово! Бекенд будет работать по адресу `{SERVER}/autodeploy-git`, а конкретно по ручке `/deploy`.

Сам сервер поднимется по порту `3000`, но это можно поменять в файле `./src/main.ts`

## 🛠 Как работает?
1. Переходим во вкладку **Settings** -> **Webhooks**
2. Создаем новый webhook, указав наш сервер с поднятым бекендом (‼️ обязательно указать `secret` как на сервере)
3. Настраиваем, какие события будем принимать от Github (рекомендую выбрать только `Pushes`)
4. ✅ Profit!

На указанный нами URL будут отправляться `POST` запросы, которые будут вызывать скрипт `./src/scripts/deploy.sh`

## А как работает сам `deploy.sh`?
Скрипт в качестве параметров принимает имя папки проекта на сервере и путь до репозитория Github (например: `reyzitwo/autodeploy-git`). Все это уже настроено в коде, ничего указывать самостоятельно для вызова не нужно.

А сам принцип работы:

**а)** Если папки проекта на сервере нет:
1. Копируется репозиторий проекта в папку `$HOME/git/$PROJECT_NAME`
2. Установка зависимостей проекта
3. Старт проекта через `pm2` по команде `npm run autodeploy-gh` (соответственно, для проектов можно настроить как будет происходить запуск в `package.json`)

**б)** Если папка проекта уже имеется на сервере:
1. Остановка проекта в `pm2`
2. Подтягивание изменений с Github: `git pull`
3. Установка зависимостей проекта
4. Старт проекта через `pm2`