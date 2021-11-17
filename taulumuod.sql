DROP SERVER IF EXISTS dev_fdw CASCADE;
DROP FOREIGN TABLE IF EXISTS ptvforeign;
DROP TABLE IF EXISTS ptvdata;
DROP TABLE IF EXISTS ptv_latest;

CREATE SERVER dev_fdw FOREIGN DATA WRAPPER multicorn OPTIONS (wrapper 'ptvfdw.ptvForeignDataWrapper');

CREATE FOREIGN TABLE ptvforeign(
orig_id varchar,
palvelut varchar[],
kohteen_nimi varchar,
latitude real,
longitude real,
puhelinnumero varchar,
osoite varchar,
sahkoposti varchar,
verkkosivu varchar,
aukioloajat varchar
) server dev_fdw options(
url 'https://api.palvelutietovaranto.suomi.fi/api/v11/ServiceChannel/list/area/Municipality/code/'
);

CREATE TABLE ptvdata(
orig_id varchar,
palvelut varchar,
kohteen_nimi varchar,
latitude real,
longitude real,
puhelinnumero varchar,
osoite varchar,
sahkoposti varchar,
verkkosivu varchar,
aukioloajat varchar
);

INSERT INTO ptvdata (orig_id, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT orig_id, REPLACE(TRIM('{}' FROM CAST("palvelut" as varchar)), '"', ''), kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat
FROM ptvforeign;

DELETE FROM ptvdata
WHERE "latitude"=0 or "longitude"=0;

CREATE TABLE ptv_latest(
orig_id varchar,
palvelukohdetyyppi varchar,
palvelut varchar,
kohteen_nimi varchar,
latitude real,
longitude real,
puhelinnumero varchar,
osoite varchar,
sahkoposti varchar,
verkkosivu varchar,
aukioloajat varchar
);


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Apteekit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'apteekki' || '%' or ("palvelut" ilike '%' || 'apteekki' || '%' and "kohteen_nimi" not ilike '%' || 'apteekki' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Paloasemat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'paloasema' || '%' or "kohteen_nimi" ilike '%' || 'palokunta' || '%' or (("palvelut" ilike '%' || 'ensihoito' || '%' or "palvelut" ilike '%' || 'palo' || '%') and ("kohteen_nimi" not ilike '%' || 'paloasema' || '%' and "kohteen_nimi" not ilike '%' || 'palokunta' || '%'));


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Museot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'museo' || '%' or ("palvelut" ilike '%' || 'museo' || '%' and "kohteen_nimi" not ilike '%' || 'museo' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset terveyskeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'terveysasema' || '%' or "kohteen_nimi" ilike '%' || 'terveyskeskus' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Sosiaalitoimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'sosiaalitoimisto' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Neuvolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'neuvola' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Koulut (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE (("kohteen_nimi" ilike '%' || 'koulu' || '%' and "kohteen_nimi" not ilike '%' || 'koulutalo' || '%') and ("palvelut" not ilike '%' || 'lukiokoulutus' || '%' and "palvelut" not ilike '%' || 'ammatillinen koulutus' || '%')) or ("palvelut" ilike '%' || 'perusopetus' || '%' and "kohteen_nimi" not ilike '%' || 'koulu' || '%' and "kohteen_nimi" not ilike '%' || 'koulutalo' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lukiot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'lukio' || '%' or ("palvelut" ilike '%' || 'lukiokoulutus' || '%'and "kohteen_nimi" not ilike '%' || 'lukio' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Ammatillisen koulutuksen instituutit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'koulutalo' || '%' or ("palvelut" ilike '%' || 'ammatillinen koulutus' || '%' and "kohteen_nimi" not ilike '%' || 'koulutalo' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kansalaisopistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kansalaisopisto' || '%' or ("palvelut" ilike '%' || 'kansalaisopisto' || '%' and "kohteen_nimi" not ilike '%' || 'kansalaisopisto' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Muut opistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE ("kohteen_nimi" ilike '%' || 'opisto' || '%' and "kohteen_nimi" not ilike '%' || 'kansalaisopisto' || '%') or ("palvelut" ilike '%' || 'opisto' || '%' and "palvelut" not ilike '%' || 'kansalaisopisto' || '%' and "kohteen_nimi" not ilike '%' || 'opisto' || '%' and "kohteen_nimi" not ilike '%' || 'kansalaisopisto' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset päiväkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE ("kohteen_nimi" ilike '%' || 'päiväkoti' || '%' or "kohteen_nimi" ilike '%' || 'päivähoito' || '%') or ("palvelut" ilike '%' || 'kunnallinen päiväkoti' || '%' and "kohteen_nimi" not ilike '%' || 'päiväkoti' || '%' and "kohteen_nimi" not ilike '%' || 'päivähoito' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Aamu- ja iltapäivätoiminta (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "palvelut" ilike '%' || 'perusopetuksen aamu- ja iltapäivätoiminta' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnanvirastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kunnanvirasto' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kelan toimipisteet', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "palvelut" ilike '%' || 'kelan ' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'TE-toimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'te-toimisto' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kirjasto' || '%' or ("palvelut" ilike '%' || 'kirjasto' || '%' and "kohteen_nimi" not ilike '%' || 'kirjasto' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastoautot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kirjastoauto' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leikkikerhot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'leikkikerho' || '%' or ("palvelut" ilike '%' || 'leikkikerhot' || '%' and "kohteen_nimi" not ilike '%' || 'leikkikerho' || '%' and "kohteen_nimi" not ilike '%' || 'päiväkoti' || '%' and "kohteen_nimi" not ilike '%' || 'päivähoito' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leirikeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'leirikeskus' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimahallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'uimahalli' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimapaikat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'uimaranta' || '%' or "kohteen_nimi" ilike '%' || 'maauima' || '%' or "kohteen_nimi" ilike '%' || 'uimapaik' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Soutu- ja melontakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'soutu' || '%' or "kohteen_nimi" ilike '%' || 'melonta' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Jäähallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'jäähalli' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Liikuntasalit ja palloiluhallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'liikuntasali' || '%' or ("palvelut" ilike '%' || 'liikuntasali' || '%' and "kohteen_nimi" not ilike '%' || 'liikuntasali' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Urheilukentät', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'urheilukenttä' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Stadionit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'stadion' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Julkiset hammashoitolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'hammas' || '%' or ("palvelut" ilike '%' || 'hammas' || '%' or "palvelut" ilike '%' || 'suun terveyden' || '%' or "palvelut" ilike '%' || 'suunterveyden' || '%' and "kohteen_nimi" not ilike '%' || 'hammas' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotihoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kotihoito' || '%' or ("palvelut" like '%' || 'Kotihoito' || '%' and "kohteen_nimi" not ilike '%' || 'kotihoito' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotisairaanhoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kotisairaanhoito' || '%' or ("palvelut" ilike '%' || 'kotisairaanhoito' || '%' and "kohteen_nimi" not ilike '%' || 'kotisairaanhoito' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Palvelutalot, ryhmä- ja vanhainkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE ("kohteen_nimi" ilike '%' || 'palvelutalo' || '%' or "kohteen_nimi" ilike '%' || 'hoivakoti' || '%' or "kohteen_nimi" ilike '%' || 'ryhmäkoti' || '%' or "kohteen_nimi" ilike '%' || 'vanhainkoti' || '%') or ("palvelut" ilike '%' || 'laitoshoito' || '%' or "palvelut" ilike '%' || 'palveluasuminen' || '%' and ("kohteen_nimi" not ilike '%' || 'palvelutalo' || '%' and "kohteen_nimi" not ilike '%' || 'hoivakoti' || '%' and "kohteen_nimi" not ilike '%' || 'ryhmäkoti' || '%' and "kohteen_nimi" not ilike '%' || 'vanhainkoti' || '%'));


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Päihdehuollon yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'päihde' || '%' or ("palvelut" ilike '%' || 'päihde' || '%' and "kohteen_nimi" not ilike '%' || 'päihde' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lastenkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'lastenkoti' || '%';


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kehitysvammahuollon tukiyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kehitysvamma' || '%' or ("palvelut" ilike '%' || 'kehitysvamma' || '%' and "kohteen_nimi" not ilike '%' || 'kehitysvamma' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Nuorisotilat ja -keskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE ("kohteen_nimi" ilike '%' || 'nuorisotila' || '%' or "kohteen_nimi" ilike '%' || 'nuorisokeskus' || '%' or "kohteen_nimi" ilike '%' || 'nuorisotalo' || '%') or ("palvelut" ilike '%' || 'nuorisotila' || '%' or "palvelut" ilike '%' || 'nuorisopalvelu' || '%' or "palvelut" ilike '%' || 'nuorisotyö' || '%' and ("kohteen_nimi" not ilike '%' || 'nuorisotila' || '%' and "kohteen_nimi" not ilike '%' || 'nuorisokeskus' || '%' and "kohteen_nimi" not ilike '%' || 'nuorisotalo' || '%'));


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Toimintakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'toimintakeskus' || '%' or ("palvelut" ilike '%' || 'toimintakeskus' || '%' and "kohteen_nimi" not ilike '%' || 'toimintakeskus' || '%');


INSERT INTO ptv_latest (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotipalvelun yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
WHERE "kohteen_nimi" ilike '%' || 'kotipalvelu' || '%' or ("palvelut" ilike '%' || 'kotipalvelu' || '%' and "kohteen_nimi" not ilike '%' || 'kotipalvelu' || '%');


ALTER TABLE ptv_latest ADD COLUMN geom geometry(Point, 3067);

UPDATE ptv_latest SET geom = ST_SetSRID(ST_MakePoint("longitude", "latitude"), 3067);

ALTER TABLE ptv_latest ADD COLUMN datalahde varchar;

UPDATE ptv_latest SET datalahde = 'PTV';

DROP FOREIGN TABLE IF EXISTS ptvforeign;
DROP TABLE IF EXISTS ptvdata;
