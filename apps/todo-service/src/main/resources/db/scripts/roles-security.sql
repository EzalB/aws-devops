CREATE TABLE public.users
(
    user_id bigint NOT NULL,
    username character varying(255) NOT NULL UNIQUE,
    password character varying(255) NOT NULL,
	create_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    roles VARCHAR(255) NOT NULL,
    PRIMARY KEY (user_id, role),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

ALTER TABLE IF EXISTS public.users
    OWNER to postgres;
