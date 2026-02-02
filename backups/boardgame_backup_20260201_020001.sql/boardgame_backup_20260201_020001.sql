--
-- PostgreSQL database dump
--

\restrict IYozEfQYmnVccxEkKpj5OjOnYZ1CU7c8ZvFY0zysblV5rHMnTefhmtSXEVFF4qv

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: games; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.games (
    id integer NOT NULL,
    bgg_id integer,
    name character varying(200) NOT NULL,
    description text,
    year_published integer,
    image_url character varying(500),
    thumbnail_url character varying(500),
    min_players integer,
    max_players integer,
    playing_time integer,
    min_age integer,
    complexity double precision,
    categories text,
    mechanics text,
    designers text,
    publishers text,
    bgg_link character varying(500),
    added_at timestamp without time zone
);


ALTER TABLE public.games OWNER TO bguser;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_id_seq OWNER TO bguser;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: login_logs; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.login_logs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    login_time timestamp without time zone NOT NULL,
    ip_address character varying(45),
    user_agent character varying(500)
);


ALTER TABLE public.login_logs OWNER TO bguser;

--
-- Name: login_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.login_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.login_logs_id_seq OWNER TO bguser;

--
-- Name: login_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.login_logs_id_seq OWNED BY public.login_logs.id;


--
-- Name: poll_options; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.poll_options (
    id integer NOT NULL,
    poll_id integer NOT NULL,
    date_time timestamp without time zone NOT NULL,
    description character varying(200)
);


ALTER TABLE public.poll_options OWNER TO bguser;

--
-- Name: poll_options_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.poll_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.poll_options_id_seq OWNER TO bguser;

--
-- Name: poll_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.poll_options_id_seq OWNED BY public.poll_options.id;


--
-- Name: poll_votes; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.poll_votes (
    id integer NOT NULL,
    option_id integer NOT NULL,
    user_id integer NOT NULL,
    value integer NOT NULL,
    voted_at timestamp without time zone,
    comment text
);


ALTER TABLE public.poll_votes OWNER TO bguser;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.poll_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.poll_votes_id_seq OWNER TO bguser;

--
-- Name: poll_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.poll_votes_id_seq OWNED BY public.poll_votes.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.polls (
    id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    creator_id integer NOT NULL,
    is_open boolean,
    created_at timestamp without time zone,
    closed_at timestamp without time zone
);


ALTER TABLE public.polls OWNER TO bguser;

--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.polls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.polls_id_seq OWNER TO bguser;

--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.polls_id_seq OWNED BY public.polls.id;


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.ratings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    game_id integer NOT NULL,
    score integer NOT NULL,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.ratings OWNER TO bguser;

--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.ratings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ratings_id_seq OWNER TO bguser;

--
-- Name: ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.ratings_id_seq OWNED BY public.ratings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: bguser
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(80) NOT NULL,
    password_hash character varying(200) NOT NULL,
    role character varying(20),
    created_at timestamp without time zone,
    last_login timestamp without time zone
);


ALTER TABLE public.users OWNER TO bguser;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: bguser
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO bguser;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bguser
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: login_logs id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.login_logs ALTER COLUMN id SET DEFAULT nextval('public.login_logs_id_seq'::regclass);


--
-- Name: poll_options id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_options ALTER COLUMN id SET DEFAULT nextval('public.poll_options_id_seq'::regclass);


