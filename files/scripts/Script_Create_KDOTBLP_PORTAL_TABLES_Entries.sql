prompt PL/SQL Developer Export Tables for user KDOT_BLP@LOCALHOST:1521/XEPDB1
prompt Created by armpl on Wednesday, January 4, 2023
set feedback off
set define off
/*
prompt Dropping KDOTBLP_PORTAL_TABLES...
drop table KDOTBLP_PORTAL_TABLES cascade constraints;
prompt Creating KDOTBLP_PORTAL_TABLES...
create table KDOTBLP_PORTAL_TABLES
(
  table_name       VARCHAR2(128) not null,
  processing_order INTEGER not null
)
tablespace KDOT_BLP
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
*/
truncate table KDOTBLP_PORTAL_TABLES;


prompt Loading KDOTBLP_PORTAL_TABLES...
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_USERS', 610);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_ROLES', 620);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_PERMISSIONS', 630);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_ROLES_PERMISSIONS', 640);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_USERS_ROLES', 625);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_GROUPS', 650);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_GROUP_ACCESS_FILTERS', 670);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_APP_USERS_GROUPS', 660);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_FILTERS', 680);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_LAYOUTS', 690);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PARAMTRS', 400);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('DATADICT', 410);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('PON_COPTIONS', 430);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('COPTIONS', 420);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_ATTRIBUTE_DESCRIPTOR', 100);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_DOCUMENTS', 260);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_LOAD_RATINGS', 230);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_NBI_RATING_HISTORY', 300);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_QAQC_REVIEW_FINDINGS', 240);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_QAQC_REVIEW_FLAGS', 250);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_USERS', 200);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_INSPECTIONS', 220);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_BRIDGE', 210);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_KBLRP_CONTRACTS', 310);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_EXCLUDED_STRUCTURES', 320);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_FORM_TABS', 330);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_DESIGN_MATERIAL_LOOKUP', 340);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_PON_APP_GROUP_CONTACTS', 350);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_REPORTS', 360);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KDOTBLP_VALDN_RESULTS', 370);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('KIND_CODE_LABELS', 380);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('LOOKUP_MAT_DESIGN_APPR_TYPE', 390);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('LOOKUP_MAT_DESIGN_MAIN_TYPE', 395);
insert into KDOTBLP_PORTAL_TABLES (table_name, processing_order)
values ('LR_VEHICLE_DEFS', 235);
commit;
prompt 34 records loaded

set feedback on
set define on
prompt Done
