--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

-- Started on 2023-01-23 20:58:16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--
--
-- TOC entry 258 (class 1255 OID 41154)
-- Name: dodaj_trenera(character varying, character varying, numeric, character varying, character varying, character varying, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE OR REPLACE PROCEDURE public.dodaj_trenera(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN vnazwa_klubu character varying)
    LANGUAGE plpgsql
    AS $$
declare
selected_adr dane_adresowe%rowtype;
selected_tre trenerzy%rowtype;
selected_kl kluby%rowtype;
klub_id kluby.id_klubu%type;
begin
select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or(vulica is null and ulica is null) ) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
if not found then
	RAISE NOTICE 'DODAJE ADRES';
	insert into dane_adresowe(miejscowosc,ulica,numer_budynku,numer_lokalu,kod_pocztowy) values(vmiejscowosc,vulica,vnumer_domu,vnumer_lokalu,vkod_pocztowy);
end if;
select * from kluby into selected_kl where vnazwa_klubu=nazwa_klubu;
if not found then
	RAISE NOTICE 'DODAJE KLUB';
	insert into kluby(nazwa_klubu) values(vnazwa_klubu);
end if;
select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null) ) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null) ) and vkod_pocztowy=kod_pocztowy;
	RAISE NOTICE 'ADRES %',selected_adr.ulica;
	select pesel from trenerzy into selected_tre where vpesel=pesel;
	if not found then
    select from kluby into klub_id where nazwa_klubu=vnazwa_klubu;
	insert into trenerzy(imie,nazwisko,pesel,id_klubu,id_adresu) values(vimie,vnazwisko,vpesel,klub_id,selected_adr.id_miejsca);
	else 
	RAISE NOTICE 'Trener o peselu % już w bazie',selected_tre.pesel;
	end if;
end ;
$$;


ALTER PROCEDURE public.dodaj_trenera(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN id_klubu integer) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 41155)
-- Name: dodaj_zawodnika(character varying, character varying, numeric, character varying, character varying, character varying, integer, integer, integer, character); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.dodaj_zawodnika(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN id_klubu integer, IN plec character)
    LANGUAGE plpgsql
    AS $$
declare
selected_adr dane_adresowe%rowtype;
selected_zaw zawodnicy%rowtype;
begin
select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null)) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
if not found then
	insert into dane_adresowe(miejscowosc,ulica,numer_budynku,numer_lokalu,kod_pocztowy) values(vmiejscowosc,vulica,vnumer_domu,vnumer_lokalu,vkod_pocztowy);
end if;
select * from dane_adresowe into selected_adr where vmiejscowosc=miejscowosc and (vulica=ulica or (vulica is null and ulica is null)) and vnumer_domu=numer_budynku and (vnumer_lokalu=numer_lokalu or (vnumer_lokalu is null and numer_lokalu is null)) and vkod_pocztowy=kod_pocztowy;
	select pesel from zawodnicy into selected_zaw where vpesel=pesel;
	if not found then
	insert into zawodnicy(imie,nazwisko,plec,pesel,id_klubu,dane_adresowe) values(vimie,vnazwisko,plec,vpesel,id_klubu,selected_adr.id_miejsca);
	else
	RAISE NOTICE 'Zawodnik o peselu % już w bazie',selected_zaw.pesel;
	end if;
end ;
$$;


ALTER PROCEDURE public.dodaj_zawodnika(IN vimie character varying, IN vnazwisko character varying, IN vpesel numeric, IN vulica character varying, IN vkod_pocztowy character varying, IN vmiejscowosc character varying, IN vnumer_domu integer, IN vnumer_lokalu integer, IN id_klubu integer, IN plec character) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 214 (class 1259 OID 41156)
-- Name: dane_adresowe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dane_adresowe (
    id_miejsca integer NOT NULL,
    miejscowosc character varying NOT NULL,
    ulica character varying,
    numer_budynku integer NOT NULL,
    numer_lokalu integer,
    kod_pocztowy character varying NOT NULL
);