--
-- Name: poll_votes id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_votes ALTER COLUMN id SET DEFAULT nextval('public.poll_votes_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.polls ALTER COLUMN id SET DEFAULT nextval('public.polls_id_seq'::regclass);


--
-- Name: ratings id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.ratings ALTER COLUMN id SET DEFAULT nextval('public.ratings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.games (id, bgg_id, name, description, year_published, image_url, thumbnail_url, min_players, max_players, playing_time, min_age, complexity, categories, mechanics, designers, publishers, bgg_link, added_at) FROM stdin;
1	\N	EXIT- La cabaña abandonada	Todos pretendían usar la cabaña solo como refugio por la noche, pero al amanecer, la puerta está cerrada con una cerradura de combinación, y nadie conoce la combinación de números que permite salir. Las ventanas también tienen barrotes. Un enigmático dial giratorio y un libro misterioso son todo lo que necesitas. ¿Podrás escapar de esta cabaña abandonada?\r\n\r\nEn Exit: The Game – The Abandoned Cabin, los jugadores deben usar su espíritu de equipo, creatividad y capacidad de deducción para descifrar códigos, resolver acertijos, recolectar objetos y ganarse la libertad poco a poco.	2016	https://cf.geekdo-images.com/l35RSCsnvu_br9IqKdsT1g__imagepage@2x/img/IZL8eKWJp8opw66uEY-9rH6TPqo=/fit-in/1800x1200/filters:strip_icc()/pic3716664.jpg	https://cf.geekdo-images.com/su2xs8LCdURypP3EGTXrGQ__imagepage/img/FD5IhRv3X8-ppMxzf6VLiF3hJ5Y=/fit-in/900x600/filters:no_upscale():strip_icc()/pic3722403.jpg	1	6	90	12	2.6	["Deduction", "Puzzle", "Real-time"]	["Cooperative Game"]	["Inka Brand", "Markus Brand"]	["KOSMOS + 18 more"]	https://boardgamegeek.com/boardgame/203420/exit-the-game-the-abandoned-cabin	2026-01-26 14:20:38.296123
2	\N	Just One	¡Just One es un juego de grupo cooperativo en el que todos jugáis juntos para conseguir la mejor puntuación! Tu objetivo en cada ronda es lograr que un jugador, el jugador activo, adivine una palabra misteriosa basándose en las pistas dadas por sus compañeros de equipo.\r\n\r\nCon más detalle, todos los que no son el jugador activo ven la palabra misteriosa y luego cada jugador escribe de forma independiente una pista en su caballete personal. Una vez que todos hayan terminado, se revelarán las pistas unos a otros. Todas las pistas idénticas se eliminan del juego, ¡así que intenta ser original!\r\n\r\nDespués de eliminar las pistas duplicadas, revela las pistas restantes al jugador activo. Si adivinan correctamente la palabra misteriosa, tu equipo gana un punto. Si se niegan a adivinar, no obtendrás la carta actual. Si adivinan mal, no obtienes la carta actual y pierdes uno de los puntos que ya habías obtenido. Por lo tanto, sé original, pero no tanto como para no ayudar al jugador activo a adivinar correctamente.\r\n\r\n¿Podrás lograr una puntuación perfecta adivinando todas las palabras misteriosas?\r\n\r\nJust One: New Version presenta la misma jugabilidad que Just One, pero presenta 550 términos nuevos en sus 110 tarjetas y crayones borrables en lugar de marcadores de borrado en seco.	2025	https://cf.geekdo-images.com/M6eB4FK84KrIiUo6MxmL9A__imagepage/img/ALXx475NIEVAtTqPJKjI62GHRSA=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8933222.jpg	https://cf.geekdo-images.com/mHiOQYYPdSkM2xjEO3CNfA__imagepage/img/-AwUnJxwbzGN1_x_sSxplrvFGMk=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8933221.png	3	7	20	8	1	["Party Game", "Word Game"]	["Communication Limits", "Cooperative Game"]	["Ludovic Roudy", "Bruno Sautter"]	["G\\u00e9m Klub Kft.", "Mald\\u00f3n", "Regatul Jocurilor", "Repos Production"]	https://boardgamegeek.com/boardgame/450619/just-one-new-version	2026-01-26 22:34:21.358423
13	\N	Jamaica	Resumen: Este es un juego de carreras tácticas de temática pirata con interacción entre jugadores y objetivos secundarios (por ejemplo, desviarse en busca de tesoros). El ganador es el jugador que mejor equilibre su posición en la carrera con el éxito en los objetivos secundarios.\r\n\r\nAmbiente: Jamaica, 1675.\r\nTras una larga carrera en la piratería, el capitán Henry Morgan consigue hábilmente ser nombrado gobernador de Jamaica, ¡con la orden explícita de limpiar el Caribe de piratas y bucaneros! En cambio, invita a todos sus antiguos "colegas" a unirse a él en su retiro para disfrutar de los frutos de su saqueo con impunidad. Cada año, en recuerdo de los "buenos tiempos", Morgan organiza el Gran Desafío, una carrera alrededor de la isla, y al final, el capitán con más oro es declarado Gran Ganador.\r\n\r\nObjetivo: La partida termina en el turno en el que al menos el barco de un jugador llega a la meta, completando una vuelta a la isla de Jamaica. En ese momento, los jugadores reciben diferentes cantidades de oro según la distancia a la meta al finalizar la carrera. Este oro se suma al oro que un jugador haya acumulado en el camino al desviarse de la carrera para buscar tesoros valiosos, al robar oro o tesoros de otros jugadores, o simplemente al cargar oro según las cartas que jugó durante la carrera. El jugador con la mayor cantidad de oro acumulado por todos estos medios será declarado ganador.\r\n\r\nJugabilidad: El juego se desarrolla en rondas. Cada jugador siempre tiene una mano de tres cartas y un tablero personal que representa las cinco bodegas de su barco, donde se pueden cargar mercancías durante la partida. En cada ronda, un jugador es designado como "capitán", y el siguiente jugador, en el sentido de las agujas del reloj, será el capitán en la ronda siguiente, y así sucesivamente. El capitán tira dos dados D6 estándar, examina sus cartas y anuncia qué dado corresponde al "día" y cuál a la "noche". A continuación, cada jugador elige simultáneamente una carta de su mano y la coloca boca abajo frente a él. Cada carta tiene dos símbolos: uno a la izquierda (que corresponde al día) y otro a la derecha (que corresponde a la noche). Los símbolos indican el movimiento del barco (hacia adelante o hacia atrás) o la carga de algún tipo de mercancía. Después de que cada jugador haya seleccionado una carta, todas las cartas se revelan simultáneamente y se resuelven en el sentido de las agujas del reloj, empezando por la del capitán. Cuando le toca a un jugador resolver su carta, primero para el símbolo de la izquierda y luego para el de la derecha, cargará una cantidad de mercancías o se moverá una cantidad de espacios igual a la cantidad de puntos que muestre el dado de día o de noche correspondiente a esa ronda. Por lo tanto, la decisión principal que toma cada jugador durante la partida es cuál de sus tres cartas actuales le resultará más útil en un turno determinado, dados los valores de los dados de día y de noche. Finalmente, durante la carrera, cuando un jugador cae en un lugar ya ocupado por otro jugador, se produce una batalla. Las batallas se resuelven principalmente tirando un dado de combate, pero los jugadores pueden mejorar sus posibilidades usando fichas de pólvora de sus bodegas, si cargaron alguna en turnos anteriores. El ganador de una batalla puede robar algunos bienes o tesoros del perdedor.	2007	https://cf.geekdo-images.com/4B6xRfD6LxOyrIzvO_5dCw__imagepage/img/SYhCQIsTysATw2tCVKWH60tAA4g=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8658924.jpg	https://cf.geekdo-images.com/wsxMCW1vbYyPHC99Emf-3w__imagepagezoom/img/xnmtR_uJmsWF4_PM0_kYavBo134=/fit-in/1200x900/filters:no_upscale():strip_icc()/pic275442.jpg	2	6	45	8	1.7	["Nautical", "Pirates", "Racing"]	["Dice Rolling", "Hand Management", "Hidden Victory Points", "Race", "Roll / Spin and Move", "Simultaneous Action Selection", "Take That", "Track Movement", "Turn Order: Progressive", "Victory Points as a Resource"]	["Malcolm Braff", "Bruno Cathala", "S\\u00e9bastien Pauchon"]	["GameWorks S\\u00e0RL", "Space Cowboys + 6 more"]	https://boardgamegeek.com/boardgame/28023/jamaica	2026-01-27 05:13:29.764642
3	\N	Código secreto		2015	https://cf.geekdo-images.com/F_KDEu0GjdClml8N7c8Imw__imagepage@2x/img/q-SpUn6DSRKZp9RGsk6V8X0Fi2c=/fit-in/1800x1200/filters:strip_icc()/pic2582929.jpg	https://cf.geekdo-images.com/ghh_zQBKXUOQsHvL1ngZMg__imagepagezoom/img/Im-CRTg5paMxjuCQ0ONwXdcVgTQ=/fit-in/1200x900/filters:no_upscale():strip_icc()/pic2598922.jpg	2	8	15	10	1.3	["Card Game", "Deduction", "Party Game", "Spies / Secret Agents", "Word Game"]	["Communication Limits", "Deduction", "Memory", "Race", "Team-Based Game"]	["Vlaada Chv\\u00e1til"]	["Czech Games Edition + 37 more"]	https://boardgamegeek.com/boardgame/178900/codenames	2026-01-26 22:41:06.120484
4	\N	Little Secret	Pequeño Secreto es un juego en el que debes descubrir intrusos. Para verificar la identidad de los participantes en una reunión de una organización secreta, necesitas saber la palabra secreta, y solo los discípulos tienen la palabra correcta. Entre ustedes se esconden infiltrados y un periodista solitario que quiere pasar desapercibido. ¿Podrán los discípulos desenmascararlos a todos?\r\n\r\nPara jugar, cada jugador recibe una tarjeta con palabras secretas que definen su rol en cada ronda. Tu rol puede cambiar de una ronda a otra. Si no tienes una palabra secreta, eres periodista; si la tienes, eres discípulo o infiltrado, pero no sabes cuál.\r\n\r\nPor turnos, cada jugador da una pista para su palabra secreta; el objetivo es descubrir quién tiene una palabra diferente a la suya (o ninguna palabra en el caso del periodista). Todos los jugadores debaten y votan a quién eliminar, tras lo cual el juego continúa con los jugadores restantes dando una nueva pista hasta que solo queden discípulos o solo queden dos jugadores. Los jugadores que no hayan sido eliminados ganan puntos.\r\n\r\nLa edición estadounidense de Little Secret de Exploding Kittens cambia los grupos a gatitos buenos, gatitos confundidos y un cachorro espía, pero por lo demás el juego sigue siendo el mismo: cada carta de jugador tiene suficientes pistas para jugar 21 juegos sin necesidad de barajar ni volver a repartir.	2022	https://cf.geekdo-images.com/DH3AQzxF2xzPV66G6fWMkA__imagepage/img/tI1TYdmgr4Foxz371fMFYv4K1tg=/fit-in/900x600/filters:no_upscale():strip_icc()/pic9105159.jpg	https://cf.geekdo-images.com/7iLDO1N1gMmldqsKjpmC4w__imagepage/img/3OWABzM15f19rlwDkYu8zztCWX0=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6972554.png	4	8	30	10	1	["Bluffing", "Children's Game", "Deduction", "Humor", "Party Game", "Word Game"]	["Deduction", "Hidden Roles"]	["Ben (II)", "JB"]	["ATM Gaming", "Exploding Kittens + 1 more"]	https://boardgamegeek.com/boardgame/367367/little-secret	2026-01-27 03:27:40.92735
5	\N	Splendor	Splendor es un juego de coleccionar fichas y desarrollar cartas. Los jugadores son comerciantes del Renacimiento que intentan comprar minas de gemas, medios de transporte y tiendas para obtener la mayor cantidad de puntos de prestigio. Si tienes suficiente dinero, incluso podrías recibir la visita de un noble en algún momento, lo que, por supuesto, aumentará aún más tu prestigio.\r\n\r\nEn tu turno, puedes (1) coleccionar fichas (gemas), (2) comprar y construir una carta, o (3) reservar una carta. Si coleccionas fichas, tomas tres tipos diferentes de fichas o dos fichas del mismo tipo. Si compras una carta, pagas su precio en fichas y la añades a tu área de juego. Para reservar una carta —para asegurarte de obtenerla, o, por qué no, que tus oponentes no la obtengan— la colocas boca abajo frente a ti para construirla más tarde; esto te cuesta una ronda, pero también obtienes oro en forma de ficha comodín, que puedes usar como cualquier gema.\r\n\r\nTodas las cartas que compras aumentan tu riqueza, ya que te otorgan una bonificación permanente de gemas para compras posteriores; algunas cartas también te otorgan puntos de prestigio. Para ganar la partida, debes alcanzar 15 puntos de prestigio antes que tus oponentes.	2014	https://cf.geekdo-images.com/wnpd_BE4_kByqaGGltw-Sg__imagepage/img/wbcWieHupc4pjPrldy-l1Ta5Az4=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8284792.jpg	https://cf.geekdo-images.com/vNFe4JkhKAERzi4T0Ntwpw__imagepage/img/JXnPzdgTeDkRrxESA86gnCw4Zws=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8234167.png	2	4	30	10	1.8	["Card Game", "Economic", "Renaissance"]	["Contracts", "Open Drafting", "Race", "Set Collection"]	["Marc Andr\\u00e9"]	["Space Cowboys + 26 more"]	https://boardgamegeek.com/boardgame/148228/splendor	2026-01-27 03:34:22.513417
11	\N	Cat in the Box	Cat in the Box: Edición Deluxe es el juego de cartas de bazas cuánticas por excelencia para 2-5 gatos geniales, ¡donde el color de tu carta no se define hasta que la juegas! Plantea cuántas bazas ganarás y registra tu apuesta. Coloca fichas en el tablero de investigación de la comunidad mientras juegas tu mano y conecta grandes grupos de fichas para sumar aún más puntos. Planifica tus bazas con cuidado, ya que no puedes reclamar el color de una carta con el mismo número que ya se ha declarado. ¡Hacerlo sería catastrófico, ya que acabarías de crear una paradoja!\r\nCaracterísticas de la nueva Edición Deluxe:\r\n\r\nPara 2-5 jugadores\r\nFichas de plástico de alta calidad estilo Geekbits\r\nTableros de jugador empotrados\r\nTablero de investigación central empotrado\r\nLibreta de puntuación\r\n¡Y un inserto de plástico personalizado para mantener Cat in the Box: Edición Deluxe ordenado!	2022	https://cf.geekdo-images.com/Ym7dwTQRGvkJlD4OtNlclQ__imagepage/img/Rvfb30_fN2rx4NNR_bA7dr2R9rE=/fit-in/900x600/filters:no_upscale():strip_icc()/pic7880178.jpg	https://cf.geekdo-images.com/S2RkEpC_8oENJSpS7K4-Ig__imagepage/img/grvRsg_eneMsnhU3fepn3r1Inwc=/fit-in/900x600/filters:no_upscale():strip_icc()/pic7945652.jpg	2	5	30	13	2.3	["Animals", "Card Game"]	["Enclosure", "Hand Management", "Predictive Bid", "Trick-taking"]	["Muneyuki Yokouchi (\\u6a2a\\u5185\\u5b97\\u5e78)"]	["Hobby Japan + 17 more"]	https://boardgamegeek.com/boardgame/345972/cat-in-the-box-deluxe-edition	2026-01-27 04:23:41.353812
12	\N	Perudo	Dados Mentirosos, también conocido como Bluff, Perudo o Dudo, es un juego de dados sudamericano en el que cada jugador recibe cinco dados y un cubilete para lanzarlos y esconderlos. Los jugadores hacen declaraciones sucesivamente más altas sobre los resultados de todos los dados restantes en el juego, por ejemplo, "hay diez seises". Sin embargo, alguien siempre puede impugnar la apuesta. En ese caso, se revelan todos los dados y el que postor o quien canta pierde dados, dependiendo de quién acertó. El último jugador con dados es el ganador.\r\n\r\nComo juego de dados de dominio público, existen varias variantes o juegos similares llamados Dados Mentirosos. Este incluye uno que se juega a menudo con Dados de Póker, y se diferencia de las versiones comerciales en que los jugadores solo declaran el valor de su propia mano (en lugar de que todos los dados estén en juego), utilizando los valores de las manos de póker.	2000	https://cf.geekdo-images.com/4ZVNJvJvjTAvHzGD4YojYQ__imagepage/img/stfJj_u1_wMExdZc_U7Lpg365fM=/fit-in/900x600/filters:no_upscale():strip_icc()/pic97791.jpg	https://cf.geekdo-images.com/di4PqcbKY3xcSnqiqFO_ow__imagepage/img/bev9GnPjbf4BePjXCVfErOD9Qk8=/fit-in/900x600/filters:no_upscale():strip_icc()/pic415706.jpg	2	10	20	8	1.3	["Bluffing", "Children's Game", "Dice", "Movies / TV / Radio theme", "Party Game"]	["Betting and Bluffing", "Dice Rolling", "Player Elimination"]	["Richard Borg"]	["(Public Domain)", "Endless Games (I)", "F.X. Schmid", "Milton Bradley + 49 more"]	https://boardgamegeek.com/boardgame/45/perudo	2026-01-27 04:27:21.394989
6	\N	Ready Set Bet	En Ready Set Bet, tú y tus amigos se dirigen a las carreras para disfrutar de un día de animar, abuchear y apostar por sus caballos favoritos, cuyo destino depende de cada tirada de dados.\r\n\r\nReady Set Bet se juega en cuatro rondas. Cada ronda consiste en una carrera seguida de la resolución de la apuesta. Durante cada carrera, los jugadores colocan libremente sus fichas de apuesta en el tablero mientras la carrera está en marcha. Después de cada carrera, los jugadores ganan o pierden dinero por cada ficha de apuesta realizada y reciben una Tarjeta VIP del Club para ayudarles a ganar más dinero en las siguientes carreras. ¡Después de cuatro rondas, el jugador con más dinero gana!	2022	https://cf.geekdo-images.com/jNGnAoDu23UwvjS-4r9-0Q__imagepage/img/Goka0siV2S7C1FfhwTQVe3ABvqo=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6674751.jpg	https://cf.geekdo-images.com/4ZCV2o_OiGha0bknXDTfdA__imagepage/img/4ZA-y1AawUCCHdmIRp35OjaN91o=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6678381.jpg	2	9	60	10	1.3	["Animals", "Party Game", "Racing", "Real-time", "Sports"]	["Betting and Bluffing", "Dice Rolling", "Real-Time", "Track Movement"]	["John D. Clair"]	["Alderac Entertainment Group + 12 more"]	https://boardgamegeek.com/boardgame/351040/ready-set-bet	2026-01-27 03:42:16.015981
7	\N	Las Vegas	El desarrollador Stefan Brück de alea describe Las Vegas como "un juego fácil de dados, divertido y de suerte, con mucha interacción y alegría por el mal ajeno". ¿A quién no le gusta la alegría por el mal ajeno? (Bueno, aparte de los que sufren, supongo...)\r\n\r\nMás detalladamente, Las Vegas incluye seis tapetes de casino de cartón, uno para cada cara de un dado normal de seis caras. En cada tapete, los jugadores roban cartas de dinero hasta que aparezcan al menos 50.000 $, pero la cantidad puede ser mucho mayor, lo que hace que el casino sea más atractivo.\r\n\r\nCada jugador tiene ocho dados de un color diferente, que tira por turnos. Al tirar los dados, puede elegir colocarlos en las cartas de casino correspondientes; por ejemplo, un dado con un 1 se colocará en el tapete de casino marcado con "1". Debe colocar todos los dados de un número en un casino en su turno. Todos los jugadores se turnan para hacer esto hasta que se hayan usado todos los dados. Finalmente, el jugador con más dados en cada carta de casino se lleva el dinero asociado a ella. En caso de empate, el siguiente jugador no empatado toma la carta de mayor valor en ese casino.\r\n	2012	https://cf.geekdo-images.com/9Wf3oYlX5RzU9ppkVeFfkw__imagepage/img/AG0Gqfgfs1Rb1ilPIAvUD8Pqd50=/fit-in/900x600/filters:no_upscale():strip_icc()/pic1814455.png	https://cf.geekdo-images.com/MsyGsou8uA7QdeN3AO0T3w__imagepage/img/8aN_pIs8p3dsYJTj32jxPyX3SPg=/fit-in/900x600/filters:no_upscale():strip_icc()/pic1467067.jpg	2	5	30	8	1.2	["Dice"]	["Area Majority / Influence", "Dice Rolling"]	["R\\u00fcdiger Dorn"]	["alea", "Ravensburger + 4 more"]	https://boardgamegeek.com/boardgame/117959/las-vegas	2026-01-27 03:50:13.706819
8	\N	Wavelength	Longitud de Onda es un juego social de adivinanzas en el que dos equipos compiten para leerse la mente. Los equipos, por turnos, giran un dial hasta donde creen que se encuentra una diana oculta en un espectro. Uno de los jugadores de su equipo —el Psíquico— sabe exactamente dónde está la diana y roba una carta con un par de símbolos binarios (como: Trabajo - Carrera, Áspero - Suave, Fantasía - Ciencia Ficción, Canción Triste - Canción Alegre, etc.). El Psíquico debe proporcionar una pista que *conceptualmente* indique dónde se encuentra la diana entre esos dos símbolos binarios.\r\n\r\nPor ejemplo, si la carta de esta ronda es CALIENTE-FRÍO y la diana está ligeramente en el lado "frío" del centro, el Psíquico debe dar una pista en algún lugar de esa región. ¿Quizás "ensalada"?\r\n\r\nDespués de que el Psíquico dé su pista, su equipo discute dónde creen que está la diana y gira el dial hasta esa ubicación en ese espectro. ¡Cuanto más cerca del centro de la diana adivine el equipo, más puntos obtendrá!	2019	https://cf.geekdo-images.com/bbn2IXHVABw1gKovTHcpIQ__imagepage/img/DW8wnMa0sjXC0YViWj1Gey5DU2Q=/fit-in/900x600/filters:no_upscale():strip_icc()/pic5140756.jpg	https://cf.geekdo-images.com/z4fbPdmJg_5yphJEvql4ZA__imagepage/img/V_3GqWteqDmL8C3ZLRoDXbJKKRo=/fit-in/900x600/filters:no_upscale():strip_icc()/pic4552862.png	2	12	30	14	1.1	["Party Game"]	["Race", "Targeted Clues", "Team-Based Game"]	["Alex Hague", "Justin Vickers", "Wolfgang Warsch"]	["Palm Court + 15 more"]	https://boardgamegeek.com/boardgame/262543/wavelength	2026-01-27 03:57:16.654945
9	\N	Flip 7	Da la vuelta a las cartas una a una sin voltear el mismo número dos veces.\r\n\r\n¿Suena fácil? ¡Piénsalo de nuevo! Esta no es una baraja cualquiera… En Flip 7 solo hay un 1, dos 2, tres 3, etc., además de un montón de cartas especiales que pueden darte puntos extra, darte una segunda oportunidad o dejarte paralizado a ti o a tus oponentes.\r\n\r\n¿Eres de los que van a lo seguro y acumulan puntos antes de pasarse, o vas a arriesgarlo todo e ir a por los puntos extra volteando siete cartas seguidas? ¡Prueba tu suerte y estrategia en este adictivo juego de cartas que seguro será el mejor que hayas jugado!	2024	https://cf.geekdo-images.com/2pTWECzcosvP8iulopECKA__imagepage/img/lmOfS2BLT6JBgqWlwR0iCl2UuMo=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8842060.jpg	https://cf.geekdo-images.com/Z6AqTlg33K0c6Ub3f_vNCw__imagepage/img/LAqdL_yAvnP10X9KBdXNenwNytQ=/fit-in/900x600/filters:no_upscale():strip_icc()/pic9301062.jpg	3	18	20	8	1	["Card Game", "Number", "Party Game"]	["Interrupts", "Push Your Luck", "Score-and-Reset Game", "Take That"]	["Eric Olsen"]	["The Op Games + 15 more"]	https://boardgamegeek.com/boardgame/420087/flip-7	2026-01-27 04:07:19.273579
10	\N	Krakel Orakel		2024	https://cf.geekdo-images.com/1UOISBJ6fl4NoQ8VoX9M4w__imagepage/img/4PIaSVdcB4B_Jf5TSquVBILAGJA=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8999866.jpg	https://cf.geekdo-images.com/NcsFCU0vJ1kYj2FxluJDcg__imagepage/img/siqSYCOPLU6676QBR1ktATQCfkw=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8951318.png	2	8	30	10	1.1	["Party Game"]	["Cooperative Game Drawing"]	["Die 7 Bazis"]	["frechverlag + 2 more"]	https://boardgamegeek.com/boardgame/419639/krakel-orakel	2026-01-27 04:14:49.986784
14	\N	Junk Art	En Junk Art, los jugadores reciben chatarra con la que deben crear arte. De ahí su nombre.\r\n\r\nJunk Art ofrece más de diez modos de juego, junto con más de sesenta grandes y coloridos componentes de madera o plástico. En una versión del juego, los jugadores apilan todas las piezas de madera o plástico en el centro de la mesa y reciben varias cartas, cada una representando una de estas piezas. En su turno, un jugador entrega dos cartas de su mano a su vecino de la izquierda. Este vecino toma una carta en la mano, luego toma la parte que se muestra en la otra carta y la coloca sobre su base o sobre otras piezas que ya haya colocado. Si algo se cae, se queda en la mesa y el jugador continúa construyendo sobre lo que quede en pie. Una vez que los jugadores terminan de jugar cartas, gana quien tenga la obra de arte más alta.	2016	https://cf.geekdo-images.com/PHzKDHtzgab2EJIp6Q5n1A__imagepage/img/uTkHhgsFfSB49gxzUBCAelRhZwY=/fit-in/900x600/filters:no_upscale():strip_icc()/pic3164034.jpg	https://cf.geekdo-images.com/5VDnpX_3ykgCjTJSmHdfCA__imagepage/img/LT-8dXobgvDd5KxqfGKfcGwMHq8=/fit-in/900x600/filters:no_upscale():strip_icc()/pic2884509.jpg	2	6	30	8	1.2	["Action / Dexterity", "Party Game"]	["Bingo", "Hand Management I Cut", "You Choose", "Score-and-Reset Game", "Stacking and Balancing"]	["Jay Cormier", "Sen-Foong Lim"]	["Pretzel Games + 5 more"]	https://boardgamegeek.com/boardgame/193042/junk-art	2026-01-27 05:19:14.625821
17	\N	Super Mega Lucky Box	Tu objetivo en Super Mega Lucky Box es conseguir la mayor cantidad de puntos posible, y lo lograrás principalmente tachando los nueve números impresos en una cuadrícula de 3x3 en las cartas que tienes delante.\r\n\r\nDurante cada una de las cuatro rondas, barajas 18 cartas (numeradas del 1 al 9 dos veces) y luego revelas nueve de ellas una a una. Por cada número revelado, tachas un número coincidente en una de tus cartas, y comienzas el juego eligiendo tres de cinco cartas. Cada vez que completas una fila o columna, recibes la bonificación impresa junto a ella:\r\n\r\nUn rayo, que puedes usar para aumentar o disminuir el número que estás tachando en cada turno. Por ejemplo, si usas tres rayos, puedes convertir un 7 en un 4 o un 1 (porque los números se "enrollan").\r\nUna luna: el jugador con más lunas gana 6 puntos al final de la partida, mientras que el jugador con menos pierde 6 puntos (excepto en partidas de dos jugadores).\r\nUna estrella: ganas 1, 4 o 9 puntos por conseguir 1, 2 o 3 estrellas en una sola ronda.\r\nUn número: tachas inmediatamente en una de tus cartas; si al hacerlo completas otra fila o columna, ¡también obtienes esa bonificación!\r\nUn signo de interrogación: tachas cualquier número.\r\n\r\nAl final de una ronda, ganas puntos por cada carta que hayas marcado completamente; los puntos disminuyen en cada ronda de 15 en la primera ronda a 8 en la cuarta. Cada jugador roba tres cartas nuevas y se queda con una.\r\n\r\nDespués de cuatro rondas, obtienes 1 punto por cada dos espacios marcados con una X en las cartas sin terminar, luego sumas tus puntos de las cartas completadas, estrellas y lunas para ver quién tiene el puntaje más alto y gana.	2021	https://cf.geekdo-images.com/Uw4Q5VAEo2L2pqEFztdT0w__imagepage/img/aW-LiEawolaCkDN_WYSxpbqadTA=/fit-in/900x600/filters:no_upscale():strip_icc()/pic8120458.jpg	https://cf.geekdo-images.com/rAix9ZhztUIUzxDKoFTqHg__imagepage/img/dl0QlGnBrPRXr9LxSlBKfGrG_pE=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6254863.png	1	6	20	8	1.3	["Number"]	["Bingo", "Paper-and-Pencil", "Pattern Building"]	["Phil Walker-Harding"]	["Gamewright + 9 more"]	https://boardgamegeek.com/boardgame/341530/super-mega-lucky-box	2026-01-27 13:55:29.671039
19	\N	Sherlock: La llamada final	En cada caso Q, se intenta resolver un misterio con 32 pistas. Los jugadores revelan una pista a la vez hasta que se hayan revelado o descartado todas las cartas. Durante su turno, cada jugador debe realizar una de las siguientes acciones:\r\n\r\nA) Revelar información:\r\nElige una carta de tu mano y colócala sobre la mesa para que todos los jugadores puedan leer o ver la información completa.\r\nRecomendamos leer en voz alta toda la información compartida al colocarla sobre la mesa. Si juegas una pista irrelevante para el caso, perderás puntos al final de la partida, ¡pero ten cuidado! Algunas pistas son vitales para resolver el caso.\r\n\r\nPuedes compartir y exponer tus teorías en cualquier momento y hablar sobre las cartas que tienes en la mano, pero no puedes mostrárselas a los demás jugadores y solo puedes leer en voz alta las palabras escritas en negrita o el texto enmarcado dentro de una imagen.\r\n\r\nAl final de la partida, cuando se hayan revelado o descartado todas las cartas de pista, debes revisar cuidadosamente toda la información disponible y elaborar una teoría de lo sucedido, trabajando en conjunto. A continuación, abre el cuestionario y responde a todas las preguntas. Durante esta fase del juego, puedes hablar libremente sobre tus cartas descartadas o sobre la información que recuerdas de ellas. Cada respuesta correcta suma dos puntos.\r\n\r\nEn Q: Last Call, un hombre sufre un infarto durante un vuelo.\r\n\r\nComandante: Comandante del vuelo TJ1309 solicita prioridad para aterrizar.\r\nCT: Torre de control de South Indian Lake. Solicitud recibida. ¿Cuál es la emergencia?\r\nComandante: Uno de nuestros pasajeros sufrió un infarto 7 horas y 30 minutos después del despegue. Su acompañante sufrió una crisis de ansiedad.\r\nCT: Recibido, TC1309, iniciaremos el protocolo estándar de RCP. Enviaremos un equipo de reanimación, un médico forense y un equipo de investigación. Facilitaremos el traslado y la custodia de los pasajeros.\r\nComandante: Afirmativo, CT. Solicito vectores lo antes posible.\r\nCT: CT al vuelo TJ1309, tiene suerte. La pista está despejada ahora mismo. Autorizado a South Indian Lake, transpondedor de seis mil pies dos-uno-cinco-siete.\r\nComandante: Vuelo TJ1309 a South Indian Lake. Transpondedor de seis mil pies dos-uno-cinco-siete. Gracias.	2018	https://cf.geekdo-images.com/FiFcvv9OpDYWz9XBqyurtA__imagepage/img/utgXMj2A0Q9kAXQEp1zHzGZ3u8A=/fit-in/900x600/filters:no_upscale():strip_icc()/pic5124439.jpg	https://cf.geekdo-images.com/WxkdvKBzRUe_uopUNnUDrA__imagepage/img/aqWfdBk31sTIBm6n8b6t096zUMA=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6407474.jpg	1	8	50	10	1.6	["Card Game", "Deduction", "Murder / Mystery"]	["Communication Limits", "Cooperative Game", "Hand Management", "Memory"]	["Mart\\u00ed Lucas Feliu", "Josep Izquierdo S\\u00e1nchez"]	["GDM Games + 14 more"]	https://boardgamegeek.com/boardgame/250780/sherlock-last-call	2026-01-27 17:23:40.041277
20	\N	Sherlock: Paradero desconocido	Nuria llega a casa y encuentra todo revuelto, y su marido ha desaparecido. ¿Qué ha pasado? ¿Por qué? Sigue las pistas con tu equipo de investigadores para responder a estas y otras preguntas. ¿Resolverás el misterio de la desaparición? (de la contraportada del juego)\r\n\r\nEn cada caso Q, intentas resolver un misterio con 32 pistas. Los jugadores revelan una pista a la vez hasta que se hayan revelado o descartado todas las cartas. Durante tu turno, cada jugador debe realizar una de las siguientes acciones:\r\n\r\nA) Revelar información:\r\nElige una carta de tu mano y colócala sobre la mesa para que todos los jugadores puedan leer o ver la información completa.\r\nTe recomendamos leer en voz alta toda la información compartida al colocarla sobre la mesa. Si juegas una pista irrelevante para el caso, perderás puntos al final de la partida, ¡pero ten cuidado! Algunas pistas son vitales para resolver el caso.\r\n\r\nPuedes compartir y exponer tus teorías en cualquier momento y hablar sobre las cartas que tienes en la mano, pero no puedes mostrárselas a los demás jugadores y solo puedes leer en voz alta las palabras escritas en negrita o el texto enmarcado en una imagen:\r\n\r\nAl final de la partida, cuando se hayan revelado o descartado todas las cartas de pista, debes revisar cuidadosamente toda la información disponible y elaborar una teoría de lo sucedido, trabajando en conjunto. Luego, abre el cuestionario y responde a todas las preguntas. Durante esta fase del juego, puedes hablar libremente sobre tus cartas descartadas o la información que recuerdes de ellas. Cada respuesta correcta sumará dos puntos.	2018	https://cf.geekdo-images.com/ZXKn2Nr1P1iYxlizUzGbxA__imagepage/img/P0y0IFdWkejJcJfMEtfIIrGwsjE=/fit-in/900x600/filters:no_upscale():strip_icc()/pic5736229.png	https://cf.geekdo-images.com/fs-SWTHSQ-1d3g0fImnYLw__imagepage/img/ULsmh7_74dGhNGkUhASaRk0vZgs=/fit-in/900x600/filters:no_upscale():strip_icc()/pic6151073.jpg	1	8	60	8	1.8	["Card Game", "Deduction", "Murder / Mystery"]	["Communication Limits", "Cooperative Game", "Hand Management", "Memory"]	["Mart\\u00ed Lucas Feliu", "Josep Izquierdo S\\u00e1nchez"]	["GDM Games + 10 more"]	https://boardgamegeek.com/boardgame/266446/the-sherlock-files-demo-deck-whereabouts-unknown	2026-01-27 17:37:45.750984
18	\N	Scrabble	En este clásico juego de palabras, los jugadores usan sus siete fichas de letras extraídas para formar palabras en el tablero. Cada palabra colocada otorga puntos según la similitud de las letras utilizadas, y ciertas casillas del tablero otorgan bonificaciones. Sin embargo, una palabra solo se puede jugar si usa al menos una ficha ya jugada o se suma a una palabra ya jugada. Esto conlleva un juego ligeramente táctico, ya que se rechazan palabras potenciales porque darían al oponente demasiado acceso a las mejores casillas de bonificación.\r\n\r\nSkip-a-cross fue licenciado por Selchow & Righter y fabricado por Cadaco. Ambos juegos tienen reglas idénticas, pero Skip-a-cross tiene fichas y soportes de cartón en lugar de madera. El juego también se publicó porque no se fabricaron suficientes juegos de Scrabble para satisfacer la demanda.	1948	https://cf.geekdo-images.com/_PXgCbrrDx66VVXaC0JRlg__imagepage/img/k5bUm9o3a_hg_aSEgOcfKIunZqE=/fit-in/900x600/filters:no_upscale():strip_icc()/pic280679.jpg	https://cf.geekdo-images.com/f_wnXZy6Hq9KQ3yPcgKrDA__imagepage/img/4FAU2XtA9XVLN1kCIxfje5r1f8w=/fit-in/900x600/filters:no_upscale():strip_icc()/pic7938294.jpg	2	4	90	10	2.1	["Word Game"]	["End Game Bonuses", "Hand Management", "Spelling", "Square Grid", "Tile Placement"]	["Alfred Mosher Butts"]	["(Unknown)", "Alga", "Barnes & Noble", "Borras Plana S.A. + 55 more"]	https://boardgamegeek.com/boardgame/320/scrabble	2026-01-27 17:15:40.77002
22	\N	Inca Treasure	Diamant, también publicado como Incan Gold, es un juego rápido y divertido que te obliga a probar suerte. Los jugadores se aventuran por pozos de minas o exploran senderos en la selva desvelando cartas de un mazo y compartiendo equitativamente las gemas que encuentran por el camino. Las gemas sobrantes se colocan sobre la carta. Antes de que se revele la siguiente carta, tienes la oportunidad de abandonar la mina y guardar tus posesiones, incluyendo las gemas que consigas al salir.\r\n\r\n¿Por qué irte? Porque el mazo también contiene peligros: escorpiones, serpientes, gas venenoso, explosiones y desprendimientos de rocas. Cuando un peligro en particular se revela por segunda vez (por ejemplo, un segundo escorpión), cualquiera que siga en el pozo o en el camino debe soltar todas las gemas que haya recogido en esa ronda y ponerse a salvo. El truco está en que, a medida que más jugadores se van en cada turno, tu parte del pastel crece, lo que quizás te inspire a explorar más a fondo, pero con el riesgo de quedarte sin nada.\r\n\r\nTodas las ediciones de Incan Gold y posteriores de Diamant incluyen cinco cartas de artefacto que se barajan en el mazo de gemas y cartas de peligro, una por ronda o todas a la vez. Cuando se revela una carta de artefacto, nadie puede tomarla y se coloca en el camino. Si solo un jugador abandona el camino al final de un turno, no solo recoge todas las gemas que quedan en el camino, sino también el artefacto, lo que otorga puntos extra al final de la partida.	2005	https://cf.geekdo-images.com/UdEkRCFvqpFdkYXGe-4V6w__imagepage/img/dEK0VRJop2crgQKz14oE-U0SO2o=/fit-in/900x600/filters:no_upscale():strip_icc()/pic222498.jpg	https://cf.geekdo-images.com/sCZv5MDfImdiUwmyg4rIfg__imagepage/img/CwhcaYj2F0kuC7soVosqx_gNDkA=/fit-in/900x600/filters:no_upscale():strip_icc()/pic440071.jpg	2	8	30	8	1.1	["Bluffing", "Exploration"]	["Move Through Deck", "Push Your Luck", "Simultaneous Action Selection"]	["Bruno Faidutti", "Alan R. Moon"]	["Eagle-Gryphon Games", "IELLO", "Schmidt Spiele", "Sunriver Games + 20 more"]	https://boardgamegeek.com/boardgame/15512/diamant	2026-01-27 19:24:21.003932
\.


