-- project: GNUMed
-- database GIS - spanish counties, according to National Institute of Statistics (http://www.ine.es)

-- ===================================================================
-- author: Carlos Moro
-- license: GPL v2 or later

-- ===================================================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ===================================================================
select i18n.upd_tx('es_ES', 'Spain', 'España');

-- Carlos, please reconcile:
--INSERT into dem.state(code, country, name) VALUES ('AN','ES',i18n.i18n('Andalusia'));
--INSERT into dem.state(code, country, name) VALUES ('AR','ES',i18n.i18n('Aragon'));
--INSERT into dem.state(code, country, name) VALUES ('AS','ES',i18n.i18n('Asturias'));
--INSERT into dem.state(code, country, name) VALUES ('BI','ES',i18n.i18n('Balearic Islands'));
--INSERT into dem.state(code, country, name) VALUES ('BC','ES',i18n.i18n('Basque Country'));
--INSERT into dem.state(code, country, name) VALUES ('CI','ES',i18n.i18n('Canary Islands'));
--INSERT into dem.state(code, country, name) VALUES ('CA','ES',i18n.i18n('Cantabria'));
--INSERT into dem.state(code, country, name) VALUES ('CL','ES',i18n.i18n('Castilla y Leon'));
--INSERT into dem.state(code, country, name) VALUES ('CM','ES',i18n.i18n('Castilla-La Mancha'));
--INSERT into dem.state(code, country, name) VALUES ('CT','ES',i18n.i18n('Catalonia'));
--INSERT into dem.state(code, country, name) VALUES ('EX','ES',i18n.i18n('Extremadura'));
--INSERT into dem.state(code, country, name) VALUES ('GA','ES',i18n.i18n('Galicia'));
--INSERT into dem.state(code, country, name) VALUES ('LR','ES',i18n.i18n('La Rioja'));
--INSERT into dem.state(code, country, name) VALUES ('MA','ES',i18n.i18n('Madrid'));
--INSERT into dem.state(code, country, name) VALUES ('MU','ES',i18n.i18n('Murcia'));
--INSERT into dem.state(code, country, name) VALUES ('NA','ES',i18n.i18n('Navarre'));
--INSERT into dem.state(code, country, name) VALUES ('VA','ES',i18n.i18n('Valencia'));

-- spanish geographic information (mostly of type 'state')
INSERT into dem.state(code,country,name) VALUES ('01','ES',i18n.i18n('Álava'));
INSERT into dem.state(code,country,name) VALUES ('02','ES',i18n.i18n('Albacete'));
INSERT into dem.state(code,country,name) VALUES ('03','ES',i18n.i18n('Alicante'));
INSERT into dem.state(code,country,name) VALUES ('04','ES',i18n.i18n('Almería'));
INSERT into dem.state(code,country,name) VALUES ('33','ES',i18n.i18n('Asturias'));
INSERT into dem.state(code,country,name) VALUES ('05','ES',i18n.i18n('Ávila'));
INSERT into dem.state(code,country,name) VALUES ('06','ES',i18n.i18n('Badajoz'));
INSERT into dem.state(code,country,name) VALUES ('07','ES',i18n.i18n('Baleares'));
INSERT into dem.state(code,country,name) VALUES ('08','ES',i18n.i18n('Barcelona'));
INSERT into dem.state(code,country,name) VALUES ('09','ES',i18n.i18n('Burgos'));
INSERT into dem.state(code,country,name) VALUES ('10','ES',i18n.i18n('Cáceres'));
INSERT into dem.state(code,country,name) VALUES ('11','ES',i18n.i18n('Cádiz'));
INSERT into dem.state(code,country,name) VALUES ('12','ES',i18n.i18n('Castellón'));
INSERT into dem.state(code,country,name) VALUES ('13','ES',i18n.i18n('Ciudad Real'));
INSERT into dem.state(code,country,name) VALUES ('14','ES',i18n.i18n('Córdoba'));
INSERT into dem.state(code,country,name) VALUES ('15','ES',i18n.i18n('Coruña'));
INSERT into dem.state(code,country,name) VALUES ('16','ES',i18n.i18n('Cuenca'));
INSERT into dem.state(code,country,name) VALUES ('17','ES',i18n.i18n('Gerona'));
INSERT into dem.state(code,country,name) VALUES ('18','ES',i18n.i18n('Granada'));
INSERT into dem.state(code,country,name) VALUES ('19','ES',i18n.i18n('Guadalajara'));
INSERT into dem.state(code,country,name) VALUES ('20','ES',i18n.i18n('Guipúzcoa'));
INSERT into dem.state(code,country,name) VALUES ('21','ES',i18n.i18n('Huelva'));
INSERT into dem.state(code,country,name) VALUES ('22','ES',i18n.i18n('Huesca'));
INSERT into dem.state(code,country,name) VALUES ('23','ES',i18n.i18n('Jaén'));
INSERT into dem.state(code,country,name) VALUES ('24','ES',i18n.i18n('León'));
INSERT into dem.state(code,country,name) VALUES ('25','ES',i18n.i18n('Lérida'));
INSERT into dem.state(code,country,name) VALUES ('27','ES',i18n.i18n('Lugo'));
INSERT into dem.state(code,country,name) VALUES ('28','ES',i18n.i18n('Madrid'));
INSERT into dem.state(code,country,name) VALUES ('29','ES',i18n.i18n('Málaga'));
INSERT into dem.state(code,country,name) VALUES ('30','ES',i18n.i18n('Murcia'));
INSERT into dem.state(code,country,name) VALUES ('31','ES',i18n.i18n('Navarra'));
INSERT into dem.state(code,country,name) VALUES ('32','ES',i18n.i18n('Orense'));
INSERT into dem.state(code,country,name) VALUES ('34','ES',i18n.i18n('Palencia'));
INSERT into dem.state(code,country,name) VALUES ('35','ES',i18n.i18n('Palmas (Las)'));
INSERT into dem.state(code,country,name) VALUES ('36','ES',i18n.i18n('Pontevedra'));
INSERT into dem.state(code,country,name) VALUES ('26','ES',i18n.i18n('Rioja (La)'));
INSERT into dem.state(code,country,name) VALUES ('37','ES',i18n.i18n('Salamanca'));
INSERT into dem.state(code,country,name) VALUES ('38','ES',i18n.i18n('Santa Cruz de Tenerife'));
INSERT into dem.state(code,country,name) VALUES ('40','ES',i18n.i18n('Segovia'));
INSERT into dem.state(code,country,name) VALUES ('41','ES',i18n.i18n('Sevilla'));
INSERT into dem.state(code,country,name) VALUES ('42','ES',i18n.i18n('Soria'));
INSERT into dem.state(code,country,name) VALUES ('43','ES',i18n.i18n('Tarragona'));
INSERT into dem.state(code,country,name) VALUES ('44','ES',i18n.i18n('Teruel'));
INSERT into dem.state(code,country,name) VALUES ('45','ES',i18n.i18n('Toledo'));
INSERT into dem.state(code,country,name) VALUES ('46','ES',i18n.i18n('Valencia'));
INSERT into dem.state(code,country,name) VALUES ('47','ES',i18n.i18n('Valladolid'));
INSERT into dem.state(code,country,name) VALUES ('48','ES',i18n.i18n('Vizcaya'));
INSERT into dem.state(code,country,name) VALUES ('49','ES',i18n.i18n('Zamora'));
INSERT into dem.state(code,country,name) VALUES ('50','ES',i18n.i18n('Zaragoza'));

select dem.gm_upd_default_states();

-- ===================================================================
-- do simple revision tracking
delete from gm_schema_revision where filename = '$RCSfile: gmDemographics-Data.es.sql,v $';
INSERT INTO gm_schema_revision (filename, version) VALUES ('$RCSfile: gmDemographics-Data.es.sql,v $', '$Revision: 1.7 $');
