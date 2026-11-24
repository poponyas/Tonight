\set ON_ERROR_STOP on

BEGIN;

DO $$
DECLARE
    sport_id BIGINT;
    games_id BIGINT;
    cycling_id BIGINT;
    test_user_id UUID;
BEGIN
    INSERT INTO categories (name) VALUES ('Test Sport') RETURNING id INTO sport_id;
    INSERT INTO categories (name) VALUES ('Test Games') RETURNING id INTO games_id;
    INSERT INTO interests (category_id, name)
        VALUES (sport_id, 'Cycling') RETURNING id INTO cycling_id;
    INSERT INTO interests (category_id, name) VALUES (games_id, 'Cycling');

    BEGIN
        INSERT INTO categories (name) VALUES (' test sport ');
        RAISE EXCEPTION 'Expected a normalized category name collision';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;

    BEGIN
        INSERT INTO interests (category_id, name) VALUES (sport_id, ' cycling ');
        RAISE EXCEPTION 'Expected a normalized interest name collision within the category';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;

    BEGIN
        INSERT INTO categories (name) VALUES ('   ');
        RAISE EXCEPTION 'Expected blank category name rejection';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    BEGIN
        INSERT INTO interests (category_id, name) VALUES (sport_id, '   ');
        RAISE EXCEPTION 'Expected blank interest name rejection';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    UPDATE interests SET name = 'Biking' WHERE id = cycling_id;
    BEGIN
        UPDATE interests SET category_id = games_id WHERE id = cycling_id;
        RAISE EXCEPTION 'Expected interest category change rejection';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    INSERT INTO users (email, password_hash)
        VALUES (gen_random_uuid()::text || '@example.test', 'test-hash') RETURNING id INTO test_user_id;
    INSERT INTO user_interests (user_id, interest_id) VALUES (test_user_id, cycling_id);

    BEGIN
        INSERT INTO user_interests (user_id, interest_id) VALUES (test_user_id, cycling_id);
        RAISE EXCEPTION 'Expected duplicate user interest rejection';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;

    BEGIN
        INSERT INTO user_interests (user_id, interest_id) VALUES (test_user_id, -1);
        RAISE EXCEPTION 'Expected missing interest rejection';
    EXCEPTION WHEN foreign_key_violation THEN
        NULL;
    END;

    BEGIN
        DELETE FROM categories WHERE id = sport_id;
        RAISE EXCEPTION 'Expected deletion of a referenced category to be rejected';
    EXCEPTION WHEN foreign_key_violation THEN
        NULL;
    END;

    BEGIN
        DELETE FROM interests WHERE id = cycling_id;
        RAISE EXCEPTION 'Expected deletion of a selected interest to be rejected';
    EXCEPTION WHEN foreign_key_violation THEN
        NULL;
    END;

    DELETE FROM users WHERE id = test_user_id;
    IF EXISTS (SELECT FROM user_interests WHERE user_id = test_user_id) THEN
        RAISE EXCEPTION 'Expected the user interest to be deleted with its user';
    END IF;
END;
$$;

ROLLBACK;
