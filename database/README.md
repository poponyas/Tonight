# Начальная миграция

`migrations/001_create_initial_tables.up.sql` создаёт users, cities, profiles
и auth_sessions одной транзакцией. Файл `.down.sql` удаляет эти таблицы
в обратном порядке зависимостей, также одной транзакцией.

users.id и auth_sessions.id генерируются как UUID через gen_random_uuid().
Ссылки на пользователя имеют тип UUID; cities.id остаётся BIGINT identity.
Требуется PostgreSQL 13 или новее, где gen_random_uuid() встроена в сервер.

Из папки project, с настроенным подключением к **отдельной тестовой базе**:

```powershell
psql -v ON_ERROR_STOP=1 -f database/migrations/001_create_initial_tables.up.sql
```

Откат удаляет все данные этих четырёх таблиц:

```powershell
psql -v ON_ERROR_STOP=1 -f database/migrations/001_create_initial_tables.down.sql
```

Это замена первоначальных файлов в ещё не объединённом PR, а не преобразование
существующей базы с BIGINT в UUID. Если прежние миграции уже применены,
не запускайте новую поверх них. Для базы с нужными данными необходим отдельный
план переноса; не удаляйте таблицы для применения этой версии.