--
-- Data for Name: login_logs; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.login_logs (id, user_id, login_time, ip_address, user_agent) FROM stdin;
1	1	2026-01-26 13:33:09.936697	192.168.1.30	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
2	3	2026-01-26 13:40:13.826102	192.168.1.30	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
3	1	2026-01-26 22:08:44.861835	172.23.0.1	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
4	1	2026-01-27 01:26:13.708908	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1
5	1	2026-01-27 02:10:50.716947	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
6	1	2026-01-27 03:15:45.570501	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
7	3	2026-01-27 03:18:16.963774	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
8	4	2026-01-27 19:02:08.121969	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
9	3	2026-01-27 22:15:05.368713	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
10	12	2026-01-27 22:32:30.037026	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1
11	15	2026-01-27 22:33:34.178083	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Brave/1 Mobile/15E148 Safari/604.1
12	3	2026-01-27 22:37:44.775067	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
13	2	2026-01-27 22:50:32.455992	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
14	10	2026-01-27 23:15:47.10389	172.23.0.4	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
15	4	2026-01-28 00:49:41.493941	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
16	16	2026-01-28 00:53:06.644808	172.23.0.4	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
17	14	2026-01-28 01:02:05.50552	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
18	4	2026-01-28 01:39:08.184238	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
19	2	2026-01-28 01:49:33.231806	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
20	3	2026-01-28 01:55:25.586489	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
21	3	2026-01-28 04:49:34.403398	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
22	3	2026-01-28 05:00:36.709574	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
23	3	2026-01-28 05:25:09.210231	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
24	2	2026-01-28 05:25:43.883198	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
25	3	2026-01-28 05:34:29.373353	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
26	4	2026-01-28 13:49:20.573886	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
27	5	2026-01-28 13:52:02.116644	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
28	7	2026-01-28 13:53:15.138289	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
29	7	2026-01-28 13:54:04.248483	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
30	7	2026-01-28 13:54:10.870388	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
31	2	2026-01-28 13:54:57.02393	172.23.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
32	3	2026-01-28 14:03:10.032404	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
33	2	2026-01-28 14:06:29.877616	172.23.0.3	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
34	7	2026-01-28 14:17:35.936092	172.23.0.3	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
35	5	2026-01-28 14:26:13.841197	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
36	3	2026-01-28 14:29:54.517478	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
37	3	2026-01-28 14:32:34.143372	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1
38	3	2026-01-28 14:45:47.678895	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
39	3	2026-01-28 14:48:21.069153	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
40	13	2026-01-28 14:49:08.806968	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
41	3	2026-01-28 14:53:55.822127	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
42	20	2026-01-28 14:54:34.901617	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
43	20	2026-01-28 14:55:17.165273	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.2 Mobile/15E148 Safari/604.1
44	3	2026-01-28 18:18:10.325332	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
45	3	2026-01-28 18:22:03.595193	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
46	13	2026-01-28 22:44:50.705269	172.23.0.3	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
47	3	2026-01-29 00:54:11.378555	172.23.0.3	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
48	3	2026-01-29 01:45:13.41873	172.23.0.3	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
49	3	2026-01-29 23:59:04.386593	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
50	4	2026-01-30 02:31:13.230218	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
51	3	2026-01-30 04:02:39.69707	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
52	2	2026-01-30 04:08:58.818077	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
53	4	2026-01-30 04:09:28.766155	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
54	3	2026-01-30 04:23:19.369423	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
55	4	2026-01-30 04:49:07.604363	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
56	3	2026-01-30 04:57:02.219678	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
57	3	2026-01-30 19:53:19.577261	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
58	4	2026-01-30 19:56:29.816648	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
59	7	2026-01-30 19:58:45.540452	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
60	3	2026-01-30 20:00:22.079714	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
61	4	2026-01-30 20:02:54.029401	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
62	3	2026-01-30 20:14:50.264349	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
63	3	2026-01-30 21:20:51.121876	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
64	4	2026-01-31 00:12:54.140119	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
65	3	2026-01-31 00:18:44.216795	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
66	3	2026-01-31 00:25:37.863681	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 26_2_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/144.0.7559.95 Mobile/15E148 Safari/604.1
67	4	2026-01-31 00:26:02.422478	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36
68	5	2026-01-31 03:57:15.275339	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1
69	5	2026-01-31 18:21:46.494699	172.23.0.4	Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1
70	4	2026-01-31 19:48:06.934899	172.23.0.4	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36
71	7	2026-01-31 19:50:39.547357	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
72	3	2026-01-31 19:51:13.859804	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
73	7	2026-01-31 19:52:22.30757	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
74	3	2026-01-31 19:52:47.37169	172.23.0.4	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0
\.


