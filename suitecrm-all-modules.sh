#!/bin/bash
DATE=`date +%Y-%m-%d`
OLD=`date -d "1 day ago" +%Y-%m-%d`
MSQLUSR=USR
MSQLPSWD=PSWD
PSWD=PSWD
CRM=BASE

#mysql --user=$MSQLUSR --password=$MSQLPSWD <<SUGAR
#create database sugar;
#exit
#SUGAR
sshpass -p $PSWD scp USER@HOST:/tmp/mysql-dump-sugarcrm-$DATE.sql.bz2 /home/test/temp/
 if [ $? -eq 0 ]
  then
   bunzip2 /home/test/temp/mysql-dump-sugarcrm-$DATE.sql.bz2 
   mysql --user=$MSQLUSR --password=$MSQLPSWD $CRM < /home/test/temp/mysql-dump-sugarcrm-$DATE.sql
   rm -f /home/test/temp/mysql-dump-sugarcrm-$DATE.sql
  else
   sshpass -p $PSWD scp USER@HOST:/tmp/mysql-dump-sugarcrm-$OLD.sql.bz2 /home/test/temp/
   bunzip2 /home/test/temp/mysql-dump-sugarcrm-$OLD.sql.bz2 
   mysql --user=$MSQLUSR --password=$MSQLPSWD $CRM < /home/test/temp/mysql-dump-sugarcrm-$OLD.sql
   rm -f /home/test/temp/mysql-dump-sugarcrm-$OLD.sql
 fi
service apache2 stop
mysql --user=$MSQLUSR --password=$MSQLPSWD <<SUITECRM 



#########################################################
#                  "ЗАЯВКИ НА ОСМОТР"                   #
#########################################################



# очитстка "Заявок на осмотр"
USE suitecrm;
TRUNCATE ra_request_survey;

# заполнение базы модуля "Заявки на осмотр"
USE sugar;
INSERT INTO
 suitecrm.ra_request_survey (id, name, date_entered, date_modified, modified_user_id, created_by,
 comment_request, deleted, assigned_user_id, address, contact, status, comment_survey, request_date, addressmap, survey_date, resolution,
 comment_ess, status_ess, comment_rs, status_rs, source_survey) 
SELECT
 ra_survey.id, ra_survey.name, ra_survey.date_entered, ra_survey.date_modified, ra_survey.modified_user_id,
 ra_survey.created_by, ra_survey.description, ra_survey.deleted, ra_survey.assigned_user_id, ra_survey.address,
 ra_survey.contact, ra_survey.status, ra_survey.description_survey, ra_survey.date_request, ra_survey.addressmap, ra_survey.date_survey, ra_survey.resolution,
 ra_survey_cstm.ess_comment_c, ra_survey_cstm.permit_installation_c, ra_survey_cstm.comment_rs_c, ra_survey_cstm.status_rs_c, ra_survey_cstm.source_inf_c
FROM ra_survey, ra_survey_cstm
WHERE ra_survey.id=ra_survey_cstm.id_c;

# Исправление несоответсвий в полях дроплистов между шугой и сюит
USE suitecrm; 
UPDATE ra_request_survey
 SET status_ess='pending' 
 WHERE status_ess='defer';

USE suitecrm;
UPDATE ra_request_survey
 SET status_ess='in_work'
 WHERE status_ess='none';

USE suitecrm;
UPDATE ra_request_survey
 SET status_rs='in_work'
 WHERE status_rs='none';



####################################################
#                    "ПОЛЬЗОВАТЕЛИ"                #
####################################################



# чистка "Пользователи"(кроме админской учетки)
USE suitecrm;
DELETE FROM suitecrm.users WHERE users.id!=1;

# заполнение базы "Пользователи"
USE sugar;
INSERT INTO
 suitecrm.users (id, user_name, user_hash, system_generated_password, pwd_last_changed, authenticate_id, sugar_login,
 first_name, last_name, is_admin, external_auth_only, receive_notifications, description, date_entered, date_modified,
 modified_user_id, created_by, title, department, phone_home, phone_mobile, phone_work, phone_other, phone_fax,
 status, address_street, address_city, address_state, address_country, address_postalcode, deleted, portal_only,
 show_on_employees, employee_status, messenger_id, messenger_type, reports_to_id, is_group) 
SELECT
 users.id, users.user_name, users.user_hash, users.system_generated_password, users.pwd_last_changed, users.authenticate_id, users.sugar_login, 
 users.first_name, users.last_name, users.is_admin, users.external_auth_only, users.receive_notifications, users.description, users.date_entered, users.date_modified, 
 users.modified_user_id, users.created_by, users.title, users.department, users.phone_home, users.phone_mobile, users.phone_work, users.phone_other, users.phone_fax, 
 users.status, users.address_street, users.address_city, users.address_state, users.address_country, users.address_postalcode, users.deleted, users.portal_only, 
 users.show_on_employees, users.employee_status, users.messenger_id, users.messenger_type, users.reports_to_id, users.is_group
FROM users
WHERE users.id=users.id and users.id!=1;

# чистка "users_cstm"(кроме админской учетки)
USE suitecrm;
DELETE FROM suitecrm.users_cstm WHERE users_cstm.id_c!=1;

# заполнение "users_cstm"
USE sugar;
INSERT INTO
 suitecrm.users_cstm (id_c, department_droplist_c)
SELECT
 users_cstm.id_c, users_cstm.dept_c
FROM users_cstm
WHERE users_cstm.id_c=users_cstm.id_c AND users_cstm.id_c!=1;

# исправление несоответсвий дроплиста между шугой и сюит
USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='ess' 
 WHERE department_droplist_c='ESS';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='pd' 
 WHERE department_droplist_c='PD';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='radio' 
 WHERE department_droplist_c='Radio';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='voice' 
 WHERE department_droplist_c='Voice';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='abonentskiy' 
 WHERE department_droplist_c='abon';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='sellers' 
 WHERE department_droplist_c='sales';

USE suitecrm; 
UPDATE users_cstm
 SET department_droplist_c='dismissed' 
 WHERE department_droplist_c='Dismissed';



#########################################################
#                      "EMAILS"                         #
#########################################################



# очитстка "Мэйлов"
USE suitecrm;
TRUNCATE email_addresses;
USE suitecrm;
TRUNCATE email_addr_bean_rel;

# копируем мэйлы пользователей (и абонентов?)
USE sugar;
INSERT INTO suitecrm.email_addresses
SELECT * from sugar.email_addresses;

USE sugar;
INSERT INTO suitecrm.email_addr_bean_rel
SELECT * from sugar.email_addr_bean_rel 
WHERE email_addr_bean_rel.id=email_addr_bean_rel.id;



##########################################################
#                       "АККАУНТЫ"                       #
##########################################################



# чистим таблицу "Контрагентов"
USE suitecrm;
TRUNCATE accounts;

# заполняем таблицу "Контрагентов"
USE sugar;
INSERT INTO suitecrm.accounts
SELECT * from sugar.accounts;

# чистим таблицу "accounts_cstm"
USE suitecrm;
TRUNCATE accounts_cstm;

# заполняем таблицу "accounts_cstm"
USE sugar;
INSERT INTO
 suitecrm.accounts_cstm (id_c, acc_actual_phone_c, acc_date_closed_c, acc_date_stoped_c,
 acc_login_c, acc_priority_c, acc_status_c, acc_tiket_phone_c, acc_type_c)
SELECT
 accounts_cstm.id_c, accounts_cstm.phone_new_c, accounts_cstm.date_close_acc_c,
 accounts_cstm.date_blockletter_acc_c, accounts_cstm.login_ph_c, accounts_cstm.priority_acc_c,
 accounts_cstm.status_acc_c, accounts_cstm.phone_from_bug_c,  accounts_cstm.company_acc_c
FROM accounts_cstm
WHERE accounts_cstm.id_c=accounts_cstm.id_c;

# исправление несоответствий в дроплисте между шугой и сюит
USE suitecrm; 
UPDATE accounts_cstm
 SET acc_type_c='organisation' 
 WHERE acc_type_c='1';

USE suitecrm; 
UPDATE accounts_cstm
 SET acc_type_c = null
 WHERE acc_type_c='0';



############################################################
#                       "ТИКЕТЫ"                           #
############################################################



# чистим таблицу "Тикетов(bugs)"
USE suitecrm;
TRUNCATE bugs;

# заполняем таблицу "Тикетов(bugs)"
USE sugar;
INSERT INTO suitecrm.bugs
SELECT * from sugar.bugs;

# чистим таблицу "bugs_cstm"
USE suitecrm;
TRUNCATE bugs_cstm;

# заполняем таблицу "bugs_cstm" (без старых причин закрытия)
USE sugar;
INSERT INTO
 suitecrm.bugs_cstm (id_c, account_id_c, bugs_todo_c, bugs_phone_c, bugs_address_c, bugs_type_c,
 bug_id_c, bugs_visit_c, bugs_reson_closed_c, bugs_duration_min_c, bugs_duration_hour_c, bugs_delivered_c)
