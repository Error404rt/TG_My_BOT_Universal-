import asyncio
import logging
import tempfile
import os
import shlex

from aiogram import types, F
from bot.core.config import SLEEP_BETWEEN_CHUNKS, MAX_DURATION_SECONDS
from bot.utils.helpers import cleanup_files, validate_video_file
from bot.utils.processing import get_video_duration, split_video_chunks, process_video_to_circle


async def handle_video_message(message: types.Message, bot):
    await message.answer("Получил видео, загружаю полностью... 🔄")
    video_file = message.video
    file_id = video_file.file_id
    chat_id = message.chat.id
    download_path = f"./downloads/{file_id}.mp4"

    try:
        # Ждём полной загрузки из TG
        file = await bot.get_file(file_id)
        await bot.download_file(file.file_path, destination=download_path)

        if not await validate_video_file(download_path):
            await bot.send_message(chat_id, "Загруженное видео не валидно. 😢")
            return

        duration = await get_video_duration(download_path)
        await message.answer(f"Видео загружено: {duration:.2f} сек. Начинаю обработку...")

        with tempfile.TemporaryDirectory() as chunk_dir:
            chunks = await split_video_chunks(download_path, chunk_dir)
            if not chunks:
                await bot.send_message(chat_id, "Ошибка при разделении видео. 😢")
                return

            num_chunks = len(chunks)
            if num_chunks > 1:
                await message.answer(
                    f"Видео слишком длинное ({duration:.2f} сек). Нарезаю на {num_chunks} кружков... ✂️")

            for i, chunk_path in enumerate(chunks, 1):
                if num_chunks > 1:
                    await bot.send_message(chat_id, f"Обрабатываю чанк {i}/{num_chunks}...")

                # Дополнительная обрезка до 60с, если split_video_chunks не обрезал идеально
                chunk_duration = await get_video_duration(chunk_path)
                if chunk_duration > MAX_DURATION_SECONDS + 1:  # +1 для допуска
                    trimmed_path = f"{chunk_path}.trimmed.mp4"
                    cmd_trim = f"ffmpeg -i {shlex.quote(chunk_path)} -t {MAX_DURATION_SECONDS} -c copy {shlex.quote(trimmed_path)}"
                    await run_ffmpeg_command(cmd_trim)
                    chunk_path = trimmed_path

                await process_video_to_circle(chunk_path, chat_id, bot)
                await asyncio.sleep(SLEEP_BETWEEN_CHUNKS)

        await bot.send_message(chat_id, "Готово! Ваши кружки отправлены. ✨")

    except Exception as e:
        logging.error(f"Error in handle_video_message: {e}")
        await bot.send_message(chat_id, "Произошла непредвиденная ошибка. 😭")
    finally:
        await cleanup_files(download_path, delay=1)


def register_video_circle_handlers(dp, bot):
    dp.message.register(handle_video_message, F.video)
