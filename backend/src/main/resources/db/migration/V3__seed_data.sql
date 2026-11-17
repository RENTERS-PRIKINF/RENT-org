-- V3: Test data for the corrected RENT database.
-- GENERATED ALWAYS AS IDENTITY requires OVERRIDING SYSTEM VALUE for explicit IDs.
-- All names, addresses, email addresses and document URLs are fictional.
-- Password hashes below are placeholders and cannot be used for login.

-- 1. Users
INSERT INTO public.users (user_id, role, email, password_hash, full_name, phone)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'landlord', 'landlord1@example.com', 'TEST_ONLY_NOT_A_REAL_HASH', 'Алексей Смирнов', '+70000000001'),
    (2, 'landlord', 'landlord2@example.com', 'TEST_ONLY_NOT_A_REAL_HASH', 'Мария Волкова', '+70000000002'),
    (3, 'tenant', 'tenant1@example.com', 'TEST_ONLY_NOT_A_REAL_HASH', 'Иван Петров', '+70000000003'),
    (4, 'tenant', 'tenant2@example.com', 'TEST_ONLY_NOT_A_REAL_HASH', 'Анна Соколова', '+70000000004');

-- 2. Landlords and tenants
INSERT INTO public.landlords (landlord_id, user_id, company_name, notes)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, NULL, 'Частный арендодатель'),
    (2, 2, NULL, 'Частный арендодатель');

INSERT INTO public.tenants (tenant_id, user_id, passport_data, notes)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 3, NULL, 'Тестовый профиль арендатора'),
    (2, 4, NULL, 'Тестовый профиль арендатора');

-- 3. Flats
INSERT INTO public.flats
    (flat_id, landlord_id, address, area, rooms, floor, cadastral_number, status, description)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 'г. Красноярск, ул. Учебная, д. 10, кв. 12', 42.5, 2, 3, NULL, 'available', 'Квартира для долгосрочной аренды'),
    (2, 1, 'г. Красноярск, ул. Примерная, д. 7, кв. 4', 28.0, 1, 2, NULL, 'booked', 'Квартира с будущей арендой'),
    (3, 2, 'г. Красноярск, ул. Тестовая, д. 3, кв. 21', 55.0, 2, 5, NULL, 'available', 'Квартира с завершённой арендой');

-- 4. Contracts and templates
INSERT INTO public.contracts
    (contract_id, name, doc_type, file_url, is_active)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'Договор аренды № 1', 'lease', '/test/contracts/lease-1.pdf', true),
    (2, 'Акт передачи № 1', 'act_handover', '/test/contracts/handover-1.pdf', true),
    (3, 'Договор аренды № 2', 'lease', '/test/contracts/lease-2.pdf', true),
    (4, 'Акт возврата № 3', 'act_return', '/test/contracts/return-3.pdf', true),
    (5, 'Дополнительное соглашение № 1', 'amendment', '/test/contracts/amendment-1.pdf', true);

INSERT INTO public.contract_templates
    (template_id, name, type, file_url, owner_id, version)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'Шаблон договора аренды', 'lease', '/test/templates/lease-template.docx', 1, 1),
    (2, 'Шаблон акта передачи', 'act_handover', '/test/templates/handover-template.docx', NULL, 2);

-- 5. Leases
-- The trigger in V2 changes flat 1 to 'rented' and flat 3 to 'available'.
INSERT INTO public.rents
    (rent_id, flat_id, tenant_id, contract_id, handover_act_id, return_act_id,
     start_at, end_at, rent_amount, deposit_amount, status, rent_period)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 1, 1, 2, NULL,
     '2026-10-01 12:00:00+07', '2027-09-30 12:00:00+07',
     30000.00, 30000.00, 'active', 'monthly'),
    (2, 2, 2, 3, NULL, NULL,
     '2026-12-01 12:00:00+07', '2027-05-31 12:00:00+07',
     25000.00, NULL, 'pending', 'monthly'),
    (3, 3, 1, NULL, NULL, 4,
     '2025-01-01 12:00:00+07', '2025-12-31 12:00:00+07',
     35000.00, 35000.00, 'finished', 'monthly');

INSERT INTO public.rent_amendments
    (amendment_id, rent_id, contract_id, change_date, description)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 5, '2026-11-01', 'Уточнение условий оплаты');