SELECT
 bugs_cstm.id_c, bugs_cstm.account_id_c, bugs_cstm.todo_c, bugs_cstm.phone_bugs_c, bugs_cstm.address_bugs_c, bugs_cstm.type_bugs_c,
 bugs_cstm.bug_id_c, bugs_cstm.departure_bugs_c, bugs_cstm.new_reason_for_closure_bugs_c, bugs_cstm.duration_min_c,
 bugs_cstm.duration_bug_c, bugs_cstm.service_is_delivered_c
FROM bugs_cstm
WHERE id_c=id_c;
# заполняем старые причины закрытия в таблице "bugs_cstm"
USE suitecrm;
UPDATE suitecrm.bugs_cstm, sugar.bugs_cstm
 SET suitecrm.bugs_cstm.bugs_reson_closed_c=sugar.bugs_cstm.reason_for_closure_bugs_c
 WHERE suitecrm.bugs_cstm.id_c=sugar.bugs_cstm.id_c
 AND sugar.bugs_cstm.reason_for_closure_bugs_c!='';

# заполняем поля "status" находящиеся в разных таблицах
USE suitecrm;
UPDATE suitecrm.bugs, sugar.bugs_cstm 
 SET suitecrm.bugs.status=sugar.bugs_cstm.status_bugs_c
 WHERE suitecrm.bugs.id=sugar.bugs_cstm.id_c;
# заполняем поля "приоритет" находящиеся в разных таблицах
USE suitecrm;
UPDATE suitecrm.bugs, sugar.bugs_cstm 
 SET suitecrm.bugs.priority=sugar.bugs_cstm.new_priority_bugs_c
 WHERE suitecrm.bugs.id=sugar.bugs_cstm.id_c;

# исправление несоответсвий дроплиста "приоритет" между шугой и сюит
USE suitecrm; 
UPDATE bugs 
 SET priority='low' 
 WHERE priority='one';

USE suitecrm; 
UPDATE bugs 
 SET priority='high' 
 WHERE priority='two';

USE suitecrm; 
UPDATE bugs 
 SET priority='plan' 
 WHERE priority='three';

# исправление несоответсвий дпроплиста "тип" между шугой и сюит
USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='speed_ping' 
 WHERE bugs_type_c='one';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='unavilable' 
 WHERE bugs_type_c='two';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='other' 
 WHERE bugs_type_c='three';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='remontage' 
 WHERE bugs_type_c='four';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='adjusting' 
 WHERE bugs_type_c='five';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='user_bug' 
 WHERE bugs_type_c='seven';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='user_network' 
 WHERE bugs_type_c='eight';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='pdcpgi' 
 WHERE bugs_type_c='six';

USE suitecrm; 
UPDATE bugs_cstm
 SET bugs_type_c='phone' 
 WHERE bugs_type_c='nine';

# заполняем мультиселекты в "bugs_cstm"
USE suitecrm;
UPDATE
 suitecrm.bugs_cstm, sugar.bugs_cstm
SET
 suitecrm.bugs_cstm.bugs_localisation_c=sugar.bugs_cstm.localisation_c,
 suitecrm.bugs_cstm.bugs_perform_c=sugar.bugs_cstm.perform_c,
 suitecrm.bugs_cstm.bugs_department_c=sugar.bugs_cstm.department_bugs_c
WHERE
 suitecrm.bugs_cstm.id_c=sugar.bugs_cstm.id_c;

# исправляем несоответсвия в полях мультиселекта между шугой и сюит
USE suitecrm;
UPDATE bugs_cstm
SET bugs_localisation_c= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
(REPLACE(bugs_localisation_c, '^WiFi^', '^wifi^'), '^PC^', '^pc^'), '^TV^', '^tv^'),
 '^AS^', '^as^'), '^BS^', '^bs^'), '^backbone_network^', '^magistral^'), '^center_PD^',
 '^center_pd^'), '^ATA^', '^ata^'), '^no_bug^', '^no_bugs^');
USE suitecrm;
UPDATE bugs_cstm
SET bugs_perform_c=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(bugs_perform_c,
 '^replace_ATA^', '^replace_ata^'), '^adjusting_rt^', '^adjusting^'), '^perform_grout_RS^', '^perform_group_rs^'),
 '^perform_group_PD^', '^perform_group_pd^'), '^perform_group_GS^', '^perform_group_phone^'),
 '^consultation_ESS^', '^consultation_ess^'), '^transfer_to_other_BS^', '^transfer_to_other_bs^');
USE suitecrm;
UPDATE bugs_cstm
SET bugs_department_c= REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
(REPLACE(REPLACE(REPLACE(bugs_department_c, 'tp', '^tp^'), 'pd', '^pd^'), 'tf', '^phone^'),
 'rs', '^rs^'), 'UO', '^uo^'), 'fo', '^fo^'), 'OM', '^om^'), 'razv', '^razv^'), 'plan', '^plan^'),
 'VNTV', '^tv_vn^'), 'sogl', '^sogl^'), 'oms', '^oms^');



#####################################################################################
#                              "Комментарии к тикетнице"                            #
#####################################################################################



# чистим таблицу "связей коментариев"
USE suitecrm;
TRUNCATE c_bug_comments_bugs_c;
# заполняем таблицу "связей Коментариев"
USE sugar;
INSERT INTO
 suitecrm.c_bug_comments_bugs_c (id, date_modified, deleted, c_bug_comments_bugsbugs_ida, c_bug_comments_bugsc_bug_comments_idb)
SELECT
 bugs_c_bug_comments_1_c.id, bugs_c_bug_comments_1_c.date_modified, bugs_c_bug_comments_1_c.deleted,
 bugs_c_bug_comments_1_c.bugs_c_bug_comments_1bugs_ida, bugs_c_bug_comments_1_c.bugs_c_bug_comments_1c_bug_comments_idb
FROM bugs_c_bug_comments_1_c
WHERE id=id;

# чистим таблицу "Комментариев тикетов"
USE suitecrm;
TRUNCATE c_bug_comments;
# заполняем таблицу "Комментариев тикетов(bugs)"
USE sugar;
INSERT INTO suitecrm.c_bug_comments
SELECT * FROM sugar.c_bug_comments;



######################################################################################
#                             "План подключений"                                     #
######################################################################################



# чистим таблицу "План подключений"
USE suitecrm;
TRUNCATE con_p_connection_plan;
# заполняем таблицу "План подключений (без фото)"
USE sugar;
INSERT INTO
 suitecrm.con_p_connection_plan (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 account_id_c, address_plan, base_station, work_category, comment_mount, contacts, date_connetcion, enter_roof, ip_address, device_given,
 description_job, level_signal, number_contract, point_address, user_id_c, radio_point, remarks, status_connection, ra_request_survey_id_c,
 tarif_plan, time_connection, type_connection, type_device, photo_1, photo_2, photo_3, photo_4, user_id1_c, user_id2_c, user_id3_c)
SELECT
 con_p_connections_plan.id, con_p_connections_plan.name, con_p_connections_plan.date_entered, con_p_connections_plan.date_modified,
 con_p_connections_plan.modified_user_id, con_p_connections_plan.created_by, con_p_connections_plan.description, con_p_connections_plan.deleted, con_p_connections_plan.assigned_user_id,
 con_p_connections_plan_cstm.account_id_c, con_p_connections_plan_cstm.address_plan_c, con_p_connections_plan_cstm.base_station_c, con_p_connections_plan_cstm.cat_work_c,
 con_p_connections_plan_cstm.comment_mount_c, con_p_connections_plan_cstm.contacts_c, con_p_connections_plan_cstm.date_connection_c, con_p_connections_plan_cstm.enter_roof_c,
 con_p_connections_plan_cstm.ip_address_c, con_p_connections_plan_cstm.issued_hard_c, con_p_connections_plan_cstm.job_list_c, con_p_connections_plan_cstm.level_signal_c,
 con_p_connections_plan_cstm.number_opp_c, con_p_connections_plan_cstm.point_address_c, con_p_connections_plan_cstm.user_id_c, con_p_connections_plan_cstm.radio_c,
 con_p_connections_plan_cstm.remarks_c, con_p_connections_plan_cstm.status_mount_c, con_p_connections_plan_cstm.ra_survey_id_c, con_p_connections_plan_cstm.tariff_plan_c,
 con_p_connections_plan_cstm.time_connection_c, con_p_connections_plan_cstm.type_conn_c, con_p_connections_plan_cstm.type_hard_c,
 con_p_connections_plan_cstm.photo_one_c, con_p_connections_plan_cstm.photo_two_c, con_p_connections_plan_cstm.photo_three_c, con_p_connections_plan_cstm.photo_four_c,
 con_p_connections_plan_cstm.user_id1_c, con_p_connections_plan_cstm.user_id2_c, con_p_connections_plan_cstm.user_id3_c
FROM
 con_p_connections_plan, con_p_connections_plan_cstm
WHERE
 con_p_connections_plan_cstm.id_c=con_p_connections_plan.id;

# исправляем несоответсвия в выпадающих списках
USE suitecrm;
UPDATE con_p_connection_plan
SET type_connection=REPLACE(REPLACE(REPLACE(REPLACE(type_connection, 'ur', 'urik'), 'app', 'multifamily'), 'private', 'cottage'), 'rab', 'work');