--
-- Data for Name: poll_options; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.poll_options (id, poll_id, date_time, description) FROM stdin;
\.


--
-- Data for Name: poll_votes; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.poll_votes (id, option_id, user_id, value, voted_at, comment) FROM stdin;
\.


--
-- Data for Name: polls; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.polls (id, title, description, creator_id, is_open, created_at, closed_at) FROM stdin;
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.ratings (id, user_id, game_id, score, comment, created_at, updated_at) FROM stdin;
4	4	18	10		2026-01-27 19:08:17.263566	2026-01-27 19:08:17.263572
6	3	20	10	Creo que no pueden ser demasiados jugadores >8 para que no se pierdan pistas importantes	2026-01-27 19:40:34.011813	2026-01-27 19:40:34.011823
7	15	9	10		2026-01-27 22:34:47.967354	2026-01-27 22:34:47.967362
8	12	7	10		2026-01-27 22:34:56.900783	2026-01-27 22:34:56.900789
10	12	9	10		2026-01-27 22:35:58.550837	2026-01-27 22:35:58.550843
9	15	10	9	Impresionante ! Si Leo traduce las tarjetas al español le pongo 20 de calificación 	2026-01-27 22:35:38.261773	2026-01-27 22:36:29.482224
12	10	3	10		2026-01-27 23:21:29.082533	2026-01-27 23:21:29.082541
13	10	8	10		2026-01-27 23:22:53.607202	2026-01-27 23:22:53.607208
11	3	18	9		2026-01-27 22:49:08.584519	2026-01-28 00:10:25.606607
14	3	4	9		2026-01-28 00:11:43.995168	2026-01-28 00:11:43.995177
15	3	17	8	Quiero volver a jugarlo, estoy seguro de que me gustará más al entenderlo mejor.	2026-01-28 00:13:52.225743	2026-01-28 00:13:52.22575
16	3	13	10		2026-01-28 00:14:17.229974	2026-01-28 00:14:17.22998
17	3	8	9		2026-01-28 00:14:48.847518	2026-01-28 00:14:48.847524
18	3	12	10	Muy dinámico!	2026-01-28 00:15:45.227106	2026-01-28 00:15:45.227115
19	3	9	10		2026-01-28 00:16:06.749895	2026-01-28 00:16:06.749904
20	3	3	10		2026-01-28 00:16:38.711432	2026-01-28 00:16:38.71144
21	3	7	10		2026-01-28 00:17:27.855955	2026-01-28 00:17:27.85596
22	3	10	10		2026-01-28 00:18:17.717212	2026-01-28 00:18:17.71722
23	3	2	10		2026-01-28 00:44:21.302289	2026-01-28 00:44:21.302296
24	3	6	6	Me resultó muy estresante, pero estoy dispuesto a volver a probar.	2026-01-28 00:50:00.400671	2026-01-28 00:50:00.400678
25	4	12	10	Me encanto...aunque tengo que aprender a mentir un poco.	2026-01-28 00:51:01.556103	2026-01-28 00:51:01.556111
26	4	4	4		2026-01-28 00:55:29.664693	2026-01-28 00:55:29.664701
27	4	13	9	Fue uno de los primeros que jugamos, habría que repetir!	2026-01-28 01:41:04.783998	2026-01-28 01:41:04.784007
28	4	10	9		2026-01-28 01:42:27.322421	2026-01-28 01:42:27.322429
29	4	9	10		2026-01-28 01:42:45.574537	2026-01-28 01:42:45.574546
30	4	8	9	Clásico!! Siempre se hace lugar para una partidita!	2026-01-28 01:43:50.626482	2026-01-28 01:43:50.626491
31	4	7	10		2026-01-28 01:44:05.342383	2026-01-28 01:44:05.342391
32	4	6	5		2026-01-28 01:44:37.364008	2026-01-28 01:44:37.364017
33	4	5	10		2026-01-28 01:45:33.842989	2026-01-28 01:45:33.842994
34	4	2	10	No se si esta bueno el juego, o nuestro grupo esta bueno, pero le ganamos!	2026-01-28 01:47:03.448953	2026-01-28 01:47:03.448962
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: bguser
--

