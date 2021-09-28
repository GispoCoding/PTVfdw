
-- LUODAAN FDW ja FOREIGN TABLE

CREATE SERVER dev_fdw FOREIGN DATA WRAPPER multicorn OPTIONS (wrapper 'ptvfdw.ptvForeignDataWrapper');


CREATE FOREIGN TABLE foreigntaulu(
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


---- LUODAAN UUSI TAULU KIINNOSTAVIEN KOHTEIDEN TIEDOILLE
drop table if exists ptvkohteet;
drop table if exists ptvselected3;

CREATE TABLE ptvkohteet(
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

INSERT INTO ptvkohteet (orig_id, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT orig_id, REPLACE(TRIM('{}' FROM CAST("palvelut" as varchar)), '"', ''), kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM foreigntaulu;

DELETE FROM ptvkohteet
where "latitude"=0 or "longitude"=0;

--select count(*)
--from ptvkohteet;

CREATE TABLE ptvselected3(
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


---------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Apteekit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'apteekkipalvelut' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Apteekit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut"='' and "kohteen_nimi" ilike '%' || 'apteekki' || '%';

--select *
--from ptvselected3;

-------------- SAIRAALAT, SKIPATTU SKELETONISSA
--select distinct *
--from ptvkohteet
--where "name" ilike '%' || ' sairaala' || '%' or "name" ilike 'kaupunginsairaala' or ("name" ilike '%' || 'satasairaala' || '%' and "channel_id" = '66412a1c-88ee-4f99-899d-758566ca91ce');

--------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Paloasemat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'ensihoito' || '%' or "palvelut" ilike '%' || 'palo' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Paloasemat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'paloasema' || '%' or "kohteen_nimi" ilike '%' || 'palokunta' || '%');

-------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Museot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'museot' || '%' or "palvelut" ilike '%' || 'museopalvelut' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Museot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'museo' || '%';

----------- KIRKOT, SKIPATAAN KOSKA EI LÖYDY KOHTEITA

-----------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset terveyskeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'terveysasema' || '%' or "kohteen_nimi" ilike '%' || 'terveyskeskus' || '%';

----------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Sosiaalitoimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'sosiaalitoimisto' || '%';

--------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Neuvolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'neuvola' || '%';

-------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Koulut (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'perusopetus' || '%';

------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lukiot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'lukiokoulutus' || '%';

---------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Ammatillisen koulutuksen instituutit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'ammatillinen koulutus' || '%';

-----------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kansalaisopistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kansalaisopisto' || '%';

---------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Muut opistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'opisto' || '%' and "palvelut" not ilike '%' || 'kansalaisopisto' || '%';

--------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnalliset päiväkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kunnallinen päiväkoti' || '%';

------------------ 
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Aamu- ja iltapäivätoiminta (perusopetus)', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'perusopetuksen aamu- ja iltapäivätoiminta' || '%';

----------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kunnanvirastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'kunnanvirasto' || '%';

--------------------------------------------- Hyotyisi organisaationimestä, jos se tieto olisi saatavilla...
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kelan toimipisteet', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kelan ' || '%';

-----------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'TE-toimistot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'te-toimisto' || '%';

---------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kirjasto' || '%';

------------------------------- OIKEASTAAN KIRJASTOAUTOT, EI NIIDEN PYSÄKIT!
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kirjastoautot', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'kirjastoauto' || '%';

------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leikkikerhot ja avoimet päiväkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'leikkikerhot' || '%';

-------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Leirikeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'leirikeskus' || '%';

---------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimahallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'uimahalli' || '%';

---------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Uimapaikat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'uimaranta' || '%' or "kohteen_nimi" ilike '%' || 'maauima' || '%' or "kohteen_nimi" ilike '%' || 'uimapaik' || '%';

----------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Soutu- ja melontakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'soutu' || '%' or "kohteen_nimi" ilike '%' || 'melonta' || '%';

------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Jäähallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'jäähalli' || '%';

-------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Liikuntasalit ja palloiluhallit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'liikuntasali' || '%';

-------------------------------------- EI VARMASTI SISÄLLÄ KAIKKIA HALUTTUJA KOHTEITA
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Urheilukentät', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'urheilukenttä' || '%';

-------------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Stadionit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'stadion' || '%';

------------------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Julkiset hammashoitolat', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'hammas' || '%' or "palvelut" ilike '%' || 'suun terveyden' || '%' or "palvelut" ilike '%' || 'suunterveyden' || '%';

------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotihoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" like '%' || 'Kotihoito' || '%';

--------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotisairaanhoidon palveluyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kotisairaanhoito' || '%';

------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Palvelutalot, ryhmä- ja vanhainkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'laitoshoito' || '%' or "palvelut" ilike '%' || 'palveluasuminen' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Palvelutalot, ryhmä- ja vanhainkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'palvelutalo' || '%' or "kohteen_nimi" ilike '%' || 'hoivakoti' || '%' or "kohteen_nimi" ilike '%' || 'ryhmäkoti' || '%' or "kohteen_nimi" ilike '%' || 'vanhainkoti' || '%');

--------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Päihdehuollon yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'päihde' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Päihdehuollon yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'päihde' || '%';

-------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Lastenkodit', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "kohteen_nimi" ilike '%' || 'lastenkoti' || '%';

--------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kehitysvammahuollon tukiyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kehitysvamma' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kehitysvammahuollon tukiyksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'kehitysvamma' || '%';

-------------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Nuorisotilat ja -keskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'nuorisotila' || '%' or "palvelut" ilike '%' || 'nuorisopalvelu' || '%' or "palvelut" ilike '%' || 'nuorisotyö' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Nuorisotilat ja -keskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and ("kohteen_nimi" ilike '%' || 'nuorisotila' || '%' or "kohteen_nimi" ilike '%' || 'nuorisokeskus' || '%' or "kohteen_nimi" ilike '%' || 'nuorisotalo' || '%');

-----------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Toimintakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'toimintakeskus' || '%';

INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Toimintakeskukset', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" = '' and "kohteen_nimi" ilike '%' || 'toimintakeskus' || '%';

--------------------------------
INSERT INTO ptvselected3 (orig_id, palvelukohdetyyppi, palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat)
SELECT distinct orig_id, 'Kotipalvelun yksiköt', palvelut, kohteen_nimi, latitude, longitude, puhelinnumero, osoite, sahkoposti, verkkosivu, aukioloajat FROM ptvkohteet
where "palvelut" ilike '%' || 'kotipalvelu' || '%';


---------------------- LOPUKSI LUODAAN GEOMETRIATIETO LAT JA LON SARAKKEISTA

ALTER TABLE ptvselected3 ADD COLUMN geom geometry(Point, 3067);

UPDATE ptvselected3 SET geom = ST_SetSRID(ST_MakePoint("longitude", "latitude"), 3067);

ALTER TABLE ptvselected3 ADD COLUMN datalahde varchar;

UPDATE ptvselected3 SET datalahde = 'PTV';