USE suitecrm;
UPDATE con_p_connection_plan
SET status_connection=REPLACE(REPLACE(REPLACE(REPLACE(status_connection, '1', 'survey'), '2', 'done'), '3', 'another_day'), '4', 'deny');

USE suitecrm;
UPDATE con_p_connection_plan
SET work_category =
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
(work_category, '25', 'controll_energy'), '23', 'adjusting'), '24', 'damontage'), '22', 'organisation_setting_network'),
'20', 'qualification'), '19', 'rtpc'), '18', 'act'), '15', 'cable_by_air'), '14', 'survey'), '12', 'install_base'),
'11', 'install_locker'), '10', 'transportation'), '9', 'delivery'), '8', 'not_qualification'), '7', 'repair'), '6', 'install'),
'5', 'swap'), '4', 'migrate'), '3', 'cottage'), '2', 'physics'), '1', 'organisation');

# приводим фото "плана подключний" к нужному виду
USE suitecrm;
UPDATE con_p_connection_plan
SET photo_1='photo_1'
WHERE photo_1 is not null and photo_1!='';

USE suitecrm;
UPDATE con_p_connection_plan
SET photo_2='photo_2'
WHERE photo_2 is not null and photo_2!='';

USE suitecrm;
UPDATE con_p_connection_plan
SET photo_3='photo_3'
WHERE photo_3 is not null and photo_3!='';

USE suitecrm;
UPDATE con_p_connection_plan
SET photo_4='photo_4'
WHERE photo_4 is not null and photo_4!='';
# ниже после MYSQL запросов лежат необходимые операции с фото для того чтобы они подцепились



##############################################################################################
#                               "Ремонтные работы"                                           #
##############################################################################################



# чистим таблицу "Ремонтные работы"
USE suitecrm;
TRUNCATE rep_repair_works;
# заполняем таблицу "Ремонтные работы"
USE sugar;
INSERT INTO
 suitecrm.rep_repair_works (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 address, time, date_repair, work_category, comment, contacts, user_id_c, user_id1_c, user_id2_c, account_id_c,
 rapair_work_photo_1, rapair_work_photo_2, rapair_work_photo_3, rapair_work_photo_4, rapair_work_photo_5, rapair_work_photo_6,
 status_repair)
SELECT
 rep_repairs.id, rep_repairs.name, rep_repairs.date_entered, rep_repairs.date_modified, rep_repairs.modified_user_id,
 rep_repairs.created_by, rep_repairs.description, rep_repairs.deleted, rep_repairs.assigned_user_id,
 rep_repairs_cstm.address_c, rep_repairs_cstm.time_c, rep_repairs_cstm.date_of_completion_c, rep_repairs_cstm.cat_work_c,
 rep_repairs_cstm.comment_c, rep_repairs_cstm.contacts_c, rep_repairs_cstm.user_id2_c, rep_repairs_cstm.user_id_c, rep_repairs_cstm.user_id1_c,
 rep_repairs_cstm.account_id_c,
 rep_repairs_cstm.photo_one_c, rep_repairs_cstm.photo_two_c, rep_repairs_cstm.photo_three_c, rep_repairs_cstm.photo_four_c,
 rep_repairs_cstm.photo_five_c, rep_repairs_cstm.photo_six_c, rep_repairs_cstm.status_c
FROM 
 rep_repairs, rep_repairs_cstm
WHERE
 rep_repairs.id=rep_repairs_cstm.id_c;
# исправляем несоответсвия в выпадающем списке "Категория работ"
USE suitecrm;
UPDATE rep_repair_works
SET work_category =
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
(work_category, '25', 'controll_energy'), '23', 'adjusting'), '24', 'damontage'), '22', 'organisation_setting_network'),
'20', 'qualification'), '19', 'rtpc'), '18', 'act'), '15', 'cable_by_air'), '14', 'survey'), '12', 'install_base'),
'11', 'install_locker'), '10', 'transportation'), '9', 'delivery'), '8', 'not_qualification'), '7', 'repair'), '6', 'install'),
'5', 'swap'), '4', 'migrate'), '3', 'cottage'), '2', 'physics'), '1', 'organisation');

# исправляем несоответствия в выподающем списке "Статус работы"
USE suitecrm;
UPDATE rep_repair_works
SET status_repair=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(status_repair, 'one', 'survey'), 'two', 'accept'), 'three', 'pending'), 'four', 'done'), 'five', 'deny');

# чистим таблицу "Связей с тикетницей"
USE suitecrm;
TRUNCATE rep_repair_works_bugs_c;
# устанавливаем связи с "Тикетницей"
USE sugar;
INSERT INTO
 suitecrm.rep_repair_works_bugs_c (id, date_modified, deleted, rep_repair_works_bugsbugs_ida, rep_repair_works_bugsrep_repair_works_idb)
SELECT
 rep_repairs_bugs_1_c.id, rep_repairs_bugs_1_c.date_modified, rep_repairs_bugs_1_c.deleted,
 rep_repairs_bugs_1_c.rep_repairs_bugs_1rep_repairs_ida, rep_repairs_bugs_1_c.rep_repairs_bugs_1bugs_idb
FROM rep_repairs_bugs_1_c
WHERE id=id;

# приводим фото "Ремонтных работ" к нужному виду
USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_1='rapair_work_photo_1'
WHERE rapair_work_photo_1 is not null and rapair_work_photo_1!='';

USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_2='rapair_work_photo_2'
WHERE rapair_work_photo_2 is not null and rapair_work_photo_2!='';

USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_3='rapair_work_photo_3'
WHERE rapair_work_photo_3 is not null and rapair_work_photo_3!='';

USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_4='rapair_work_photo_4'
WHERE rapair_work_photo_4 is not null and rapair_work_photo_4!='';

USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_5='rapair_work_photo_5'
WHERE rapair_work_photo_5 is not null and rapair_work_photo_5!='';

USE suitecrm;
UPDATE rep_repair_works
SET rapair_work_photo_6='rapair_work_photo_6'
WHERE rapair_work_photo_6 is not null and rapair_work_photo_6!='';



#####################################################################################################
#                               "Пользовательское оборудование"                                     #
#####################################################################################################



# чистим атаблицу "Пользовательское оборудование"
USE suitecrm;
TRUNCATE po_oborudovanie;
# заполняем таблицу "Пользовательское оборудование"
USE sugar;
INSERT INTO
 suitecrm.po_oborudovanie (id, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 account_id_c, type, status_po, inventory_number)
SELECT
 po_po.id, po_po.date_entered, po_po.date_modified, po_po.modified_user_id, po_po.created_by, po_po.description, po_po.deleted,
 po_po.assigned_user_id,
 po_po_cstm.account_id_c, po_po_cstm.hardware_types_c, po_po_cstm.status_c, po_po_cstm.invnum_c
FROM po_po, po_po_cstm
WHERE id=id_c;
# исправвляем несоответсвия в дроплистах между шугой и сюит
USE suitecrm;
UPDATE po_oborudovanie
SET status_po = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(status_po, 'one', 'installed'),
 'two', 'need_demontage'), 'three', 'sklad'), 'four', 'in_repair'), 'five', 'break_down'), 'six', 'shipped_repair'), 'seven', 'discarded');

# чистим таблицу связей с "Контрагентами"
USE suitecrm;
TRUNCATE po_oborudovanie_accounts_c;
# заполняем таблицу связей с "Контрагентами"
USE sugar;
INSERT INTO
 suitecrm.po_oborudovanie_accounts_c (id, date_modified, deleted, po_oborudovanie_accountsaccounts_ida, po_oborudovanie_accountspo_oborudovanie_idb)
SELECT
 accounts_po_po_1_c.id, accounts_po_po_1_c.date_modified, accounts_po_po_1_c.deleted, accounts_po_po_1_c.accounts_po_po_1accounts_ida, accounts_po_po_1_c.accounts_po_po_1po_po_idb
FROM accounts_po_po_1_c
WHERE id=id;
# приравниваем "Name" к "Инвентарному номеру"
USE suitecrm;
UPDATE po_oborudovanie SET name=inventory_number;



####################################################################################
#                                   "Контакты"                                     #
####################################################################################



# чистим таблицу "Контакты"
USE suitecrm;
TRUNCATE contacts;
# заполняем таблицу "Контакты"
USE sugar;
INSERT INTO
 suitecrm.contacts (id, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, salutation, first_name, last_name, title,
 department, do_not_call, phone_home, phone_mobile, phone_work, phone_other, phone_fax, primary_address_street, primary_address_city, primary_address_state,
 primary_address_postalcode, primary_address_country, alt_address_street, alt_address_city, alt_address_state, alt_address_postalcode, alt_address_country,
 assistant, assistant_phone, lead_source, reports_to_id, birthdate, campaign_id)
SELECT
 contacts.id, contacts.date_entered, contacts.date_modified, contacts.modified_user_id, contacts.created_by, contacts.description, contacts.deleted, contacts.assigned_user_id,
 contacts.salutation, contacts.first_name, contacts.last_name, contacts.title, contacts.department, contacts.do_not_call, contacts.phone_home, contacts.phone_mobile,
 contacts.phone_work, contacts.phone_other, contacts.phone_fax, contacts.primary_address_street, contacts.primary_address_city, contacts.primary_address_state,
 contacts.primary_address_postalcode, contacts.primary_address_country, contacts.alt_address_street, contacts.alt_address_city, contacts.alt_address_state, contacts.alt_address_postalcode,
 contacts.alt_address_country, contacts.assistant, contacts.assistant_phone, contacts.lead_source, contacts.reports_to_id, contacts.birthdate, contacts.campaign_id