COPY public.users (id, username, password_hash, role, created_at, last_login) FROM stdin;
1	admin	$2b$12$SWZ9q9wBvDqrN8O/fUUFXu/jrqhyqRdAp/RM6tclvsjI/MIZCrLXS	admin	2026-01-26 05:54:09.61642	2026-01-27 03:15:45.566013
20	Marcel	$2b$12$HeDHaBSGooY8HsJTKI1kUOO4GCwA8LXucPXqp0fajI6X2u2UjcWnS	user	2026-01-28 14:54:26.216408	2026-01-28 14:55:17.165288
6	Bruno	$2b$12$.FnHsqlCmhq3cNHZth6pveYp5xtmJDH2ClkieZ7kP9VDa5QNCWQRa	user	2026-01-27 20:22:59.758446	\N
8	Emiliano	$2b$12$SR5ozByb8nyDqE7d38/8VOlmzoy2MAKCvPRBF4InRA.kl102BrW6q	user	2026-01-27 20:23:23.135127	\N
9	Franco	$2b$12$CtktVX5n.NpyJe5DT8RpaeVrlRUzQynswEQuRwwgAFmV0rjpOiNoS	user	2026-01-27 20:23:34.010093	\N
11	Gustavo	$2b$12$0J2yus8Iu7iWOQ0SPagnHe2i8xlurxiBNtwosihQyKcbazn7CnLX.	user	2026-01-27 20:23:56.308732	\N
17	Natalia	$2b$12$CxqYPDGUurUv.K2JuzYhaOvCPTdG41cJQeMaOLRnIh0NPcavb8vku	user	2026-01-27 20:25:29.863575	\N
13	Jimena	$2b$12$mAB6NMOjLRn0xRyq3IBcQeUCTTVJEswjln4VKBvuCH4Em1Cb9b4oy	user	2026-01-27 20:24:15.587229	2026-01-28 22:44:50.705285
18	Viviana	$2b$12$CjygV0IORLnfN8Wc3UgdVOX5dJEkWmPGnzHcpte8OR4lWhx1mOZ.m	user	2026-01-27 22:15:47.182166	\N
12	Helga	$2b$12$vrFwfxoRoWn3b/fU7XA2kOcvd/qVnXiPziahRuvtEvxh.bL/GKysm	user	2026-01-27 20:24:05.606212	2026-01-27 22:32:30.035393
15	Martin	$2b$12$14eYIVYIr0jHBHOdJ1y0p.PHRGfrin4isb0VrBseY4yJXxlqSage6	user	2026-01-27 20:24:55.235164	2026-01-27 22:33:34.176523
10	Gaby	$2b$12$ut0GDJpF9j3TX9Z1KVrwS.gf3gvUgKrP5DXFlclB17Shx0o.futm6	user	2026-01-27 20:23:44.181111	2026-01-27 23:15:47.102369
16	Miriam	$2b$12$BUkzNHi6/6v9uBoQ0N8.FO4VR9q0WYAxzV.fNZUk64uFkNgC8ilJi	user	2026-01-27 20:25:12.16761	2026-01-28 00:53:06.643175
14	Manuel	$2b$12$9SLGnIhc7fUBapcRkRQcqugGNjHLrK8PHY8N7PTY/9Y8B92MoPoaW	user	2026-01-27 20:24:32.730292	2026-01-28 01:02:05.50187
2	invitado	$2b$12$Gh57GQUJ9XIX1z4yYcUtF.etS9fVbz5afFJnnXhbbjfPznNzWQUXC	guest	2026-01-26 05:54:09.927404	2026-01-30 04:08:58.818093
5	Rosina	$2b$12$Tk.tCHVOu.zTe.wvayAI2uSMUMpqbOac3JiAfX8ZEY6788o7qXGVK	user	2026-01-27 20:22:48.102578	2026-01-31 18:21:46.49473
4	Yosane	$2b$12$LqIuWDTkJFAei/DB6lSzQuN2BgTeJbX7kQP5uXK7pesx.kF/a5Tly	user	2026-01-27 18:59:55.243207	2026-01-31 19:48:06.93492
7	Diego	$2b$12$9Ml0fHzSjjd.mvEKjU.1YebE4/0xk.LCpVE01k.3AI475mmOngup6	user	2026-01-27 20:23:11.62085	2026-01-31 19:52:22.307597
3	Leonardo	$2b$12$mzn9QjMUwImPGMITLhJ3LeCsIvlS4cLk9s.DUZ5gGXoJXGX7BTVsi	admin	2026-01-26 13:39:49.834421	2026-01-31 19:52:47.371716
\.


