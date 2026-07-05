#!/usr/bin/env bash
set -euo pipefail

# ===========================================
# Автоматическая установка TG_My_BOT_Universal3
# Для Termux + Proot Ubuntu / обычной Ubuntu / Debian
# ===========================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_PYTHON_MAJOR=3
REQUIRED_PYTHON_MINOR=11

check_python() {
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        echo "❌ Python не найден. Установи Python 3.11 или новее."
        exit 1
    fi

    local version
    version="$($PYTHON_CMD --version 2>&1 | awk '{print $2}')"
    local major minor
    major="$(echo "$version" | cut -d. -f1)"
    minor="$(echo "$version" | cut -d. -f2)"

    if [[ "$major" -lt $REQUIRED_PYTHON_MAJOR ]] || { [[ "$major" -eq $REQUIRED_PYTHON_MAJOR ]] && [[ "$minor" -lt $REQUIRED_PYTHON_MINOR ]]; }; then
        echo "❌ Нужен Python >= 3.11, найден $version"
        exit 1
    fi

    echo "✅ Python $version"
}

install_system_deps() {
    echo ""
    echo "🔧 Проверяю системные зависимости..."

    if ! command -v ffmpeg &>/dev/null; then
        echo "⬇️  Устанавливаю FFmpeg..."
        if command -v apt-get &>/dev/null; then
            # Стараемся избежать зависания man-db
            DEBIAN_FRONTEND=noninteractive \
                sudo -n apt-get update -y && \
                sudo -n apt-get install -y -o Dpkg::Options::="--force-confdef" \
                    -o Dpkg::Options::="--force-confold" \
                    ffmpeg curl git || {
                echo "⚠️  Не удалось установить FFmpeg через apt. Попробуй вручную:"
                echo "   sudo apt-get install ffmpeg curl git"
                exit 1
            }
        elif command -v pkg &>/dev/null; then
            pkg install -y ffmpeg curl git
        else
            echo "❌ Не найден apt-get или pkg. Установи FFmpeg вручную."
            exit 1
        fi
    else
        echo "✅ FFmpeg уже установлен"
    fi

    if ! command -v git &>/dev/null; then
        echo "⚠️  Git не найден. Для автообновления бота он понадобится."
    else
        echo "✅ Git уже установлен"
    fi
}

install_poetry() {
    echo ""
    echo "🔧 Проверяю Poetry..."
    if command -v poetry &>/dev/null; then
        echo "✅ Poetry $(poetry --version 2>&1)"
        return
    fi

    echo "⬇️  Устанавливаю Poetry официальным скриптом..."
    curl -fsSL https://install.python-poetry.org | python3 -

    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v poetry &>/dev/null; then
        echo "⚠️  Poetry не найден в PATH. Добавь в ~/.bashrc:"
        echo "   export PATH=\"\\$HOME/.local/bin:\\$PATH\""
        echo "   source ~/.bashrc"
        exit 1
    fi
    echo "✅ Poetry установлен"
}

install_python_deps() {
    echo ""
    echo "🔧 Устанавливаю Python-зависимости через Poetry..."
    cd "$PROJECT_DIR"
    poetry install --no-interaction
    echo "✅ Зависимости установлены"
}

create_env_if_missing() {
    echo ""
    echo "🔧 Проверяю .env..."
    cd "$PROJECT_DIR"
    if [[ -f ".env" ]]; then
        echo "✅ Файл .env уже есть"
    else
        cp Parse_bot/.env .env 2>/dev/null || cat > .env << 'EOF'
BOT_TOKEN=PASTE_TOKEN_HERE

MAX_DURATION_SECONDS=60
MAX_FILE_SIZE_BYTES=12582912
MAX_VIDEO_SIZE_BYTES=52428800
CIRCLE_SIZE=640
MIN_FILE_SIZE_BYTES=10240
RETRY_DOWNLOAD_ATTEMPTS=2
RETRY_SEND_ATTEMPTS=3

SLEEP_BETWEEN_CHUNKS=2
EOF
        echo "📝 Создан шаблон .env"
    fi

    if grep -q "PASTE_TOKEN_HERE\|bot father token" .env; then
        echo ""
        echo "⚠️  В .env стоит заглушка токена."
        echo "   Открой файл: $PROJECT_DIR/.env"
        echo "   Замени BOT_TOKEN=... на токен от @BotFather"
        echo "   Потом запусти бота командой: 🤖"
    else
        echo "✅ Токен найден в .env"
    fi
}

add_emoji_launcher() {
    echo ""
    echo "🔧 Добавляю команду 🤖 в ~/.bashrc..."
    if ! grep -q "^🤖()" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << EOF

🤖() {
    cd "$PROJECT_DIR" && export PATH="\$HOME/.local/bin:\$PATH" && poetry run python main.py
}
EOF
        echo "✅ Команда 🤖 добавлена. Выполни: source ~/.bashrc"
    else
        echo "✅ Команда 🤖 уже есть в ~/.bashrc"
    fi
}

main() {
    echo "🚀 Установка TG_My_BOT_Universal3"
    echo "================================="

    check_python
    install_system_deps
    install_poetry
    install_python_deps
    create_env_if_missing
    add_emoji_launcher

    echo ""
    echo "================================="
    echo "✅ Установка завершена!"
    echo ""
    echo "Чтобы запустить бота:"
    echo "   source ~/.bashrc"
    echo "   🤖"
    echo ""
    echo "Остановить бота: Ctrl+C"
    echo ""
}

main "$@"
