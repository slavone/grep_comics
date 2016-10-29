--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: creator_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE creator_type AS ENUM (
    'writer',
    'artist',
    'cover_artist'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE api_keys (
    id integer NOT NULL,
    key character varying,
    call_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE api_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE api_keys_id_seq OWNED BY api_keys.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comics (
    id integer NOT NULL,
    diamond_code character varying,
    title character varying,
    issue_number integer,
    preview text,
    suggested_price numeric,
    item_type character varying,
    shipping_date date,
    publisher_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cover_image character varying,
    weekly_list_id integer,
    is_variant boolean,
    reprint_number smallint,
    cover_thumbnail character varying,
    no_cover_available boolean
);


--
-- Name: comics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comics_id_seq OWNED BY comics.id;


--
-- Name: creator_credits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE creator_credits (
    id integer NOT NULL,
    creator_id integer,
    comic_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    credited_as creator_type
);


--
-- Name: creator_credits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creator_credits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creator_credits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creator_credits_id_seq OWNED BY creator_credits.id;


--
-- Name: creators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE creators (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: creators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creators_id_seq OWNED BY creators.id;


--
-- Name: publishers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE publishers (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: publishers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE publishers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publishers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE publishers_id_seq OWNED BY publishers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: weekly_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE weekly_lists (
    id integer NOT NULL,
    list text,
    wednesday_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: weekly_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE weekly_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weekly_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE weekly_lists_id_seq OWNED BY weekly_lists.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys ALTER COLUMN id SET DEFAULT nextval('api_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comics ALTER COLUMN id SET DEFAULT nextval('comics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creator_credits ALTER COLUMN id SET DEFAULT nextval('creator_credits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY creators ALTER COLUMN id SET DEFAULT nextval('creators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers ALTER COLUMN id SET DEFAULT nextval('publishers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY weekly_lists ALTER COLUMN id SET DEFAULT nextval('weekly_lists_id_seq'::regclass);


--
-- Name: api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comics
    ADD CONSTRAINT comics_pkey PRIMARY KEY (id);


--
-- Name: creator_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY creator_credits
    ADD CONSTRAINT creator_credits_pkey PRIMARY KEY (id);


--
-- Name: creators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY creators
    ADD CONSTRAINT creators_pkey PRIMARY KEY (id);


--
-- Name: publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: weekly_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY weekly_lists
    ADD CONSTRAINT weekly_lists_pkey PRIMARY KEY (id);


--
-- Name: index_comics_on_diamond_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comics_on_diamond_code ON comics USING btree (diamond_code);


--
-- Name: index_comics_on_publisher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comics_on_publisher_id ON comics USING btree (publisher_id);


--
-- Name: index_comics_on_shipping_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comics_on_shipping_date ON comics USING btree (shipping_date);


--
-- Name: index_comics_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comics_on_title ON comics USING btree (title);


--
-- Name: index_comics_on_weekly_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comics_on_weekly_list_id ON comics USING btree (weekly_list_id);


--
-- Name: index_creator_credits_on_comic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creator_credits_on_comic_id ON creator_credits USING btree (comic_id);


--
-- Name: index_creator_credits_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creator_credits_on_creator_id ON creator_credits USING btree (creator_id);


--
-- Name: index_creator_credits_on_creator_id_and_credited_as; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creator_credits_on_creator_id_and_credited_as ON creator_credits USING btree (creator_id, credited_as);


--
-- Name: index_creators_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_creators_on_name ON creators USING btree (name);


--
-- Name: index_publishers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publishers_on_name ON publishers USING btree (name);


--
-- Name: index_weekly_lists_on_wednesday_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weekly_lists_on_wednesday_date ON weekly_lists USING btree (wednesday_date);


--
-- Name: fk_rails_4c749ccbd2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comics
    ADD CONSTRAINT fk_rails_4c749ccbd2 FOREIGN KEY (publisher_id) REFERENCES publishers(id);


--
-- Name: fk_rails_51059dd044; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY creator_credits
    ADD CONSTRAINT fk_rails_51059dd044 FOREIGN KEY (comic_id) REFERENCES comics(id);


--
-- Name: fk_rails_812b74135e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comics
    ADD CONSTRAINT fk_rails_812b74135e FOREIGN KEY (weekly_list_id) REFERENCES weekly_lists(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160610092548'), ('20160610093044'), ('20160610093739'), ('20160610095244'), ('20160611111551'), ('20160611115320'), ('20160611143027'), ('20160612185459'), ('20160613112716'), ('20160614123546'), ('20160614193602'), ('20160708165412'), ('20160731195932'), ('20160821165255'), ('20161027152719');