FROM contacts
WHERE id=id;



##############################################################################################
#                                    "Опросы клиентов"                                       #
##############################################################################################



# чистим таблицу "Опросы клиентов"
USE suitecrm;
TRUNCATE qu_question;
# заполняем таблицу "Опросы клиентов"
USE sugar;
INSERT INTO
 suitecrm.qu_question (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, type_question,
 date_question, account_id_c, quality_client, phone, user_id_c, support_calls, install, seller, support, service_problem)
SELECT
 qu_question.id, qu_question.name, qu_question.date_entered, qu_question.date_modified, qu_question.modified_user_id, qu_question.created_by,
 qu_question.description, qu_question.deleted, qu_question.assigned_user_id, qu_question.type, qu_question.date_question, qu_question.account_id_c,
 qu_question.quality_client, qu_question.user_accounts, qu_question.user_id_c, qu_question.support_calls, qu_question.install, qu_question.sell,
 qu_question.support, qu_question.service_problem
FROM qu_question
WHERE id=id;

# чистим таблицу связей "Опросов клиентов" с "Контрагентами"
USE suitecrm;
TRUNCATE  qu_question_accounts_c;
# заполнряем таблицу связей "Опросов клиентов" с "Контрагентами"
USE sugar;
INSERT INTO
 suitecrm.qu_question_accounts_c (id, date_modified, deleted, qu_question_accountsaccounts_ida, qu_question_accountsqu_question_idb)
SELECT
 qu_question_accounts_c.id, qu_question_accounts_c.date_modified, qu_question_accounts_c.deleted,
 qu_question_accounts_c.qu_question_accountsaccounts_idb, qu_question_accounts_c.qu_question_accountsqu_question_ida
FROM qu_question_accounts_c
WHERE id=id;



#############################################################################################
#                                        "Задачи"                                           #
#############################################################################################



# чистим таблицу "Задачи"
USE suitecrm;
TRUNCATE tasks;
# заполняем таблицу "Задачи"
USE sugar;
INSERT INTO suitecrm.tasks
SELECT * FROM sugar.tasks;

# чистим таблицу связей "Задачи" с "Контрагентами"
USE suitecrm;
TRUNCATE accounts_tasks_1_c;
# заполняем таблицу связей "Задачи" с "Контрагентами" (при таком заполнении id в таблице со связями совпадает с id в таблице задач (в дальнейшем это исправляется)
USE sugar;
INSERT INTO
 suitecrm.accounts_tasks_1_c (id, date_modified, accounts_tasks_1accounts_ida, accounts_tasks_1tasks_idb)
SELECT
 tasks.id, tasks.date_modified, tasks.parent_id, tasks.id
FROM tasks;
# меняем id в тблице со связями на новые уникальные
USE suitecrm;
UPDATE
 accounts_tasks_1_c
SET
 accounts_tasks_1_c.id=uuid ();



####################################################################################################
#                                         "Работы"                                                 #
####################################################################################################



# читсим таблицу "Работы"
USE suitecrm;
TRUNCATE ac_action;
# заполняем таблицу "Работы"
USE sugar;
INSERT INTO
 suitecrm.ac_action (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 status, plan_action_date, no_service, plan_no_service, start_action_date, plan_duration, duration, adress, goal, comment)
SELECT
 ra_actions.id, ra_actions.name, ra_actions.date_entered, ra_actions.date_modified, ra_actions.modified_user_id,
 ra_actions.created_by, ra_actions.description, ra_actions.deleted, ra_actions.assigned_user_id,
 ra_actions.status, ra_actions.planactiondate, ra_actions.noservice, ra_actions.plannoservice, ra_actions.actiondate,
 ra_actions.planduration, ra_actions.duration, ra_actions.address, ra_actions.goal, ra_actions.comment
FROM ra_actions;



#####################################################################################################
#                                           "Заметки"                                               #
#####################################################################################################



# чисим таблицу модуля "Заметки"
USE suitecrm;
TRUNCATE notes;
# заполняем таблицу модуля "Заметки"
USE sugar;
INSERT INTO
 suitecrm.notes
SELECT
 *
FROM
 sugar.notes;
# чистим таблицу связей "Заметок" с "Работами"
USE suitecrm;
TRUNCATE ac_action_notes_c;
# заполняем таблицу связей "Заметок" с "Работами"
USE sugar;
INSERT INTO
 suitecrm.ac_action_notes_c (id, date_modified, deleted, ac_action_notesac_action_ida, ac_action_notesnotes_idb)
SELECT
 ra_actions_notes_c.id, ra_actions_notes_c.date_modified, ra_actions_notes_c.deleted,
 ra_actions_notes_c.ra_actions_notesra_actions_ida, ra_actions_notes_c.ra_actions_notesnotes_idb
FROM ra_actions_notes_c;
# чистим таблицу связей с "Заявками на осмотр"
USE suitecrm;
TRUNCATE ra_request_survey_notes_c;
# заполняем таблицу связей с "Заявками на осмотр"
USE sugar;
INSERT INTO
 suitecrm.ra_request_survey_notes_c (id, date_modified, deleted, ra_request_survey_notesra_request_survey_ida, ra_request_survey_notesnotes_idb)
SELECT
 ra_survey_notes_c.id, ra_survey_notes_c.date_modified, ra_survey_notes_c.deleted,
 ra_survey_notes_c.ra_survey_notesra_survey_ida, ra_survey_notes_c.ra_survey_notesra_survey_ida
FROM ra_survey_notes_c;
# чистим таблицу связей "Заметок" с "Ремонтными работами"
USE suitecrm;
TRUNCATE rep_repair_works_notes_c;
# заполняем таблицу связей "Заметок" с "Ремонтными работами"
USE sugar;
INSERT INTO
 suitecrm.rep_repair_works_notes_c (id, date_modified, deleted, rep_repair_works_notesrep_repair_works_ida, rep_repair_works_notesnotes_idb)
SELECT
 rep_repairs_notes_1_c.id, rep_repairs_notes_1_c.date_modified, rep_repairs_notes_1_c.deleted,
 rep_repairs_notes_1_c.rep_repairs_notes_1rep_repairs_ida, rep_repairs_notes_1_c.rep_repairs_notes_1notes_idb
FROM
 rep_repairs_notes_1_c;
# чистим таблицу связей "Заметок" с "Корреспонденцией"
USE suitecrm;
TRUNCATE let_letters_notes_c ;
# заполняем таблицу связей "Заметок" с "Коррепонденцией"
USE sugar;
INSERT INTO
 suitecrm.let_letters_notes_c (id, date_modified, deleted, let_letters_noteslet_letters_ida, let_letters_notesnotes_idb)
SELECT
 let_letters_notes_c.id, let_letters_notes_c.date_modified, let_letters_notes_c.deleted, let_letters_notes_c.let_letters_noteslet_letters_ida, let_letters_notes_c.let_letters_notesnotes_idb
FROM
 let_letters_notes_c;

#############################################
#       "Корреспонденция исходящая"         # #Если решат что не нужно разделять входящую и исхдящую по модулям, то не переносить
#############################################
USE suitecrm;
TRUNCATE let_letters_output_notes_c ;

USE sugar;
INSERT INTO
 suitecrm.let_letters_output_notes_c (id, date_modified, deleted, let_letters_output_noteslet_letters_output_ida, let_letters_output_notesnotes_idb)
SELECT
 let_letters_notes_c.id, let_letters_notes_c.date_modified, let_letters_notes_c.deleted, let_letters_notes_c.let_letters_noteslet_letters_ida, let_letters_notes_c.let_letters_notesnotes_idb
FROM
 let_letters_notes_c;


###############################################################################################
#                                    "Корреспонденция"                                        #
###############################################################################################



# чистим таблицу модуля "Корреспонденция"
USE suitecrm;
TRUNCATE  let_letters;
# заполняем таблицу модуля "Корреспонденция"
USE sugar;
INSERT INTO
 suitecrm.let_letters (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, organisation, type_letter,
 input_number, output_number, input_date, output_date, letter_from, letter_for, performer, number_letter)
SELECT
 let_letters.id, let_letters.name, let_letters.date_entered, let_letters.date_modified, let_letters.modified_user_id, let_letters.created_by, let_letters.description,
 let_letters.deleted, let_letters.assigned_user_id, let_letters.organization, let_letters.typeletters, let_letters.inputnumber, let_letters.outputnumber,
 let_letters.inputdate, let_letters.outputdate, let_letters.let_from, let_letters.let_to, let_letters.performer, let_letters_cstm.number_kor_new_c
FROM
 let_letters, let_letters_cstm
WHERE
 let_letters.id=let_letters_cstm.id_c;

#############################################
#       "Корреспонденция исходящая"         # #Если решат что не нужно разделять входящую и исхдящую по модулям, то не переносить
#############################################
USE suitecrm;
TRUNCATE  let_letters_output;