-- 6. Payments
INSERT INTO public.payments
    (payment_id, rent_id, payment_date, amount, type, direction, comment)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, '2026-10-01', 30000.00, 'rent', 'income', 'Арендная плата за октябрь'),
    (2, 1, '2026-10-01', 30000.00, 'deposit', 'income', 'Обеспечительный платёж'),
    (3, 1, '2026-11-01', 30000.00, 'rent', 'income', 'Арендная плата за ноябрь'),
    (4, 3, '2025-12-31', 35000.00, 'deposit_return', 'expense', 'Возврат депозита');

-- 7. Meters and readings
INSERT INTO public.meters
    (meter_id, flat_id, meter_type, serial_number, verification_date)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 'electricity', 'TEST-EL-0001', '2028-09-01'),
    (2, 1, 'water_cold', 'TEST-WC-0001', '2028-03-01'),
    (3, 2, 'electricity', 'TEST-EL-0002', '2029-01-01');

INSERT INTO public.meter_readings
    (reading_id, meter_id, reading_date, value, photo_url, entered_by)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, '2026-10-01', 1250.000, NULL, 3),
    (2, 1, '2026-11-01', 1360.000, NULL, 3),
    (3, 2, '2026-11-01', 87.500, NULL, 3),
    (4, 3, '2026-11-01', 520.000, NULL, 4);

-- 8. Property media
INSERT INTO public.property_media
    (media_id, flat_id, file_url, media_type)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, '/test/media/flat-1-living-room.jpg', 'picture'),
    (2, 1, '/test/media/flat-1-kitchen.jpg', 'picture'),
    (3, 2, '/test/media/flat-2-tour.mp4', 'video');

-- 9. Requests
INSERT INTO public.requests
    (request_id, flat_id, tenant_id, description, status)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 1, 'Необходимо проверить смеситель на кухне', 'new'),
    (2, 2, 2, 'Вопрос по дате передачи ключей', 'pending');

-- Demonstrate the requests trigger: resolved_at is set automatically.
UPDATE public.requests
SET status = 'done'
WHERE request_id = 1;

-- 10. Notifications
INSERT INTO public.notifications
    (notification_id, user_id, type, message, scheduled_at, sent_at, status)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 3, 'payment', 'Напоминание об оплате аренды', '2026-12-01 09:00:00', NULL, 'pending'),
    (2, 1, 'contract', 'Дополнительное соглашение подготовлено', '2026-11-01 10:00:00', '2026-11-01 10:05:00', 'sent'),
    (3, 4, 'inspection', 'Согласуйте время осмотра квартиры', '2026-11-20 12:00:00', NULL, 'pending');

-- 11. Adjust sequences after inserting explicit IDs.
SELECT setval(pg_get_serial_sequence('public.users', 'user_id'), (SELECT MAX(user_id) FROM public.users));
SELECT setval(pg_get_serial_sequence('public.landlords', 'landlord_id'), (SELECT MAX(landlord_id) FROM public.landlords));
SELECT setval(pg_get_serial_sequence('public.tenants', 'tenant_id'), (SELECT MAX(tenant_id) FROM public.tenants));
SELECT setval(pg_get_serial_sequence('public.flats', 'flat_id'), (SELECT MAX(flat_id) FROM public.flats));
SELECT setval(pg_get_serial_sequence('public.contracts', 'contract_id'), (SELECT MAX(contract_id) FROM public.contracts));
SELECT setval(pg_get_serial_sequence('public.contract_templates', 'template_id'), (SELECT MAX(template_id) FROM public.contract_templates));
SELECT setval(pg_get_serial_sequence('public.rents', 'rent_id'), (SELECT MAX(rent_id) FROM public.rents));
SELECT setval(pg_get_serial_sequence('public.rent_amendments', 'amendment_id'), (SELECT MAX(amendment_id) FROM public.rent_amendments));
SELECT setval(pg_get_serial_sequence('public.payments', 'payment_id'), (SELECT MAX(payment_id) FROM public.payments));
SELECT setval(pg_get_serial_sequence('public.meters', 'meter_id'), (SELECT MAX(meter_id) FROM public.meters));
SELECT setval(pg_get_serial_sequence('public.meter_readings', 'reading_id'), (SELECT MAX(reading_id) FROM public.meter_readings));
SELECT setval(pg_get_serial_sequence('public.property_media', 'media_id'), (SELECT MAX(media_id) FROM public.property_media));
SELECT setval(pg_get_serial_sequence('public.requests', 'request_id'), (SELECT MAX(request_id) FROM public.requests));
SELECT setval(pg_get_serial_sequence('public.notifications', 'notification_id'), (SELECT MAX(notification_id) FROM public.notifications));