ALTER TABLE public.dane_adresowe OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 41161)
-- Name: dane_adresowe_id_miejsca_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dane_adresowe ALTER COLUMN id_miejsca ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dane_adresowe_id_miejsca_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 216 (class 1259 OID 41162)
-- Name: grupy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupy (
    id_grupy integer NOT NULL,
    nazwa character varying NOT NULL,
    id_konkurencji integer NOT NULL,
    id_klubu integer NOT NULL
);


ALTER TABLE public.grupy OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 41167)
-- Name: grupy_id_grupy_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.grupy ALTER COLUMN id_grupy ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.grupy_id_grupy_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 41168)
-- Name: grupy_zawodnicy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupy_zawodnicy (
    id_grupy integer NOT NULL,
    id_zawodnika integer NOT NULL
);


ALTER TABLE public.grupy_zawodnicy OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 41171)
-- Name: kluby; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kluby (
    id_klubu integer NOT NULL,
    nazwa_klubu character varying NOT NULL
);


ALTER TABLE public.kluby OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 41176)
-- Name: kluby_id_klubu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.kluby ALTER COLUMN id_klubu ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.kluby_id_klubu_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 41177)
-- Name: konkurencje; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.konkurencje (
    id_konkurencji integer NOT NULL,
    nazwa_konkurencji character varying NOT NULL
);


ALTER TABLE public.konkurencje OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 41182)
-- Name: konkurencje_id_konkurencji_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.konkurencje ALTER COLUMN id_konkurencji ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.konkurencje_id_konkurencji_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 41183)
-- Name: wyniki; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wyniki (
    id_rekordu integer NOT NULL,
    czas numeric(5,4) NOT NULL,
    id_treningu integer,
    id_zawodow integer,
    id_zawodnika integer NOT NULL,
    id_konkurencji integer NOT NULL
);


ALTER TABLE public.wyniki OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 41186)
-- Name: zawodnicy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zawodnicy (
    id_zawodnika integer NOT NULL,
    imie character varying NOT NULL,
    nazwisko character varying NOT NULL,
    plec character(1) NOT NULL,
    pesel numeric(12,0),
    id_klubu integer NOT NULL,
    dane_adresowe integer
);


ALTER TABLE public.zawodnicy OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 41200)
-- Name: zawody; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zawody (
    id_zawodow integer NOT NULL,
    data_zawodow date NOT NULL,
    id_obiektu integer NOT NULL,
    nazwa character varying
);


ALTER TABLE public.zawody OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 41191)
-- Name: nazwiska_wyniki; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nazwiska_wyniki AS
 SELECT z.imie,
    z.nazwisko,
    w.czas,
    kk.nazwa_konkurencji,
    z.id_zawodnika,
    za.data_zawodow,
    za.nazwa
   FROM (((public.wyniki w
     JOIN public.zawodnicy z ON ((w.id_zawodnika = z.id_zawodnika)))
     JOIN public.konkurencje kk ON ((kk.id_konkurencji = w.id_konkurencji)))
     JOIN public.zawody za ON ((za.id_zawodow = w.id_zawodow)));


ALTER TABLE public.nazwiska_wyniki OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 41195)
-- Name: obiekty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.obiekty (
    id_obiektu integer NOT NULL,
    dane_adresowe integer NOT NULL,
    nazwa character varying NOT NULL
);


ALTER TABLE public.obiekty OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 41203)
-- Name: zawody_zawodnicy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zawody_zawodnicy (
    id_zawodnika integer NOT NULL,
    id_zawodow integer NOT NULL
);


ALTER TABLE public.zawody_zawodnicy OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 41206)
-- Name: nazwiska_zawody; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nazwiska_zawody AS
 SELECT z.imie,
    z.nazwisko,
    z.id_zawodnika,
    z2.data_zawodow,
    o.nazwa
   FROM (((public.zawody_zawodnicy zz
     JOIN public.zawodnicy z ON ((zz.id_zawodnika = z.id_zawodnika)))
     JOIN public.zawody z2 ON ((zz.id_zawodow = z2.id_zawodow)))
     JOIN public.obiekty o ON ((z2.id_obiektu = o.id_obiektu)));