USE sugar;
INSERT INTO
 suitecrm.let_letters_output (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, organisation, type_letter,
 input_number, output_number, input_date, output_date, letter_from, letter_for, performer, number_letter)
SELECT
 let_letters.id, let_letters.name, let_letters.date_entered, let_letters.date_modified, let_letters.modified_user_id, let_letters.created_by, let_letters.description,
 let_letters.deleted, let_letters.assigned_user_id, let_letters.organization, let_letters.typeletters, let_letters.inputnumber, let_letters.outputnumber,
 let_letters.inputdate, let_letters.outputdate, let_letters.let_from, let_letters.let_to, let_letters.performer, let_letters_cstm.number_kor_new_c
FROM
 let_letters, let_letters_cstm
WHERE
 let_letters.id=let_letters_cstm.id_c;
use suitecrm;
update let_letters_output
set deleted = "1" where type_letter = "input";
update let_letters
set deleted = "1" where type_letter = "output";


#################################################################################################
#                                     "Объекты сети"                                            #
#################################################################################################



# читсим таблицу "Объектов сети"
USE suitecrm;
TRUNCATE obj_n_objects_network;
# заполняем таблицу "Объектов сети"
USE sugar;
INSERT INTO
 suitecrm.obj_n_objects_network (id, name, date_entered, date_modified, modified_user_id, created_by,
 description, deleted, assigned_user_id, address_object, status_object, addressmap_object)
SELECT
 obj_n_net_obj.id, obj_n_net_obj.name, obj_n_net_obj.date_entered, obj_n_net_obj.date_modified, obj_n_net_obj.modified_user_id,
 obj_n_net_obj.created_by, obj_n_net_obj.description, obj_n_net_obj.deleted, obj_n_net_obj.assigned_user_id,
 obj_n_net_obj_cstm.address_obj_c, obj_n_net_obj_cstm.status_obj_c, obj_n_net_obj_cstm.address_map_obj_c
FROM
 obj_n_net_obj, obj_n_net_obj_cstm
WHERE
 obj_n_net_obj.id=obj_n_net_obj_cstm.id_c;
# чистим таблицу связей "Объектов сети" с "Оборудованием"
USE suitecrm;
TRUNCATE obj_n_objects_network_po_oborudovanie_c;
# заполняем таблицу связей "Объектов сети" с "Оборудованием"
USE sugar;
INSERT INTO
 suitecrm.obj_n_objects_network_po_oborudovanie_c (id, date_modified, deleted,
 obj_n_objects_network_po_oborudovanieobj_n_objects_network_ida, obj_n_objects_network_po_oborudovaniepo_oborudovanie_idb)
SELECT
 obj_n_net_obj_po_po_1_c.id, obj_n_net_obj_po_po_1_c.date_modified, obj_n_net_obj_po_po_1_c.deleted,
 obj_n_net_obj_po_po_1_c.obj_n_net_obj_po_po_1obj_n_net_obj_ida, obj_n_net_obj_po_po_1_c.obj_n_net_obj_po_po_1po_po_idb
FROM
 obj_n_net_obj_po_po_1_c;



################################################################################################
#                                      "Документы"                                             #
################################################################################################



# чистим таблицу "Документы"
USE suitecrm;
TRUNCATE documents;
# заоплняем таблицу "Документов"
USE sugar;
INSERT INTO
 suitecrm.documents
SELECT *FROM documents;
# чистим таблицу соответсвий файлов модуля "Документы"
USE suitecrm;
TRUNCATE document_revisions;
# заполняем таблицу соответсвий файлов модуля "Документы"
USE sugar;
INSERT INTO
 suitecrm.document_revisions
SELECT * FROM document_revisions;
# чистим таблицу связей "Документов" с "Объектами сети"
USE suitecrm;
TRUNCATE documents_obj_n_objects_network_1_c;
# заполняем таблицу связей "Документов" с "Объектами сети"
USE sugar;
INSERT INTO
 suitecrm.documents_obj_n_objects_network_1_c (id, date_modified, deleted, document_revision_id,
 documents_obj_n_objects_network_1documents_ida, documents_obj_n_objects_network_1obj_n_objects_network_idb)
SELECT
 obj_n_net_obj_documents_1_c.id, obj_n_net_obj_documents_1_c.date_modified, obj_n_net_obj_documents_1_c.deleted, obj_n_net_obj_documents_1_c.document_revision_id,
 obj_n_net_obj_documents_1_c.obj_n_net_obj_documents_1obj_n_net_obj_ida, obj_n_net_obj_documents_1_c.obj_n_net_obj_documents_1documents_idb
FROM
 obj_n_net_obj_documents_1_c;



################################################################################################
#                         "Претензии к организации доступа"                                    #
################################################################################################



# чистим таблицу "Претензий к оргназации доступа"
USE suitecrm;
TRUNCATE acc_access_errors;
# заполняем таблицу "Претензий к организации доступа"
USE sugar;
INSERT INTO
 suitecrm.acc_access_errors (id, name, date_entered, date_modified, modified_user_id, created_by, description,
 deleted, assigned_user_id, date_error, date_access, status_access)
SELECT
 acc_accesserror.id, acc_accesserror.name, acc_accesserror.date_entered, acc_accesserror.date_modified, acc_accesserror.modified_user_id,
 acc_accesserror.created_by, acc_accesserror.description, acc_accesserror.deleted, acc_accesserror.assigned_user_id,
 acc_accesserror.dateerror, acc_accesserror.dateaccess, acc_accesserror.status
FROM
 acc_accesserror;
# исправляем несоответсвия дропбоксов между шугой и сюит
USE suitecrm;
UPDATE acc_access_errors
SET status_access='deny'
WHERE status_access='reject';
# чистим таблицу связей "Претензий к организации доступа" с "Заметками"
USE suitecrm;
TRUNCATE acc_access_errors_notes_c;
# заполняем таблицу связей "Претензий к организации доступа" с "Заметками"
USE sugar;
INSERT INTO
 suitecrm.acc_access_errors_notes_c (id, date_modified, deleted, acc_access_errors_notesacc_access_errors_ida, acc_access_errors_notesnotes_idb)
SELECT
 acc_accesserror_notes_c.id, acc_accesserror_notes_c.date_modified, acc_accesserror_notes_c.deleted,
 acc_accesserror_notes_c.acc_accesserror_notesacc_accesserror_ida, acc_accesserror_notes_c.acc_accesserror_notesnotes_idb
FROM acc_accesserror_notes_c;



#################################################################################################
#                                       "Проишествия"                                           #
#################################################################################################



# чистим таблицу "Проишествий"
USE suitecrm;
TRUNCATE claim_claim;
# заполняем таблицу "Проишествий"
USE sugar;
INSERT INTO
 suitecrm.claim_claim (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, responsible_group, volume, date_claim)
SELECT
 ra_claim.id, ra_claim.name, ra_claim.date_entered, ra_claim.date_modified, ra_claim.modified_user_id, ra_claim.created_by, ra_claim.description, ra_claim.deleted, ra_claim.assigned_user_id,
 ra_claim.group_onus, ra_claim.volume, ra_claim.date_event
FROM
 ra_claim;
# чистим таблицу связей "Проишествий" с "Тикетами"
USE suitecrm;
TRUNCATE claim_claim_bugs_c;
# заполняем таблицу связей "Проишествий" с "Тикетами"
USE sugar;
INSERT INTO
 suitecrm.claim_claim_bugs_c (id, date_modified, deleted, claim_claim_bugsclaim_claim_ida, claim_claim_bugsbugs_idb)
SELECT
 ra_claim_bugs_1_c.id, ra_claim_bugs_1_c.date_modified, ra_claim_bugs_1_c.deleted,
 ra_claim_bugs_1_c.ra_claim_bugs_1ra_claim_ida, ra_claim_bugs_1_c.ra_claim_bugs_1bugs_idb
FROM
 ra_claim_bugs_1_c;
# чистим таблицу связей "Проишествий" с "Заметками"
USE suitecrm;
TRUNCATE claim_claim_notes_c;
# заполняем таблицу связей "Проишествий" с "Заметками"
USE sugar;
INSERT INTO
 suitecrm.claim_claim_notes_c (id, date_modified, deleted, claim_claim_notesclaim_claim_ida, claim_claim_notesnotes_idb)
SELECT
 ra_claim_notes_c.id, ra_claim_notes_c.date_modified, ra_claim_notes_c.deleted,
 ra_claim_notes_c.ra_claim_notesra_claim_ida, ra_claim_notes_c.ra_claim_notesnotes_idb
FROM
 ra_claim_notes_c;



##############################################################################################
#                        "Заявки на согласование доступа"                                    #
##############################################################################################



