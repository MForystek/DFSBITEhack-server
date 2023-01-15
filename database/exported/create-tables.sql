-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 0.9.4
-- PostgreSQL version: 13.0
-- Project Site: pgmodeler.io
-- Model Author: ---
-- object: "kgex-user" | type: ROLE --
-- DROP ROLE IF EXISTS "kgex-user";
CREATE ROLE "kgex-user" WITH 
	CREATEDB
	LOGIN;
-- ddl-end --


-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: "kgex-db" | type: DATABASE --
-- DROP DATABASE IF EXISTS "kgex-db";
CREATE DATABASE "kgex-db"
	OWNER = "kgex-user";
-- ddl-end --


-- object: public.users | type: TABLE --
-- DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
	id serial NOT NULL,
	username text NOT NULL,
	password text NOT NULL,
	email text NOT NULL,
	creation_at timestamp NOT NULL,
	verification_at timestamp,
	icon_path text,
	verification_method_id int4,
	CONSTRAINT user_pk PRIMARY KEY (id),
	CONSTRAINT login_uq UNIQUE (username),
	CONSTRAINT email_uq UNIQUE (email),
	CONSTRAINT icon_path_uq UNIQUE (icon_path)
);
-- ddl-end --
COMMENT ON COLUMN public.users.verification_at IS E'if null uesr is unverified';
-- ddl-end --
COMMENT ON COLUMN public.users.icon_path IS E'path';
-- ddl-end --
ALTER TABLE public.users OWNER TO postgres;
-- ddl-end --

-- object: public.tags | type: TABLE --
-- DROP TABLE IF EXISTS public.tags CASCADE;
CREATE TABLE public.tags (
	id serial NOT NULL,
	name text NOT NULL,
	super_tag_id int4,
	level int2 NOT NULL,
	CONSTRAINT tags_pk PRIMARY KEY (id),
	CONSTRAINT tag_uq UNIQUE (name)
);
-- ddl-end --
ALTER TABLE public.tags OWNER TO postgres;
-- ddl-end --

-- object: public.users_tags_teach | type: TABLE --
-- DROP TABLE IF EXISTS public.users_tags_teach CASCADE;
CREATE TABLE public.users_tags_teach (
	user_id int4 NOT NULL,
	tag_id int4 NOT NULL,
	CONSTRAINT users_tags_pk PRIMARY KEY (user_id,tag_id)
);
-- ddl-end --
ALTER TABLE public.users_tags_teach OWNER TO postgres;
-- ddl-end --

-- object: public.verification_method_dict | type: TABLE --
-- DROP TABLE IF EXISTS public.verification_method_dict CASCADE;
CREATE TABLE public.verification_method_dict (
	id serial NOT NULL,
	method text NOT NULL,
	CONSTRAINT verification_method_dict_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.verification_method_dict OWNER TO postgres;
-- ddl-end --

-- object: public.user_roles | type: TABLE --
-- DROP TABLE IF EXISTS public.user_roles CASCADE;
CREATE TABLE public.user_roles (
	user_id int4 NOT NULL,
	role_id int4 NOT NULL,
	CONSTRAINT user_roles_pk PRIMARY KEY (user_id,role_id)
);
-- ddl-end --
ALTER TABLE public.user_roles OWNER TO postgres;
-- ddl-end --

-- object: public.roles | type: TABLE --
-- DROP TABLE IF EXISTS public.roles CASCADE;
CREATE TABLE public.roles (
	id serial NOT NULL,
	name text,
	CONSTRAINT name_uq UNIQUE (name),
	CONSTRAINT roles_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.roles OWNER TO postgres;
-- ddl-end --

-- object: public.chat_message | type: TABLE --
-- DROP TABLE IF EXISTS public.chat_message CASCADE;
CREATE TABLE public.chat_message (
	id serial NOT NULL,
	message text NOT NULL,
	"time" timestamp NOT NULL,
	chat_session_id int4 NOT NULL,
	to_user_id int4 NOT NULL,
	CONSTRAINT chat_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.chat_message OWNER TO postgres;
-- ddl-end --

-- object: public.chat_session | type: TABLE --
-- DROP TABLE IF EXISTS public.chat_session CASCADE;
CREATE TABLE public.chat_session (
	id serial NOT NULL,
	l_user_id int4 NOT NULL,
	o_user_id int4 NOT NULL,
	CONSTRAINT chat_session_pk PRIMARY KEY (id)
);
-- ddl-end --
ALTER TABLE public.chat_session OWNER TO postgres;
-- ddl-end --

-- object: public.users_tags_learn | type: TABLE --
-- DROP TABLE IF EXISTS public.users_tags_learn CASCADE;
CREATE TABLE public.users_tags_learn (
	user_id int4 NOT NULL,
	tag_id int4 NOT NULL,
	CONSTRAINT t_uq PRIMARY KEY (user_id,tag_id)
);
-- ddl-end --
ALTER TABLE public.users_tags_learn OWNER TO postgres;
-- ddl-end --

-- object: verification_method_fk | type: CONSTRAINT --
-- ALTER TABLE public.users DROP CONSTRAINT IF EXISTS verification_method_fk CASCADE;
ALTER TABLE public.users ADD CONSTRAINT verification_method_fk FOREIGN KEY (verification_method_id)
REFERENCES public.verification_method_dict (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: user_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags_teach DROP CONSTRAINT IF EXISTS user_id_fk CASCADE;
ALTER TABLE public.users_tags_teach ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: tag_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags_teach DROP CONSTRAINT IF EXISTS tag_id_fk CASCADE;
ALTER TABLE public.users_tags_teach ADD CONSTRAINT tag_id_fk FOREIGN KEY (tag_id)
REFERENCES public.tags (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: user_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_id_fk CASCADE;
ALTER TABLE public.user_roles ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: role_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS role_id_fk CASCADE;
ALTER TABLE public.user_roles ADD CONSTRAINT role_id_fk FOREIGN KEY (role_id)
REFERENCES public.roles (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: chat_session_fk | type: CONSTRAINT --
-- ALTER TABLE public.chat_message DROP CONSTRAINT IF EXISTS chat_session_fk CASCADE;
ALTER TABLE public.chat_message ADD CONSTRAINT chat_session_fk FOREIGN KEY (chat_session_id)
REFERENCES public.chat_session (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: l_user_fk | type: CONSTRAINT --
-- ALTER TABLE public.chat_session DROP CONSTRAINT IF EXISTS l_user_fk CASCADE;
ALTER TABLE public.chat_session ADD CONSTRAINT l_user_fk FOREIGN KEY (l_user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: o_user_id | type: CONSTRAINT --
-- ALTER TABLE public.chat_session DROP CONSTRAINT IF EXISTS o_user_id CASCADE;
ALTER TABLE public.chat_session ADD CONSTRAINT o_user_id FOREIGN KEY (o_user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --

-- object: user_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags_learn DROP CONSTRAINT IF EXISTS user_id_fk CASCADE;
ALTER TABLE public.users_tags_learn ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: tag_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags_learn DROP CONSTRAINT IF EXISTS tag_id_fk CASCADE;
ALTER TABLE public.users_tags_learn ADD CONSTRAINT tag_id_fk FOREIGN KEY (tag_id)
REFERENCES public.tags (id) MATCH SIMPLE
ON DELETE NO ACTION ON UPDATE NO ACTION;
-- ddl-end --