ALTER TABLE public.nazwiska_zawody OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 41210)
-- Name: obiekty_id_obiektu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.obiekty ALTER COLUMN id_obiektu ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.obiekty_id_obiektu_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 41211)
-- Name: trenerzy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trenerzy (
    id_trenera integer NOT NULL,
    imie character varying NOT NULL,
    nazwisko character varying NOT NULL,
    pesel numeric(12,0),
    id_klubu integer NOT NULL,
    id_adresu integer NOT NULL
);


ALTER TABLE public.trenerzy OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 41216)
-- Name: trenerzy_adresy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.trenerzy_adresy AS
 SELECT tr.id_trenera,
    tr.imie,
    tr.nazwisko,
    tr.pesel,
    tr.id_klubu,
    tr.id_adresu,
    d.id_miejsca,
    d.miejscowosc,
    d.ulica,
    d.numer_budynku,
    d.numer_lokalu,
    d.kod_pocztowy
   FROM (public.trenerzy tr
     JOIN public.dane_adresowe d ON ((d.id_miejsca = tr.id_adresu)));


ALTER TABLE public.trenerzy_adresy OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 41220)
-- Name: trenerzy_grupy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trenerzy_grupy (
    id_trenera integer NOT NULL,
    id_grupy integer NOT NULL
);


ALTER TABLE public.trenerzy_grupy OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 41223)
-- Name: trenerzy_id_trenera_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.trenerzy ALTER COLUMN id_trenera ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.trenerzy_id_trenera_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 41224)
-- Name: treningi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treningi (
    id_treningu integer NOT NULL,
    data_treningu date NOT NULL,
    id_obiektu integer NOT NULL
);


ALTER TABLE public.treningi OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 41386)
-- Name: treningi_adresy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.treningi_adresy AS
 SELECT t.data_treningu
   FROM (public.treningi t
     JOIN public.obiekty o ON ((o.id_obiektu = t.id_obiektu)));


ALTER TABLE public.treningi_adresy OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 41227)
-- Name: treningi_id_treningu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.treningi ALTER COLUMN id_treningu ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.treningi_id_treningu_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 237 (class 1259 OID 41228)
-- Name: treningi_konkurencje; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.treningi_konkurencje (
    id_treningu integer NOT NULL,
    id_konkurencji integer NOT NULL
);


ALTER TABLE public.treningi_konkurencje OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 41231)
-- Name: wyniki_id_rekordu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.wyniki ALTER COLUMN id_rekordu ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.wyniki_id_rekordu_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 246 (class 1259 OID 57356)
-- Name: wyniki_zawody; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.wyniki_zawody AS
 SELECT z.imie,
    z.nazwisko,
    z.plec,
    w.czas,
    kk.nazwa_konkurencji,
    z.id_zawodnika,
    za.id_zawodow
   FROM (((public.wyniki w
     JOIN public.zawodnicy z ON ((w.id_zawodnika = z.id_zawodnika)))
     JOIN public.konkurencje kk ON ((kk.id_konkurencji = w.id_konkurencji)))
     JOIN public.zawody za ON ((za.id_zawodow = w.id_zawodow)));


ALTER TABLE public.wyniki_zawody OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 41232)
-- Name: zawodnicy_adresy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.zawodnicy_adresy AS
 SELECT z.id_zawodnika,
    z.imie,
    z.nazwisko,
    z.plec,
    z.pesel,
    z.id_klubu,
    z.dane_adresowe,
    d.id_miejsca,
    d.miejscowosc,
    d.ulica,
    d.numer_budynku,
    d.numer_lokalu,
    d.kod_pocztowy
   FROM (public.zawodnicy z
     JOIN public.dane_adresowe d ON ((d.id_miejsca = z.dane_adresowe)));