# чистим таблицу "Заявки на согласование доступа"
#USE suitecrm;
#TRUNCATE req_requisition;
# заполняем таблицу "Заявки на согласование доступа"
#USE sugar;
#INSERT INTO
# suitecrm.req_requisition (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, status_requisition, acces_mode_needed)
#SELECT
# acc_requisition.id, acc_requisition.name, acc_requisition.date_entered, acc_requisition.date_modified, acc_requisition.modified_user_id, acc_requisition.created_by,
# acc_requisition.description, acc_requisition.deleted, acc_requisition.assigned_user_id, acc_requisition.status, acc_requisition.accessmode
#FROM
# acc_requisition;
#USE suitecrm;
#UPDATE
# suitecrm.req_requisition, sugar.acc_requisition_cstm
#SET
# suitecrm.req_requisition.address_requisition=sugar.acc_requisition_cstm.address_sogl_c,
# suitecrm.req_requisition.acces_mode_requisition=sugar.acc_requisition_cstm.accessmodecheck_c,
# suitecrm.req_requisition.equipment=sugar.acc_requisition_cstm.equipment_c
#WHERE
# suitecrm.req_requisition.id=sugar.acc_requisition_cstm.id_c;
# чистим таблицу связей "Заявок на согласование доступа" с "Заметками"
#USE suitecrm;
#TRUNCATE req_requisition_notes_c ;
# заполняем таблицу связей "Заявок на согласование доступа" с "Заметками"
#USE sugar;
#INSERT INTO
# suitecrm.req_requisition_notes_c (id, date_modified, deleted, req_requisition_notesreq_requisition_ida, req_requisition_notesnotes_idb)
#SELECT
# acc_requisition_notes_c.id, acc_requisition_notes_c.date_modified, acc_requisition_notes_c.deleted,
# acc_requisition_notes_c.acc_requisition_notesacc_requisition_ida, acc_requisition_notes_c.acc_requisition_notesnotes_idb
#FROM
# acc_requisition_notes_c;



#######################################################################################################
#                                          "Объекты"                                                  #
#######################################################################################################



# чистим таблицу "Объекты"
USE suitecrm;
TRUNCATE fac_facility;
# заполняем таблицу "Объекты"
USE sugar;
INSERT INTO
 suitecrm.fac_facility (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 status_facility, addressmap_facility, access_mode, keys_facility)
SELECT
 acc_facility.id, acc_facility.name, acc_facility.date_entered, acc_facility.date_modified, acc_facility.modified_user_id,
 acc_facility.created_by, acc_facility.description, acc_facility.deleted, acc_facility.assigned_user_id,
 acc_facility.status, acc_facility.facilitymap, acc_facility.accessmode, acc_facility.presencekey
FROM
 acc_facility;
USE suitecrm;
UPDATE
 suitecrm.fac_facility, sugar.acc_facility_cstm
SET
 suitecrm.fac_facility.district=sugar.acc_facility_cstm.district_c
WHERE
 suitecrm.fac_facility.id=sugar.acc_facility_cstm.id_c;
# чистим таблицу связей "Объектов" с "Контактами"
USE suitecrm;
TRUNCATE fac_facility_contacts_c;
# заполняем таблицу связей "Объектов" с "Контактами"
USE sugar;
INSERT INTO
 suitecrm.fac_facility_contacts_c (id, date_modified, deleted, fac_facility_contactsfac_facility_ida, fac_facility_contactscontacts_idb)
SELECT
 acc_facility_contacts_c.id, acc_facility_contacts_c.date_modified, acc_facility_contacts_c.deleted,
 acc_facility_contacts_c.acc_facility_contactsacc_facility_ida, acc_facility_contacts_c.acc_facility_contactscontacts_idb
FROM
 acc_facility_contacts_c;
# чистим таблицу связей "Объектов" с "Заявками на согласование доступа"
#USE suitecrm;
#TRUNCATE req_requisition_fac_facility_c;
# заполняем таблицу связей "Объектов" с "Заявками на согласование доступа"
#USE sugar;
#INSERT INTO
# suitecrm.req_requisition_fac_facility_c (id, date_modified, deleted,
# req_requisition_fac_facilityreq_requisition_ida, req_requisition_fac_facilityfac_facility_idb)
#SELECT
# acc_requisition_acc_facility_c.id, acc_requisition_acc_facility_c.date_modified, acc_requisition_acc_facility_c.deleted,
# acc_requisition_acc_facility_c.acc_requisition_acc_facilityacc_requisition_ida, acc_requisition_acc_facility_c.acc_requisition_acc_facilityacc_facility_idb
#FROM
# acc_requisition_acc_facility_c;
# читсим таблицу связей "Объектов" с  "Претензиями на согласование доступа"
USE suitecrm;
TRUNCATE fac_facility_acc_access_errors_c;
# читсим таблицу связей "Объектов" с  "Претензиями на согласование доступа"
USE sugar;
INSERT INTO
 suitecrm.fac_facility_acc_access_errors_c (id, date_modified, deleted,
 fac_facility_acc_access_errorsfac_facility_ida, fac_facility_acc_access_errorsacc_access_errors_idb)
SELECT
 acc_accesserror_acc_facility_c.id, acc_accesserror_acc_facility_c.date_modified, acc_accesserror_acc_facility_c.deleted,
 acc_accesserror_acc_facility_c.acc_accesserror_acc_facilityacc_facility_ida, acc_accesserror_acc_facility_c.acc_accesserror_acc_facilityacc_accesserror_idb
FROM
 acc_accesserror_acc_facility_c;
# исправляем несоответсвия в дроплисте между шугой и сюитом
USE suitecrm;
UPDATE fac_facility
SET status_facility =REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(status_facility, 'AbUr10', 'AbUr10plus'),
 'AbUr5', 'AbUr5plus'), 'AbUr2', 'AbUr2plus'), 'AbFiz10', 'AbFiz10plus'), 'AbFiz4', 'AbFiz5plus'), 'AbFiz2', 'AbFiz2plus');



###################################################################################################
#                                     "Документы на доступ"                                       #
###################################################################################################



# чистим таблицу "Документов на доступ"
USE suitecrm;
TRUNCATE a_doc_access_documents;
# заполняем таблицу "Документов на доступ"
USE sugar;
INSERT INTO
 suitecrm.a_doc_access_documents (id, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, document_name,
 filename, file_ext, file_mime_type, active_date, exp_date, category_id, subcategory_id, status_id)
SELECT
 acc_accessdocuments.id, acc_accessdocuments.date_entered, acc_accessdocuments.date_modified, acc_accessdocuments.modified_user_id, acc_accessdocuments.created_by,
 acc_accessdocuments.description, acc_accessdocuments.deleted, acc_accessdocuments.assigned_user_id, acc_accessdocuments.document_name,
 acc_accessdocuments.filename, acc_accessdocuments.file_ext, acc_accessdocuments.file_mime_type, acc_accessdocuments.active_date,
 acc_accessdocuments.exp_date, acc_accessdocuments.category_id, acc_accessdocuments.subcategory_id, acc_accessdocuments.status_id
FROM
 acc_accessdocuments;
# чистим таблитцу связей "Документов на доступ" с "Заявками на согласование доступа"
#USE suitecrm;
#TRUNCATE a_doc_access_documents_req_requisition_c ;
# заполняем таблитцу связей "Документов на доступ" с "Заявками на согласование доступа"
#USE sugar;
#INSERT INTO
# suitecrm.a_doc_access_documents_req_requisition_c (id, date_modified, deleted,
# a_doc_access_documents_req_requisitiona_doc_access_documents_ida, a_doc_access_documents_req_requisitionreq_requisition_idb)
#SELECT
# acc_requisition_acc_accessdocuments_c.id, acc_requisition_acc_accessdocuments_c.date_modified, acc_requisition_acc_accessdocuments_c.deleted,
# acc_requisition_acc_accessdocuments_c.acc_requisition_acc_accessdocumentsacc_requisition_ida, acc_requisition_acc_accessdocuments_c.acc_requisition_acc_accessdocumentsacc_accessdocuments_idb
#FROM
# acc_requisition_acc_accessdocuments_c;
# чистим таблитцу связей "Документов на доступ" с "Объектами"
USE suitecrm;
TRUNCATE a_doc_access_documents_fac_facility_c;
# заполняем таблитцу связей "Документов на доступ" с "Объектами"
USE sugar;
INSERT INTO
 suitecrm.a_doc_access_documents_fac_facility_c (id, date_modified, deleted,
 a_doc_access_documents_fac_facilityfac_facility_idb, a_doc_access_documents_fac_facilitya_doc_access_documents_ida)
SELECT
 acc_facility_acc_accessdocuments_c.id, acc_facility_acc_accessdocuments_c.date_modified, acc_facility_acc_accessdocuments_c.deleted,
 acc_facility_acc_accessdocuments_c.acc_facility_acc_accessdocumentsacc_facility_ida, acc_facility_acc_accessdocuments_c.acc_facility_acc_accessdocumentsacc_accessdocuments_idb
FROM
 acc_facility_acc_accessdocuments_c;



######################################################################################################
#                                    "Управляющие компании"                                          #
######################################################################################################



# чистим таблицу "Управляющие компании"
USE suitecrm;
TRUNCATE m_com_management_company;
# заполняем таблицу "Управляющие компании"
USE sugar;
INSERT INTO
 suitecrm.m_com_management_company (id, name, date_entered, date_modified, modified_user_id, created_by, description,
 deleted, assigned_user_id, address, phone, fax, status_management_company)
