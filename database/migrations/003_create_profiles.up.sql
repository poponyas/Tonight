BEGIN;

CREATE TABLE profiles(
    user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(80) NOT NULL,
    city_id BIGINT NOT NULL REFERENCES cities(id),
    bio VARCHAR(500),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;