ALTER TABLE public.zawodnicy_adresy OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 41236)
-- Name: zawodnicy_id_zawodnika_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.zawodnicy ALTER COLUMN id_zawodnika ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.zawodnicy_id_zawodnika_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 245 (class 1259 OID 41390)
-- Name: zawodnicy_wyniki; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.zawodnicy_wyniki AS
 SELECT z.id_zawodnika,
    z.imie,
    z.nazwisko,
    z.plec,
    z.pesel,
    z.id_klubu,
    z.dane_adresowe,
    w.czas,
    w.id_konkurencji,
    w.id_treningu,
    w.id_zawodow
   FROM (public.zawodnicy z
     JOIN public.wyniki w ON ((w.id_zawodnika = z.id_zawodnika)));


ALTER TABLE public.zawodnicy_wyniki OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 41382)
-- Name: zawody_adresy; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.zawody_adresy AS
 SELECT z.data_zawodow,
    o.nazwa
   FROM (public.zawody z
     JOIN public.obiekty o ON ((o.id_obiektu = z.id_obiektu)));


ALTER TABLE public.zawody_adresy OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 41237)
-- Name: zawody_id_zawodow_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.zawody ALTER COLUMN id_zawodow ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.zawody_id_zawodow_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 242 (class 1259 OID 41238)
-- Name: zawody_konkurencje; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zawody_konkurencje (
    id_zawodow integer NOT NULL,
    id_konkurencji integer NOT NULL
);


ALTER TABLE public.zawody_konkurencje OWNER TO postgres;

