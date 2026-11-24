# Словарь данных базы данных `rent`

## 1. Описание таблиц и столбцов

| Таблица | Столбец | Тип | Описание | Ограничения |
| :--- | :--- | :--- | :--- | :--- |
| **users** | `user_id` | `bigint` | Уникальный идентификатор пользователя системы | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **users** | `role` | `user_role` (ENUM) | Роль пользователя в системе (арендодатель или арендатор) | `NOT NULL` |
| **users** | `email` | `varchar(255)` | Электронная почта пользователя (используется для входа) | `NOT NULL`, `UNIQUE` |
| **users** | `password_hash` | `varchar(255)` | Хэш пароля учётной записи | `NOT NULL` |
| **users** | `full_name` | `varchar(255)` | Фамилия, имя и отчество пользователя | `NOT NULL` |
| **users** | `phone` | `varchar(50)` | Контактный номер телефона | `NULL` |
| **users** | `created_at` | `timestamp` | Дата и время регистрации пользователя | `NOT NULL`, `DEFAULT now()` |
| **landlords** | `landlord_id` | `bigint` | Уникальный идентификатор профиля арендодателя | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **landlords** | `user_id` | `bigint` | Ссылка на базовую учётную запись пользователя | `NOT NULL`, `UNIQUE`, `FK -> users(user_id)` |
| **landlords** | `company_name` | `varchar(255)` | Наименование организации или ИП (если сдаёт юрлицо) | `NULL` |
| **landlords** | `tax_id` | `varchar(50)` | ИНН или налоговый идентификатор арендодателя | `NULL` |
| **landlords** | `notes` | `text` | Дополнительные заметки об арендодателе | `NULL` |
| **tenants** | `tenant_id` | `bigint` | Уникальный идентификатор профиля арендатора | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **tenants** | `user_id` | `bigint` | Ссылка на базовую учётную запись пользователя | `NOT NULL`, `UNIQUE`, `FK -> users(user_id)` |
| **tenants** | `passport_data` | `varchar(255)` | Паспортные данные арендатора для оформления договора | `NULL` |
| **tenants** | `notes` | `text` | Дополнительные заметки об арендаторе | `NULL` |
| **flats** | `flat_id` | `bigint` | Уникальный идентификатор объекта недвижимости (квартиры) | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **flats** | `landlord_id` | `bigint` | Идентификатор владельца (арендодателя) квартиры | `NOT NULL`, `FK -> landlords(landlord_id)` |
| **flats** | `address` | `varchar(500)` | Полный почтовый адрес объекта недвижимости | `NOT NULL` |
| **flats** | `area` | `numeric` | Общая площадь квартиры в квадратных метрах | `NULL` |
| **flats** | `rooms` | `integer` | Количество жилых комнат | `NULL` |
| **flats** | `floor` | `integer` | Этаж расположения квартиры | `NULL` |
| **flats** | `cadastral_number` | `varchar(100)` | Кадастровый номер объекта недвижимости | `NULL` |
| **flats** | `status` | `flat_status` (ENUM) | Текущий статус доступности квартиры | `NOT NULL`, `DEFAULT 'free'` |
| **flats** | `description` | `text` | Подробное описание квартиры, оснащения и условий | `NULL` |
| **flats** | `created_at` | `timestamp` | Дата и время добавления квартиры в систему | `NOT NULL`, `DEFAULT now()` |
| **property_media** | `media_id` | `bigint` | Уникальный идентификатор медиафайла объекта | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **property_media** | `flat_id` | `bigint` | Ссылка на квартиру, к которой относится фото или видео | `NOT NULL`, `FK -> flats(flat_id)` |
| **property_media** | `file_url` | `varchar(500)` | Путь или URL-ссылка на файл в хранилище | `NOT NULL` |
| **property_media** | `media_type` | `media_type` (ENUM) | Тип медиаконтента (изображение или видео) | `NOT NULL` |
| **property_media** | `created_at` | `timestamp` | Дата и время загрузки файла | `NOT NULL`, `DEFAULT now()` |
| **contract_templates** | `template_id` | `bigint` | Уникальный идентификатор шаблона документа | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **contract_templates** | `name` | `varchar(255)` | Название шаблона документа | `NOT NULL` |
| **contract_templates** | `type` | `doc_kind` (ENUM) | Вид документа, для которого предназначен шаблон | `NOT NULL` |
| **contract_templates** | `file_url` | `varchar(500)` | Ссылка на файл шаблона | `NOT NULL` |
| **contract_templates** | `owner_id` | `bigint` | Владелец пользовательского шаблона (`NULL` для системных) | `NULL`, `FK -> landlords(landlord_id)` |
| **contract_templates** | `version` | `integer` | Номер версии шаблона | `NOT NULL`, `DEFAULT 1` |
| **contract_templates** | `created_at` | `timestamp` | Дата и время создания шаблона | `NOT NULL`, `DEFAULT now()` |
| **contracts** | `contract_id` | `bigint` | Уникальный идентификатор сформированного документа | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **contracts** | `name` | `varchar(255)` | Название или номер документа | `NOT NULL` |
| **contracts** | `doc_kind` | `doc_kind` (ENUM) | Тип документа (договор, акт приёма-передачи, допсоглашение) | `NOT NULL` |
| **contracts** | `file_url` | `varchar(500)` | Ссылка на подписанный или сгенерированный файл документа | `NOT NULL` |
| **contracts** | `is_active` | `boolean` | Признак актуальности документа | `NOT NULL`, `DEFAULT true` |
| **contracts** | `created_at` | `timestamp` | Дата и время создания документа | `NOT NULL`, `DEFAULT now()` |
| **leases** | `lease_id` | `bigint` | Уникальный идентификатор сделки (договора аренды) | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **leases** | `flat_id` | `bigint` | Сдаваемая в аренду квартира | `NOT NULL`, `FK -> flats(flat_id)` |
| **leases** | `tenant_id` | `bigint` | Арендатор (наниматель) по договору | `NOT NULL`, `FK -> tenants(tenant_id)` |
| **leases** | `contract_id` | `bigint` | Ссылка на основной файл договора аренды | `NULL`, `FK -> contracts(contract_id)` |
| **leases** | `handover_act_id` | `bigint` | Ссылка на акт приёма-передачи квартиры при заселении | `NULL`, `FK -> contracts(contract_id)` |
| **leases** | `return_act_id` | `bigint` | Ссылка на акт возврата квартиры при выезде | `NULL`, `FK -> contracts(contract_id)` |
| **leases** | `start_date` | `date` | Дата начала срока аренды | `NOT NULL` |
| **leases** | `end_date` | `date` | Дата окончания срока аренды | `NOT NULL` |
| **leases** | `rent_amount` | `numeric` | Размер ежемесячной арендной платы | `NOT NULL` |
| **leases** | `deposit_amount` | `numeric` | Сумма страхового депозита (залога) | `NULL` |
| **leases** | `status` | `lease_status` (ENUM) | Текущий статус договора аренды | `NOT NULL`, `DEFAULT 'active'` |
| **lease_amendments** | `amendment_id` | `bigint` | Уникальный идентификатор дополнительного соглашения | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **lease_amendments** | `lease_id` | `bigint` | Ссылка на основной договор аренды | `NOT NULL`, `FK -> leases(lease_id)` |
| **lease_amendments** | `contract_id` | `bigint` | Ссылка на файл документа дополнительного соглашения | `NULL`, `FK -> contracts(contract_id)` |
| **lease_amendments** | `change_date` | `date` | Дата вступления изменений в силу | `NOT NULL` |
| **lease_amendments** | `description` | `text` | Краткое содержание вносимых изменений | `NULL` |
| **payments** | `payment_id` | `bigint` | Уникальный идентификатор финансовой операции | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **payments** | `lease_id` | `bigint` | Ссылка на договор аренды, по которому прошёл платёж | `NOT NULL`, `FK -> leases(lease_id)` |
| **payments** | `payment_date` | `date` | Фактическая дата совершения платежа | `NOT NULL` |
| **payments** | `amount` | `numeric` | Сумма платежа | `NOT NULL` |
| **payments** | `type` | `payment_type` (ENUM) | Назначение платежа (аренда, залог, ремонт, штраф и др.) | `NOT NULL` |
| **payments** | `direction` | `payment_direction` (ENUM) | Направление движения средств (приход или расход) | `NOT NULL` |
| **payments** | `comment` | `text` | Комментарий или назначение платежа | `NULL` |
| **meters** | `meter_id` | `bigint` | Уникальный идентификатор прибора учёта (счётчика) | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **meters** | `flat_id` | `bigint` | Квартира, в которой установлен счётчик | `NOT NULL`, `FK -> flats(flat_id)` |
| **meters** | `meter_type` | `meter_type` (ENUM) | Тип ресурса (электричество, холодная/горячая вода, газ) | `NOT NULL` |
| **meters** | `serial_number` | `varchar(100)` | Заводской серийный номер прибора учёта | `NOT NULL`, `UNIQUE` |
| **meters** | `verification_date` | `date` | Дата следующей обязательной поверки счётчика | `NULL` |
| **meter_readings** | `reading_id` | `bigint` | Уникальный идентификатор записи показаний счётчика | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **meter_readings** | `meter_id` | `bigint` | Ссылка на прибор учёта | `NOT NULL`, `FK -> meters(meter_id)`, `UNIQUE(meter_id, reading_date)` |
| **meter_readings** | `reading_date` | `date` | Дата снятия показаний (не более одной записи в день на прибор) | `NOT NULL`, `UNIQUE(meter_id, reading_date)` |
| **meter_readings** | `value` | `numeric` | Зафиксированное числовое значение показаний | `NOT NULL` |
| **meter_readings** | `photo_url` | `varchar(500)` | Ссылка на подтверждающее фото циферблата счётчика | `NULL` |
| **meter_readings** | `entered_by` | `bigint` | Пользователь, внёсший показания в систему | `NOT NULL`, `FK -> users(user_id)` |
| **requests** | `request_id` | `bigint` | Уникальный идентификатор обращения/заявки на обслуживание | `PRIMARY KEY`, `NOT NULL`, автоинкремент |
| **requests** | `flat_id` | `bigint` | Квартира, к которой относится заявка | `NOT NULL`, `FK -> flats(flat_id)` |
| **requests** | `tenant_id` | `bigint` | Арендатор, создавший обращение | `NOT NULL`, `FK -> tenants(tenant_id)` |
| **requests** | `created_at` | `timestamp` | Дата и время создания заявки | `NOT NULL`, `DEFAULT now()` |
| **requests** | `description` | `text` | Описание проблемы или сути обращения | `NOT NULL` |
| **requests** | `status` | `request_status` (ENUM) | Текущий статус обработки заявки | `NOT NULL`, `DEFAULT 'new'` |
| **requests** | `resolved_at` | `timestamp` | Дата и время закрытия (решения) заявки | `NULL` |