SELECT
 acc_uk.id, acc_uk.name, acc_uk.date_entered, acc_uk.date_modified, acc_uk.modified_user_id, acc_uk.created_by, acc_uk.description,
 acc_uk.deleted, acc_uk.assigned_user_id, acc_uk.address, acc_uk.phone, acc_uk.fax, acc_uk.status
FROM
 acc_uk;
# чистим таблицу связей "Управляющие компании" с "Объектами"
USE suitecrm;
TRUNCATE m_com_management_company_fac_facility_c;
# заполняем таблицу связей "Управляющие компании" с "Объектами"
USE sugar;
INSERT INTO
 suitecrm.m_com_management_company_fac_facility_c (id, date_modified, deleted,
 m_com_mana54b5company_ida, m_com_management_company_fac_facilityfac_facility_idb)
SELECT
 acc_uk_acc_facility_c.id, acc_uk_acc_facility_c.date_modified, acc_uk_acc_facility_c.deleted,
 acc_uk_acc_facility_c.acc_uk_acc_facilityacc_uk_ida, acc_uk_acc_facility_c.acc_uk_acc_facilityacc_facility_idb
FROM
 acc_uk_acc_facility_c;
# чистим таблицу связей "Управляющие компании" с "Документами на доступ"
USE suitecrm;
TRUNCATE m_com_management_company_a_doc_access_documents_c;
# заполняем таблицу связей "Управляющие компании" с "Документами на доступ"
USE sugar;
INSERT INTO
 suitecrm.m_com_management_company_a_doc_access_documents_c (id, date_modified, deleted,
 m_com_mana1d4fcompany_ida, m_com_mana4c26cuments_idb)
SELECT
 acc_uk_acc_accessdocuments_c.id, acc_uk_acc_accessdocuments_c.date_modified, acc_uk_acc_accessdocuments_c.deleted,
 acc_uk_acc_accessdocuments_c.acc_uk_acc_accessdocumentsacc_uk_ida, acc_uk_acc_accessdocuments_c.acc_uk_acc_accessdocumentsacc_accessdocuments_idb
FROM
acc_uk_acc_accessdocuments_c;



###################################################################################################
#                                         "Договоры"                                              #
###################################################################################################

#WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"ПОДУМАТЬ НАД СВЯЗЯМИ С КОНТРАГЕНТАМИ"WWWwwwwWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWw

#чистим таблицу "Договоры"
USE suitecrm;
TRUNCATE con_contracts;
#заполняем таблицу "Договоры"
USE sugar;
INSERT INTO
 suitecrm.con_contracts (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, summ_contract)
SELECT
 opportunities.id, opportunities.name, opportunities.date_entered, opportunities.date_modified, opportunities.modified_user_id,
 opportunities.created_by, opportunities.description, opportunities.deleted, opportunities.assigned_user_id, opportunities.amount
FROM
 opportunities;

USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm, sugar.accounts_opportunities
SET
 suitecrm.con_contracts.date_contract=sugar.opportunities_cstm.opp_date_opp_c,
 suitecrm.con_contracts.actual_date_contract=sugar.opportunities_cstm.date_apply_c,
 suitecrm.con_contracts.organisation_contract= sugar.opportunities_cstm.organization_opp_c,
 suitecrm.con_contracts.code_fineko=sugar.opportunities_cstm.code_fineko_c,
 suitecrm.con_contracts.closed=sugar.opportunities_cstm.closed_opp_c,
 suitecrm.con_contracts.date_closed=sugar.opportunities_cstm.close_date_c,
 suitecrm.con_contracts.stoped=sugar.opportunities_cstm.blockletter_opp_c,
 suitecrm.con_contracts.date_stoped=sugar.opportunities_cstm.date_blockletter_opp_c,
 suitecrm.con_contracts.pvk=sugar.opportunities_cstm.pvk_opp_c,
 suitecrm.con_contracts.payment_pdcpgi=sugar.opportunities_cstm.cost_pdcpgi_opp_c,
 suitecrm.con_contracts.inet_size=sugar.opportunities_cstm.inet_bandwidth_opp_c,
 suitecrm.con_contracts.payment_ip=sugar.opportunities_cstm.ip_cost_opp_c,
 suitecrm.con_contracts.summ_phone_line=sugar.opportunities_cstm.quantity_phone_lines_c,
 suitecrm.con_contracts.account_id_c=sugar.accounts_opportunities.account_id
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c and suitecrm.con_contracts.id=sugar.accounts_opportunities.opportunity_id;

#заполняем и исправляем несоответсвия "Подключеные услуги"
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services='^internet^'
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.internet_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^phone^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.phone_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^video^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.cctv_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^pdcpgi^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.pdcpgi_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^tv^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.tv_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^package_service^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.packet_opp_c='1';
USE suitecrm;
UPDATE
 suitecrm.con_contracts, sugar.opportunities_cstm
SET
 suitecrm.con_contracts.services=concat(services, ',^virtual_ats^')
WHERE
 suitecrm.con_contracts.id=sugar.opportunities_cstm.id_c AND sugar.opportunities_cstm.vats_opp_c='1';



##################################################################################################
#                                   "Заявки на чертеж"                                           #
##################################################################################################



#чистим таблицу "Заявок на чертеж"
USE suitecrm;
TRUNCATE sk_sketch; 
#заполняем таблицу "Заявок на чертеж"
USE sugar;
INSERT INTO
 suitecrm.sk_sketch (id, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 document_name, filename, file_ext, file_mime_type, active_date, exp_date, category_id, subcategory_id, status_id, address) 
SELECT
 sk_sketch.id, sk_sketch.date_entered, sk_sketch.date_modified, sk_sketch.modified_user_id, sk_sketch.created_by, sk_sketch.description,
 sk_sketch.deleted, sk_sketch.assigned_user_id, sk_sketch.document_name, sk_sketch.filename, sk_sketch.file_ext, sk_sketch.file_mime_type,
 sk_sketch.active_date, sk_sketch.exp_date, sk_sketch.category_id, sk_sketch.subcategory_id, sk_sketch.status_requisition, sk_sketch.address
FROM
 sk_sketch;
#исправляем несоответсвия в дропбоксах между сюит и шугой
USE suitecrm;
UPDATE
 sk_sketch
SET
 status_id=REPLACE(REPLACE(REPLACE(status_id, 'reject', 'deny'), 'complet', 'done'), 'not_complet', 'not_done');
#чистим таблицу связей
USE suitecrm;
TRUNCATE sk_sketch_ra_request_survey_c;
TRUNCATE sk_sketch_req_requisition_c;
#заполняем таблицу связей
USE sugar;
INSERT INTO
 suitecrm.sk_sketch_ra_request_survey_c (id, date_modified, deleted, sk_sketch_ra_request_surveysk_sketch_ida, sk_sketch_ra_request_surveyra_request_survey_idb)
SELECT
 sk_sketch_ra_survey_c.id, sk_sketch_ra_survey_c.date_modified, sk_sketch_ra_survey_c.deleted,
 sk_sketch_ra_survey_c.sk_sketch_ra_surveysk_sketch_ida, sk_sketch_ra_survey_c.sk_sketch_ra_surveyra_survey_idb
FROM
 sk_sketch_ra_survey_c;
USE sugar;
INSERT INTO
 suitecrm.sk_sketch_req_requisition_c (id, date_modified, deleted, sk_sketch_req_requisitionsk_sketch_ida, sk_sketch_req_requisitionreq_requisition_idb)
SELECT
 sk_sketch_acc_requisition_c.id, sk_sketch_acc_requisition_c.date_modified, sk_sketch_acc_requisition_c.deleted,
 sk_sketch_acc_requisition_c.sk_sketch_acc_requisitionsk_sketch_ida, sk_sketch_acc_requisition_c.sk_sketch_acc_requisitionacc_requisition_idb
FROM
 sk_sketch_acc_requisition_c;



###############################################################################################
#                                     "Развитие сети"                                         #
###############################################################################################



#чистим таблицу "Развитие сети"
USE suitecrm;
TRUNCATE dev_development_network;
#заполняем таблицу "Развитие сети"
USE sugar;
INSERT INTO
 suitecrm.dev_development_network (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id, status_development, date_finished)
SELECT
 dev_development.id, dev_development.name, dev_development.date_entered, dev_development.date_modified, dev_development.modified_user_id,
 dev_development.created_by, dev_development.description, dev_development.deleted, dev_development.assigned_user_id, dev_development.status, dev_development.finish
FROM
 dev_development;
#чистим таблицу связей с "Заявками на осмотр"
USE suitecrm;
TRUNCATE dev_development_network_ra_request_survey_c;
#заполняем таблицу связей с "Заявками на осмотр"
USE sugar;
INSERT INTO
 suitecrm.dev_development_network_ra_request_survey_c (id, date_modified, deleted, dev_develoa631network_ida, dev_development_network_ra_request_surveyra_request_survey_idb)
SELECT
 dev_development_ra_survey_c.id, dev_development_ra_survey_c.date_modified, dev_development_ra_survey_c.deleted,
 dev_development_ra_survey_c.dev_development_ra_surveydev_development_ida, dev_development_ra_survey_c.dev_development_ra_surveyra_survey_idb
FROM
 dev_development_ra_survey_c;