--
-- TOC entry 3475 (class 0 OID 41156)
-- Dependencies: 214
-- Data for Name: dane_adresowe; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (1, 'Testowo', 'Zawodowa', 2, NULL, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (2, 'Testowo', 'Testowa', 1, NULL, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (3, 'Poznan', 'Brzozowa', 11, 11, '00-00');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (7, 'Poznan', 'Brzozowsa', 11, 11, '00-00');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (16, 'Poznan', 'Główna', 11, 1, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (18, 'Poznan', 'Główna', 11, NULL, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (20, 'Poznan', 'Ganta', 11, NULL, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (25, 'Ul', 'Sasa', 11, 11, '123456');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (26, 'Poznan', 'Poznanska', 12, 12, '9u329u39');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (27, 'Poznan', '', 12, 12, '9u329u39');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (28, 'Poznan', '', 12, 1, '9u329u39');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (29, 'Poznan', '', 12, 2, '9u329u39');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (30, 'Poznan', '', 12, 21, '9u329u391');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (31, 'Poznan', '', 12, 1, '9u329u391');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (32, 'Poznan', 'Ganta', 981, NULL, '00-000');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (33, 'Tu', 'Być', 12, NULL, '234');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (34, 'Inowrocław', 'Pułkowa', 11, 11, '77-542');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (35, 'Piła', 'Główna', 10, NULL, '10-100');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (36, 'Gniezno', 'Szeroka', 4, NULL, '10-199');
INSERT INTO public.dane_adresowe OVERRIDING SYSTEM VALUE VALUES (37, 'Piła', 'Główna', 23, NULL, '10-100');


--
-- TOC entry 3477 (class 0 OID 41162)
-- Dependencies: 216
-- Data for Name: grupy; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3479 (class 0 OID 41168)
-- Dependencies: 218
-- Data for Name: grupy_zawodnicy; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3480 (class 0 OID 41171)
-- Dependencies: 219
-- Data for Name: kluby; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kluby OVERRIDING SYSTEM VALUE VALUES (1, 'PRZYKLADOWY');
INSERT INTO public.kluby OVERRIDING SYSTEM VALUE VALUES (2, 'PRZYKLADOWY');


--
-- TOC entry 3482 (class 0 OID 41177)
-- Dependencies: 221
-- Data for Name: konkurencje; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.konkurencje OVERRIDING SYSTEM VALUE VALUES (1, 'plywanie');
INSERT INTO public.konkurencje OVERRIDING SYSTEM VALUE VALUES (2, '100 m');
INSERT INTO public.konkurencje OVERRIDING SYSTEM VALUE VALUES (3, '100 k');


--
-- TOC entry 3486 (class 0 OID 41195)
-- Dependencies: 226
-- Data for Name: obiekty; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.obiekty OVERRIDING SYSTEM VALUE VALUES (2, 2, 'Hala 1');
INSERT INTO public.obiekty OVERRIDING SYSTEM VALUE VALUES (3, 2, 'Hala 1');


--
-- TOC entry 3490 (class 0 OID 41211)
-- Dependencies: 231
-- Data for Name: trenerzy; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (7, 'Jan', 'Kowalski', 12212312, 1, 16);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (9, 'Jan', 'Kowalski', 122122312, 1, 16);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (10, 'Jan', 'Kowalski', 1222312, 1, 20);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (11, 'Jan', 'Kowalski', 12272312, 1, 20);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (12, 'Trenr', 'treningowy', 924, 1, 26);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (13, 'Trenr', 'treningowy', 924123, 1, 27);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (14, 'Trenr', 'treningowy', 9241232, 1, 28);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (15, 'Trenr', 'treningowy', 9, 1, 29);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (16, 'Trenr2a', 'treningowy2', 92, 1, 30);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (17, 'Trenr2a', 'treningowy2', 9231, 1, 31);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (18, 'Trenr2a', 'treningowy2', 923112, 1, 30);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (19, 'Jan', 'Kowalski', 1227992, 1, 20);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (20, 'Mam', 'Zadanie', 8277, 1, 33);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (21, 'Andrzej', 'Andrzejewski', 9212012423, 1, 34);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (22, 'Marcin', 'Sportowy', 12345678910, 1, 35);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (23, 'Marek', 'Piotr', 12345678911, 1, 36);
INSERT INTO public.trenerzy OVERRIDING SYSTEM VALUE VALUES (24, 'Marek', 'Piotr', 12345678916, 1, 36);


--
-- TOC entry 3491 (class 0 OID 41220)
-- Dependencies: 233
-- Data for Name: trenerzy_grupy; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3493 (class 0 OID 41224)
-- Dependencies: 235
-- Data for Name: treningi; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.treningi OVERRIDING SYSTEM VALUE VALUES (1, '4434-03-12', 2);
INSERT INTO public.treningi OVERRIDING SYSTEM VALUE VALUES (2, '5678-04-13', 2);


--
-- TOC entry 3495 (class 0 OID 41228)
-- Dependencies: 237
-- Data for Name: treningi_konkurencje; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3484 (class 0 OID 41183)
-- Dependencies: 223
-- Data for Name: wyniki; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.wyniki OVERRIDING SYSTEM VALUE VALUES (5, 9.3300, NULL, 3, 1, 1);
INSERT INTO public.wyniki OVERRIDING SYSTEM VALUE VALUES (6, 1.0000, NULL, 35, 1, 2);
INSERT INTO public.wyniki OVERRIDING SYSTEM VALUE VALUES (7, 2.0000, NULL, 34, 1, 1);


--
-- TOC entry 3485 (class 0 OID 41186)
-- Dependencies: 224
-- Data for Name: zawodnicy; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (1, 'Test', 'Testowski', 'M', 123456789101, 1, 1);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (2, 'Marek', 'Przykladowy', 'M', 11111111111, 1, 3);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (3, 'Marek', 'Przykladowy', 'M', 11111111111, 1, 3);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (4, 'Marek', 'Przykladowy', 'M', 11111111211, 1, 3);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (5, 'Marek', 'Przykladowy', 'M', 11111211211, 1, 3);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (6, 'Marek', 'Przykladowy', 'M', 1111121121, 1, 7);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (10, 'Andrzej', 'Mak', 'M', 123456, 1, 25);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (11, 'Andrzejs', 'Mak', 'M', 1234562, 1, 25);
INSERT INTO public.zawodnicy OVERRIDING SYSTEM VALUE VALUES (12, 'Marcin', 'Sportowy', 'M', 12345678916, 1, 37);


--
-- TOC entry 3487 (class 0 OID 41200)
-- Dependencies: 227
-- Data for Name: zawody; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.zawody OVERRIDING SYSTEM VALUE VALUES (3, '2022-12-12', 2, NULL);
INSERT INTO public.zawody OVERRIDING SYSTEM VALUE VALUES (34, '3223-03-12', 2, 'Zawody');
INSERT INTO public.zawody OVERRIDING SYSTEM VALUE VALUES (35, '2023-01-28', 2, 'Zawody główne');


--
-- TOC entry 3499 (class 0 OID 41238)
-- Dependencies: 242
-- Data for Name: zawody_konkurencje; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.zawody_konkurencje VALUES (34, 1);
INSERT INTO public.zawody_konkurencje VALUES (34, 2);
INSERT INTO public.zawody_konkurencje VALUES (34, 3);
INSERT INTO public.zawody_konkurencje VALUES (35, 2);
INSERT INTO public.zawody_konkurencje VALUES (35, 3);


--
-- TOC entry 3488 (class 0 OID 41203)
-- Dependencies: 228
-- Data for Name: zawody_zawodnicy; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3506 (class 0 OID 0)
-- Dependencies: 215
-- Name: dane_adresowe_id_miejsca_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dane_adresowe_id_miejsca_seq', 37, true);


--
-- TOC entry 3507 (class 0 OID 0)
-- Dependencies: 217
-- Name: grupy_id_grupy_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grupy_id_grupy_seq', 1, false);


--
-- TOC entry 3508 (class 0 OID 0)
-- Dependencies: 220
-- Name: kluby_id_klubu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kluby_id_klubu_seq', 2, true);


--
-- TOC entry 3509 (class 0 OID 0)
-- Dependencies: 222
-- Name: konkurencje_id_konkurencji_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.konkurencje_id_konkurencji_seq', 3, true);


--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 230
-- Name: obiekty_id_obiektu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.obiekty_id_obiektu_seq', 3, true);


--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 234
-- Name: trenerzy_id_trenera_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trenerzy_id_trenera_seq', 24, true);


--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 236
-- Name: treningi_id_treningu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.treningi_id_treningu_seq', 2, true);


--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 238
-- Name: wyniki_id_rekordu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wyniki_id_rekordu_seq', 7, true);


--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 240
-- Name: zawodnicy_id_zawodnika_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zawodnicy_id_zawodnika_seq', 12, true);


--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 241
-- Name: zawody_id_zawodow_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zawody_id_zawodow_seq', 35, true);


--
-- TOC entry 3273 (class 2606 OID 41242)
-- Name: dane_adresowe dane_adresowe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dane_adresowe
    ADD CONSTRAINT dane_adresowe_pkey PRIMARY KEY (id_miejsca);


--
-- TOC entry 3275 (class 2606 OID 41244)
-- Name: grupy grupy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy
    ADD CONSTRAINT grupy_pkey PRIMARY KEY (id_grupy);


--
-- TOC entry 3277 (class 2606 OID 41246)
-- Name: grupy_zawodnicy grupy_zawodnicy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy_zawodnicy
    ADD CONSTRAINT grupy_zawodnicy_pkey PRIMARY KEY (id_grupy, id_zawodnika);


--
-- TOC entry 3279 (class 2606 OID 41248)
-- Name: kluby kluby_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kluby
    ADD CONSTRAINT kluby_pkey PRIMARY KEY (id_klubu);


--
-- TOC entry 3281 (class 2606 OID 41250)
-- Name: konkurencje konkurencje_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.konkurencje
    ADD CONSTRAINT konkurencje_pkey PRIMARY KEY (id_konkurencji);


--
-- TOC entry 3287 (class 2606 OID 41252)
-- Name: obiekty obiekty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.obiekty
    ADD CONSTRAINT obiekty_pkey PRIMARY KEY (id_obiektu);


--
-- TOC entry 3295 (class 2606 OID 41254)
-- Name: trenerzy_grupy trenerzy_grupy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy_grupy
    ADD CONSTRAINT trenerzy_grupy_pkey PRIMARY KEY (id_trenera, id_grupy);


--
-- TOC entry 3293 (class 2606 OID 41256)
-- Name: trenerzy trenerzy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy
    ADD CONSTRAINT trenerzy_pkey PRIMARY KEY (id_trenera);


--
-- TOC entry 3299 (class 2606 OID 41258)
-- Name: treningi_konkurencje treningi_konkurencje_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treningi_konkurencje
    ADD CONSTRAINT treningi_konkurencje_pkey PRIMARY KEY (id_treningu, id_konkurencji);


--
-- TOC entry 3297 (class 2606 OID 41260)
-- Name: treningi treningi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treningi
    ADD CONSTRAINT treningi_pkey PRIMARY KEY (id_treningu);


--
-- TOC entry 3283 (class 2606 OID 41262)
-- Name: wyniki wyniki_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyniki
    ADD CONSTRAINT wyniki_pkey PRIMARY KEY (id_rekordu);


--
-- TOC entry 3285 (class 2606 OID 41264)
-- Name: zawodnicy zawodnicy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawodnicy
    ADD CONSTRAINT zawodnicy_pkey PRIMARY KEY (id_zawodnika);


--
-- TOC entry 3301 (class 2606 OID 41266)
-- Name: zawody_konkurencje zawody_konkurencje_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_konkurencje
    ADD CONSTRAINT zawody_konkurencje_pkey PRIMARY KEY (id_zawodow, id_konkurencji);


--
-- TOC entry 3289 (class 2606 OID 41268)
-- Name: zawody zawody_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody
    ADD CONSTRAINT zawody_pkey PRIMARY KEY (id_zawodow);


--
-- TOC entry 3291 (class 2606 OID 41270)
-- Name: zawody_zawodnicy zawody_zawodnicy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_zawodnicy
    ADD CONSTRAINT zawody_zawodnicy_pkey PRIMARY KEY (id_zawodnika, id_zawodow);


--
-- TOC entry 3310 (class 2606 OID 41271)
-- Name: zawodnicy fk_adres; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawodnicy
    ADD CONSTRAINT fk_adres FOREIGN KEY (dane_adresowe) REFERENCES public.dane_adresowe(id_miejsca);


--
-- TOC entry 3304 (class 2606 OID 41276)
-- Name: grupy_zawodnicy fk_grup; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy_zawodnicy
    ADD CONSTRAINT fk_grup FOREIGN KEY (id_grupy) REFERENCES public.grupy(id_grupy);


--
-- TOC entry 3318 (class 2606 OID 41281)
-- Name: trenerzy_grupy fk_grupy_t; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy_grupy
    ADD CONSTRAINT fk_grupy_t FOREIGN KEY (id_grupy) REFERENCES public.grupy(id_grupy);


--
-- TOC entry 3311 (class 2606 OID 41286)
-- Name: zawodnicy fk_id_klubu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawodnicy
    ADD CONSTRAINT fk_id_klubu FOREIGN KEY (id_klubu) REFERENCES public.kluby(id_klubu);


--
-- TOC entry 3302 (class 2606 OID 41291)
-- Name: grupy fk_id_konkurencji; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy
    ADD CONSTRAINT fk_id_konkurencji FOREIGN KEY (id_konkurencji) REFERENCES public.konkurencje(id_konkurencji);


--
-- TOC entry 3306 (class 2606 OID 41296)
-- Name: wyniki fk_konkurencja_wyn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyniki
    ADD CONSTRAINT fk_konkurencja_wyn FOREIGN KEY (id_konkurencji) REFERENCES public.konkurencje(id_konkurencji);


--
-- TOC entry 3321 (class 2606 OID 41301)
-- Name: treningi_konkurencje fk_konkurencje_t; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treningi_konkurencje
    ADD CONSTRAINT fk_konkurencje_t FOREIGN KEY (id_konkurencji) REFERENCES public.konkurencje(id_konkurencji);


--
-- TOC entry 3323 (class 2606 OID 41306)
-- Name: zawody_konkurencje fk_konkurencje_z; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_konkurencje
    ADD CONSTRAINT fk_konkurencje_z FOREIGN KEY (id_konkurencji) REFERENCES public.konkurencje(id_konkurencji);


--
-- TOC entry 3312 (class 2606 OID 41311)
-- Name: obiekty fk_obiekt_addr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.obiekty
    ADD CONSTRAINT fk_obiekt_addr FOREIGN KEY (dane_adresowe) REFERENCES public.dane_adresowe(id_miejsca);


--
-- TOC entry 3316 (class 2606 OID 41316)
-- Name: trenerzy fk_trener_adr; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy
    ADD CONSTRAINT fk_trener_adr FOREIGN KEY (id_adresu) REFERENCES public.dane_adresowe(id_miejsca);


--
-- TOC entry 3317 (class 2606 OID 41321)
-- Name: trenerzy fk_trener_kl; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy
    ADD CONSTRAINT fk_trener_kl FOREIGN KEY (id_klubu) REFERENCES public.kluby(id_klubu);


--
-- TOC entry 3319 (class 2606 OID 41326)
-- Name: trenerzy_grupy fk_trenerzy_g; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trenerzy_grupy
    ADD CONSTRAINT fk_trenerzy_g FOREIGN KEY (id_trenera) REFERENCES public.trenerzy(id_trenera);


--
-- TOC entry 3322 (class 2606 OID 41331)
-- Name: treningi_konkurencje fk_trening_k; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treningi_konkurencje
    ADD CONSTRAINT fk_trening_k FOREIGN KEY (id_treningu) REFERENCES public.treningi(id_treningu);


--
-- TOC entry 3307 (class 2606 OID 41336)
-- Name: wyniki fk_trening_wyn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyniki
    ADD CONSTRAINT fk_trening_wyn FOREIGN KEY (id_treningu) REFERENCES public.treningi(id_treningu);


--
-- TOC entry 3305 (class 2606 OID 41341)
-- Name: grupy_zawodnicy fk_zawodnik; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy_zawodnicy
    ADD CONSTRAINT fk_zawodnik FOREIGN KEY (id_zawodnika) REFERENCES public.zawodnicy(id_zawodnika);


--
-- TOC entry 3308 (class 2606 OID 41346)
-- Name: wyniki fk_zawodnik_wyn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyniki
    ADD CONSTRAINT fk_zawodnik_wyn FOREIGN KEY (id_zawodnika) REFERENCES public.zawodnicy(id_zawodnika);


--
-- TOC entry 3324 (class 2606 OID 41351)
-- Name: zawody_konkurencje fk_zawody_k; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_konkurencje
    ADD CONSTRAINT fk_zawody_k FOREIGN KEY (id_zawodow) REFERENCES public.zawody(id_zawodow);


--
-- TOC entry 3309 (class 2606 OID 41356)
-- Name: wyniki fk_zawody_wyn; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyniki
    ADD CONSTRAINT fk_zawody_wyn FOREIGN KEY (id_zawodow) REFERENCES public.zawody(id_zawodow);


--
-- TOC entry 3303 (class 2606 OID 57361)
-- Name: grupy grupy_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupy
    ADD CONSTRAINT grupy_fk FOREIGN KEY (id_klubu) REFERENCES public.kluby(id_klubu);


--
-- TOC entry 3320 (class 2606 OID 41361)
-- Name: treningi treningi_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.treningi
    ADD CONSTRAINT treningi_fk FOREIGN KEY (id_obiektu) REFERENCES public.obiekty(id_obiektu);


--
-- TOC entry 3314 (class 2606 OID 41366)
-- Name: zawody_zawodnicy zawodnik_z_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_zawodnicy
    ADD CONSTRAINT zawodnik_z_fk FOREIGN KEY (id_zawodow) REFERENCES public.zawody(id_zawodow);


--
-- TOC entry 3313 (class 2606 OID 41371)
-- Name: zawody zawody_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody
    ADD CONSTRAINT zawody_fk FOREIGN KEY (id_obiektu) REFERENCES public.obiekty(id_obiektu);


--
-- TOC entry 3315 (class 2606 OID 41376)
-- Name: zawody_zawodnicy zawody_z_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zawody_zawodnicy
    ADD CONSTRAINT zawody_z_fk FOREIGN KEY (id_zawodnika) REFERENCES public.zawodnicy(id_zawodnika);


-- Completed on 2023-01-23 20:58:16

--
-- PostgreSQL database dump complete
--

