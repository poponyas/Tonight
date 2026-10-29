CREATE TABLE cities (
    id BIGSERIAL PRIMARY KEY,
    region TEXT NOT NULL,
    city TEXT NOT NULL,
    timezone TEXT NOT NULL
);