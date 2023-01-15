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
	creation_at date,
	verification_at date,
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
	tag text NOT NULL,
	super_tag_id int4,
	level int2 NOT NULL,
	CONSTRAINT tags_pk PRIMARY KEY (id),
	CONSTRAINT tag_uq UNIQUE (tag)
);
-- ddl-end --
ALTER TABLE public.tags OWNER TO postgres;
-- ddl-end --

-- object: public.users_tags | type: TABLE --
-- DROP TABLE IF EXISTS public.users_tags CASCADE;
CREATE TABLE public.users_tags (
	user_id int4 NOT NULL,
	tag_id int4 NOT NULL,
	CONSTRAINT users_tags_pk PRIMARY KEY (user_id,tag_id)
);
-- ddl-end --
ALTER TABLE public.users_tags OWNER TO postgres;
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

-- object: verification_method_fk | type: CONSTRAINT --
-- ALTER TABLE public.users DROP CONSTRAINT IF EXISTS verification_method_fk CASCADE;
ALTER TABLE public.users ADD CONSTRAINT verification_method_fk FOREIGN KEY (verification_method_id)
REFERENCES public.verification_method_dict (id) MATCH SIMPLE
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: user_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags DROP CONSTRAINT IF EXISTS user_id_fk CASCADE;
ALTER TABLE public.users_tags ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id)
REFERENCES public.users (id) MATCH SIMPLE
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --

-- object: tag_id_fk | type: CONSTRAINT --
-- ALTER TABLE public.users_tags DROP CONSTRAINT IF EXISTS tag_id_fk CASCADE;
ALTER TABLE public.users_tags ADD CONSTRAINT tag_id_fk FOREIGN KEY (tag_id)
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


