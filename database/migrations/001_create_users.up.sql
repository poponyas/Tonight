BEGIN;

CREATE TABLE users(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(254) UNIQUE,
    password_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT users_account_state_check CHECK (
        (
            deleted_at IS NULL
            AND email IS NOT NULL
            AND password_hash IS NOT NULL
        )
        OR
        (
            deleted_at IS NOT NULL
            AND email IS NULL
            AND password_hash IS NULL
        )
    )
);

COMMIT;
