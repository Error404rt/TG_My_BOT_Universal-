# 🤖 Многофункциональный Telegram-бот

Бот для скачивания и обработки контента из социальных сетей.

## Возможности

- 🎥 Создание кружков (длительность видео не ограничена)
- 🎵 Скачивание с TikTok + распознавание песни
- 📹 Скачивание с Instagram Reels
- 🎧 Извлечение аудио из TikTok / Reels
- 📺 Скачивание с YouTube
- 🔞 Скачивание с Pornhub

## Требования

- Android + Termux + Proot Ubuntu **или** Ubuntu/Debian на ПК/VPS
- Python **3.11 или новее**
- Интернет-соединение

## Быстрая установка

1. Склонируй репозиторий:

```bash
git clone https://github.com/Error404rt/TG_My_BOT_Universal3.git
cd TG_My_BOT_Universal3
```

2. Запусти автоматическую установку:

```bash
bash install.sh
```

Скрипт сам:
- проверит Python,
- установит FFmpeg, curl, git (если нужно),
- установит менеджер зависимостей Poetry,
- установит все Python-пакеты,
- создаст шаблон `.env`,
- добавит команду запуска `🤖` в `~/.bashrc`.

> ⚠️ Если во время установки `apt-get` спросит пароль — введи пароль от Ubuntu.
> ⚠️ В Termux используй `pkg` вместо `apt`, либо запускай скрипт внутри Proot Ubuntu.

## Настройка токена

После установки открой файл `.env` в папке бота:

```bash
nano .env
```

Найди строку:

```
BOT_TOKEN=PASTE_TOKEN_HERE
```

Замени `PASTE_TOKEN_HERE` на токен, полученный от [@BotFather](https://t.me/BotFather).

Пример:

```
BOT_TOKEN=1234567890:ABCDEF...xyz
```

Сохрани файл (`Ctrl+O`, `Enter`, `Ctrl+X` в nano).

## Запуск бота

После установки и настройки токена просто введи:

```bash
🤖
```

Если команда не сработала сразу, обнови оболочку:

```bash
source ~/.bashrc
🤖
```

Бот запустится в текущем окне. Чтобы остановить — нажми `Ctrl+C`.

## Ручной запуск (если не хочешь команду 🤖)

```bash
cd TG_My_BOT_Universal3
poetry run python main.py
```

## Установка вручную (если install.sh не подошёл)

```bash
# 1. Системные зависимости
sudo apt-get update
sudo apt-get install -y ffmpeg curl git

# 2. Poetry
curl -fsSL https://install.python-poetry.org | python3 -
export PATH="$HOME/.local/bin:$PATH"

# 3. Python-зависимости
poetry install

# 4. Настрой .env и запускай
nano .env
poetry run python main.py
```

## Важные замечания

- Бот автоматически проверяет обновления из Git-репозитория при запуске. Для этого нужен `git`.
- Файл `.env` содержит твой токен — **никому его не показывай** и не отправляй в Git.
- Для работы с видео используется FFmpeg.

## Структура проекта

```
TG_My_BOT_Universal3/
├── bot/
│   ├── core/          # конфигурация
│   ├── handlers/      # обработчики команд
│   └── utils/         # вспомогательные функции
├── Parse_bot/
│   └── .env           # резервный шаблон .env
├── install.sh         # автоматический установщик
├── main.py            # точка входа
├── pyproject.toml     # зависимости Poetry
├── requirements.txt   # зависимости pip (fallback)
└── README.md          # этот файл
```

## Лицензия

Private.