#исправляем несоответсвия в дропбоксе между сюит и шугой
USE suitecrm;
UPDATE dev_development_network
SET status_development=REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (status_development, '1', 'request'), '2', 'accept'), '3', 'done'), '4', 'deny'), '5', 'deferred');
 


###############################################################################################
#                                        "Закупки"                                            #
###############################################################################################



#чистим таблицу "Закупок"
USE suitecrm;
TRUNCATE pur_purchases;
#заполняем таблицу "Закупок"
USE sugar;
INSERT INTO
 suitecrm.pur_purchases (id, name, date_entered, date_modified, modified_user_id, created_by, description, deleted, assigned_user_id,
 status_purchases, type_purchases, group_purchases, date_purchases, cost, purpose)
SELECT
 pur_purchases.id, pur_purchases.name, pur_purchases.date_entered, pur_purchases.date_modified,
 pur_purchases.modified_user_id, pur_purchases.created_by, pur_purchases.description, pur_purchases.deleted, pur_purchases.assigned_user_id,
 pur_purchases.status, pur_purchases.type, pur_purchases.grouppur, pur_purchases.date_pur, pur_purchases.cost, pur_purchases.purpose
FROM
 pur_purchases;
#исправляем несоответсвия в дроплисте между сюит и шугой
USE suitecrm;
UPDATE pur_purchases
SET status_purchases='request'
WHERE status_purchases='requisition';
#чистим таблицу связей "Закупок с Заметками"
USE suitecrm;
TRUNCATE pur_purchases_notes_c;
#заполняем таблицу связей "Закупок с Заметками"
USE sugar;
INSERT INTO
 suitecrm.pur_purchases_notes_c 
SELECT
 *
FROM
 pur_purchases_notes_c;



#drop database sugar;
SUITECRM



##############################################################################################
#               "Переименонываем фото 'Плана подключений' чтобы они подцепились"             #
##############################################################################################



# переменные для запроса из которого формируется файл с названиями фотографий
#sql_one_connection_plan=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_one_c)
#from con_p_connections_plan_cstm where photo_one_c is not null and photo_one_c!='';`

#sql_two_connection_plan=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_three_c)
#from con_p_connections_plan_cstm where photo_three_c is not null and photo_three_c!='';`

#sql_three_connection_plan=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_two_c)
#from con_p_connections_plan_cstm where photo_two_c is not null and photo_two_c!='';`

#sql_four_connection_plan=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_four_c)
#from con_p_connections_plan_cstm where photo_four_c is not null and photo_four_c!='';`
# переименовываются фото "плана подключений"
#printf "$sql_one_connection_plan" > "/home/crm/temp1.log"
#cd /var/www/suitecrm/upload/
#while read one_connection_plan; 
#do
#rename 's/(.+?)_(.*)/$1_photo_1/' $one_connection_plan
#done < "/home/crm/temp1.log"

#printf "$sql_two_connection_plan" > "/home/crm/temp2.log"
#cd /var/www/suitecrm/upload/
#while read two_connection_plan; 
#do
#rename 's/(.+?)_(.*)/$1_photo_2/' $two_connection_plan
#done < "/home/crm/temp2.log"

#printf "$sql_three_connection_plan" > "/home/crm/temp3.log"
#cd /var/www/suitecrm/upload/
#while read three_connection_plan; 
#do
#rename 's/(.+?)_(.*)/$1_photo_3/' $three_connection_plan
#done < "/home/crm/temp3.log"

#printf "$sql_four_connection_plan" > "/home/crm/temp4.log"
#cd /var/www/suitecrm/upload/
#while read four_connection_plan; 
#do
#rename 's/(.+?)_(.*)/$1_photo_4/' $four_connection_plan
#done < "/home/crm/temp4.log"

#rm /home/crm/temp1.log
#rm /home/crm/temp2.log
#rm /home/crm/temp3.log
#rm /home/crm/temp4.log



##################################################################################################
#              "Переименовываем фото 'Ремонтных работ' чтобы они подцепились"                    #
##################################################################################################



# переменные для запроса из которого формируется файл с названием фотографий
#sql_one_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_one_c)
#from rep_repairs_cstm where photo_one_c is not null and photo_one_c!='';`

#sql_two_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_two_c)
#from rep_repairs_cstm where photo_two_c is not null and photo_two_c!='';`

#sql_three_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_three_c)
#from rep_repairs_cstm where photo_three_c is not null and photo_three_c!='';`

#sql_four_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_four_c)
#from rep_repairs_cstm where photo_four_c is not null and photo_four_c!='';`

#sql_five_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_five_c)
#from rep_repairs_cstm where photo_five_c is not null and photo_five_c!='';`

#sql_six_repair_works=`mysql --user=$MSQLUSR --password=$MSQLPSWD --default-character-set=utf8 <<SUITECRM
#use sugar;
#select concat_ws ('_', id_c, photo_six_c)
#from rep_repairs_cstm where photo_six_c is not null and photo_six_c!='';`

# переименовываются фото ремонтных работ
#printf "$sql_one_repair_works" > "/home/crm/temp_r1.log"
#cd /var/www/suitecrm/upload/
#while read one_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_1/' $one_repair_work
#done < "/home/crm/temp_r1.log"

#printf "$sql_two_repair_works" > "/home/crm/temp_r2.log"
#cd /var/www/suitecrm/upload/
#while read two_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_2/' $two_repair_work
#done < "/home/crm/temp_r2.log"

#printf "$sql_three_repair_works" > "/home/crm/temp_r3.log"
#cd /var/www/suitecrm/upload/
#while read three_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_3/' $three_repair_work
#done < "/home/crm/temp_r3.log"

#printf "$sql_four_repair_works" > "/home/crm/temp_r4.log"
#cd /var/www/suitecrm/upload/
#while read four_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_4/' $four_repair_work
#done < "/home/crm/temp_r4.log"

#printf "$sql_five_repair_works" > "/home/crm/temp_r5.log"
#cd /var/www/suitecrm/upload/
#while read five_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_5/' $five_repair_work
#done < "/home/crm/temp_r5.log"

#printf "$sql_six_repair_works" > "/home/crm/temp_r6.log"
#cd /var/www/suitecrm/upload/
#while read six_repair_work;
#do
#rename 's/(.+?)_(.*)/$1_rapair_work_photo_6/' $six_repair_work
#done < "/home/crm/temp_r6.log"

#rm /home/crm/temp_r1.log
#rm /home/crm/temp_r2.log
#rm /home/crm/temp_r3.log
#rm /home/crm/temp_r4.log
#rm /home/crm/temp_r5.log
#rm /home/crm/temp_r6.log


#use sugar;
#update rep_repairs_cstm set rep_repairs_cstm.new_cat_work_c=rep_repairs_cstm.cat_work_c;
#use sugar;
#update rep_repairs_cstm set new_cat_work_c = '^1^' where new_cat_work_c='1';
#update rep_repairs_cstm set new_cat_work_c = '^2^' where new_cat_work_c='2';
#update rep_repairs_cstm set new_cat_work_c = '^3^' where new_cat_work_c='3';
#update rep_repairs_cstm set new_cat_work_c = '^4^' where new_cat_work_c='4';
#update rep_repairs_cstm set new_cat_work_c = '^5^' where new_cat_work_c='5';
#update rep_repairs_cstm set new_cat_work_c = '^6^' where new_cat_work_c='6';
#update rep_repairs_cstm set new_cat_work_c = '^7^' where new_cat_work_c='7';
#update rep_repairs_cstm set new_cat_work_c = '^8^' where new_cat_work_c='8';
#update rep_repairs_cstm set new_cat_work_c = '^9^' where new_cat_work_c='9';
#update rep_repairs_cstm set new_cat_work_c = '^10^' where new_cat_work_c='10';
#update rep_repairs_cstm set new_cat_work_c = '^11^' where new_cat_work_c='11';
#update rep_repairs_cstm set new_cat_work_c = '^12^' where new_cat_work_c='12';
#update rep_repairs_cstm set new_cat_work_c = '^13^' where new_cat_work_c='13';
#update rep_repairs_cstm set new_cat_work_c = '^14^' where new_cat_work_c='14';
#update rep_repairs_cstm set new_cat_work_c = '^15^' where new_cat_work_c='15';
#update rep_repairs_cstm set new_cat_work_c = '^16^' where new_cat_work_c='16';
#update rep_repairs_cstm set new_cat_work_c = '^17^' where new_cat_work_c='17';
#update rep_repairs_cstm set new_cat_work_c = '^18^' where new_cat_work_c='18';
#update rep_repairs_cstm set new_cat_work_c = '^19^' where new_cat_work_c='19';
#update rep_repairs_cstm set new_cat_work_c = '^20^' where new_cat_work_c='20';
#update rep_repairs_cstm set new_cat_work_c = '^21^' where new_cat_work_c='21';
#update rep_repairs_cstm set new_cat_work_c = '^22^' where new_cat_work_c='22';
#update rep_repairs_cstm set new_cat_work_c = '^23^' where new_cat_work_c='23';
#update rep_repairs_cstm set new_cat_work_c = '^24^' where new_cat_work_c='24';
#update rep_repairs_cstm set new_cat_work_c = '^25^' where new_cat_work_c='25';

service apache2 start