--
-- Name: games_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.games_id_seq', 22, true);


--
-- Name: login_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.login_logs_id_seq', 74, true);


--
-- Name: poll_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.poll_options_id_seq', 20, true);


--
-- Name: poll_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.poll_votes_id_seq', 39, true);


--
-- Name: polls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.polls_id_seq', 5, true);


--
-- Name: ratings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.ratings_id_seq', 34, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: bguser
--

SELECT pg_catalog.setval('public.users_id_seq', 20, true);


--
-- Name: poll_votes _option_user_uc; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT _option_user_uc UNIQUE (option_id, user_id);


--
-- Name: games games_bgg_id_key; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_bgg_id_key UNIQUE (bgg_id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: login_logs login_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_pkey PRIMARY KEY (id);


--
-- Name: poll_options poll_options_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_pkey PRIMARY KEY (id);


--
-- Name: poll_votes poll_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: ratings unique_user_game_rating; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT unique_user_game_rating UNIQUE (user_id, game_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: login_logs login_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: poll_options poll_options_poll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(id);


--
-- Name: poll_votes poll_votes_option_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.poll_options(id);


--
-- Name: poll_votes poll_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: polls polls_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: ratings ratings_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- Name: ratings ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bguser
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict IYozEfQYmnVccxEkKpj5OjOnYZ1CU7c8ZvFY0zysblV5rHMnTefhmtSXEVFF4qv

