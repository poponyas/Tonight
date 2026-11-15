# Загрузка городов в PostgreSQL

Скрипт `scripts/seed_cities.sh` загружает 1102 города из `seeds/cities.csv` в таблицу `cities`.

Перед запуском таблица `cities` должна быть создана через миграцию.

## Linux (Ubuntu/Debian)

Установить `psql`:

```bash
sudo apt update
sudo apt install postgresql-client
```

Запустить из корня проекта:

```bash
DATABASE_URL="postgresql://postgres@localhost:5432/tonight_lite" \
bash scripts/seed_cities.sh
```

## Windows

Установить Git Bash и PostgreSQL Command Line Tools (`psql`).

Открыть Git Bash в папке проекта:

```bash
export DATABASE_URL="postgresql://postgres@localhost:5432/tonight_lite"
bash scripts/seed_cities.sh
```

Если `psql` не найден, добавить каталог `bin` PostgreSQL в `PATH`.

## macOS

Установить `psql`:

```bash
brew install libpq
```

Запустить:

```bash
export PATH="$(brew --prefix libpq)/bin:$PATH"

DATABASE_URL="postgresql://postgres@localhost:5432/tonight_lite" \
bash scripts/seed_cities.sh
```

## Проверка

В DBeaver выполнить:

```sql
SELECT COUNT(*) FROM public.cities;
```

Ожидаемый результат: **1102 записи**.

При необходимости заменить параметры подключения в `DATABASE_URL`. Пароль PostgreSQL вводится при запросе. Повторный последовательный запуск скрипта не добавляет существующие города.
