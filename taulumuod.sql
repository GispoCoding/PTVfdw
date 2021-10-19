DROP SERVER IF EXISTS dev_fdw CASCADE;
DROP FOREIGN TABLE IF EXISTS ptvforeign;
DROP TABLE IF EXISTS ptvdata;
DROP TABLE IF EXISTS ptvselected;

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
where "latitude"=0 or "longitude"=0;

CREATE TABLE ptvselected(
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

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Apteekit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat
FROM ptvdata
where "palvelut" ilike '%' || 'apteekkipalvelut' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Apteekit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat
FROM ptvdata
where "palvelut"='' and "kohteen_nimi" ilike '%' || 'apteekki' || '%';

 INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Paloasemat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'ensihoito' || '%' or "palvelut" ilike '%' || 'palo' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Paloasemat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'paloasema' || '%' or "kohteen_nimi" ilike '%' || 'palokunta' || '%');

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Museot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'museot' || '%' or "palvelut" ilike '%' || 'museopalvelut' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Museot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'museo' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset terveyskeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'terveysasema' || '%' or "kohteen_nimi" ilike '%' || 'terveyskeskus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Sosiaalitoimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'sosiaalitoimisto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Neuvolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'neuvola' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Koulut (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'perusopetus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lukiot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'lukiokoulutus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Ammatillisen koulutuksen instituutit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'ammatillinen koulutus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kansalaisopistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kansalaisopisto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Muut opistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'opisto' || '%' and "palvelut" not ilike '%' || 'kansalaisopisto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset päiväkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kunnallinen päiväkoti' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Aamu- ja iltapäivätoiminta (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'perusopetuksen aamu- ja iltapäivätoiminta' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnanvirastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'kunnanvirasto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kelan toimipisteet', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kelan ' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'TE-toimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'te-toimisto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kirjasto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastoautot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'kirjastoauto' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leikkikerhot ja avoimet päiväkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'leikkikerhot' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leirikeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'leirikeskus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimahallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'uimahalli' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimapaikat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'uimaranta' || '%' or "kohteen_nimi" ilike '%' || 'maauima' || '%' or "kohteen_nimi" ilike '%' || 'uimapaik' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Soutu- ja melontakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'soutu' || '%' or "kohteen_nimi" ilike '%' || 'melonta' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Jäähallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'jäähalli' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Liikuntasalit ja palloiluhallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'liikuntasali' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Urheilukentät', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'urheilukenttä' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Stadionit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'stadion' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Julkiset hammashoitolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'hammas' || '%' or "palvelut" ilike '%' || 'suun terveyden' || '%' or "palvelut" ilike '%' || 'suunterveyden' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotihoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" like '%' || 'Kotihoito' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotisairaanhoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kotisairaanhoito' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Palvelutalot, ryhmä- ja vanhainkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'laitoshoito' || '%' or "palvelut" ilike '%' || 'palveluasuminen' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Palvelutalot, ryhmä- ja vanhainkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'palvelutalo' || '%' or "kohteen_nimi" ilike '%' || 'hoivakoti' || '%' or "kohteen_nimi" ilike '%' || 'ryhmäkoti' || '%' or "kohteen_nimi" ilike '%' || 'vanhainkoti' || '%');

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Päihdehuollon yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'päihde' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Päihdehuollon yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'päihde' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lastenkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "kohteen_nimi" ilike '%' || 'lastenkoti' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kehitysvammahuollon tukiyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kehitysvamma' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kehitysvammahuollon tukiyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'kehitysvamma' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Nuorisotilat ja -keskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'nuorisotila' || '%' or "palvelut" ilike '%' || 'nuorisopalvelu' || '%' or "palvelut" ilike '%' || 'nuorisotyö' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Nuorisotilat ja -keskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'nuorisotila' || '%' or "kohteen_nimi" ilike '%' || 'nuorisokeskus' || '%' or "kohteen_nimi" ilike '%' || 'nuorisotalo' || '%');

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Toimintakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'toimintakeskus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Toimintakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'toimintakeskus' || '%';

INSERT INTO ptvselected (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotipalvelun yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvdata
where "palvelut" ilike '%' || 'kotipalvelu' || '%';

ALTER TABLE ptvselected
ADD COLUMN geom geometry(Point, 3067);

UPDATE ptvselected
SET geom = ST_SetSRID(ST_MakePoint("longitude", "latitude"), 3067);

ALTER TABLE ptvselected
ADD COLUMN datalahde varchar;

UPDATE ptvselected
SET datalahde = 'PTV';