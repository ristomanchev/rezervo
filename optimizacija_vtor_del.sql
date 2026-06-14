-- 1. БРИШЕЊЕ НА ИНДЕКСОТ АКО ПОСТОИ
DROP INDEX IF EXISTS idx_appointment_customer_not_cancelled;

-- 2. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE appointment;

-- 3. МЕРЕЊЕ БЕЗ ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM customer_appointments_view
WHERE customer_id = 100;

-- Тука најдолу го читаш:
-- Execution Time: ... ms
-- Ова е "Пред оптимизација"


-- 4. КРЕИРАЊЕ НА ИНДЕКС
CREATE INDEX IF NOT EXISTS idx_appointment_customer_not_cancelled
    ON appointment(customer_id)
    WHERE status <> 'cancelled';

-- 5. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE appointment;

-- 6. МЕРЕЊЕ СО ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM customer_appointments_view
WHERE customer_id = 100;

-- Тука најдолу го читаш:
-- Execution Time: ... ms
-- Ова е "После оптимизација"







-- 1. БРИШЕЊЕ НА ИНДЕКСОТ АКО ПОСТОИ
DROP INDEX IF EXISTS idx_time_slot_available_business_date;

-- 2. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE time_slot;

-- 3. МЕРЕЊЕ БЕЗ ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM available_slots
WHERE business_id = 1
  AND date = CURRENT_DATE;

-- Ова е "Пред оптимизација"


-- 4. КРЕИРАЊЕ НА ИНДЕКС
CREATE INDEX IF NOT EXISTS idx_time_slot_available_business_date
    ON time_slot(business_id, date)
    WHERE is_available = TRUE;

-- 5. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE time_slot;

-- 6. МЕРЕЊЕ СО ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM available_slots
WHERE business_id = 1
  AND date = CURRENT_DATE;

-- Ова е "После оптимизација"





-- 1. БРИШЕЊЕ НА ИНДЕКСОТ АКО ПОСТОИ
DROP INDEX IF EXISTS idx_review_rating_details;

-- 2. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE review;

-- 3. МЕРЕЊЕ БЕЗ ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM review_details
WHERE rating = 5;

-- Ова е "Пред оптимизација"


-- 4. КРЕИРАЊЕ НА ИНДЕКС
CREATE INDEX IF NOT EXISTS idx_review_rating_details
    ON review(rating);

-- 5. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE review;

-- 6. МЕРЕЊЕ СО ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM review_details
WHERE rating = 5;

-- Ова е "После оптимизација"





-- 1. БРИШЕЊЕ НА ИНДЕКСОТ АКО ПОСТОИ
DROP INDEX IF EXISTS idx_review_customer_profile;

-- Ако случајно си го креирала и овој индекс, избриши го и него:
DROP INDEX IF EXISTS idx_appointment_customer_profile;

-- 2. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE appointment;
ANALYZE review;

-- 3. МЕРЕЊЕ БЕЗ ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM customer_profile_view
WHERE customer_id = 100;

-- Ова е "Пред оптимизација"


-- 4. КРЕИРАЊЕ НА ИНДЕКС
CREATE INDEX IF NOT EXISTS idx_review_customer_profile
    ON review(customer_id, rating);

-- 5. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE appointment;
ANALYZE review;

-- 6. МЕРЕЊЕ СО ИНДЕКС
EXPLAIN ANALYZE
SELECT *
FROM customer_profile_view
WHERE customer_id = 100;

-- Ова е "После оптимизација"





-- 1. БРИШЕЊЕ НА ИНДЕКСИТЕ АКО ПОСТОЈАТ
DROP INDEX IF EXISTS idx_reschedule_request_status;
DROP INDEX IF EXISTS idx_reschedule_request_old_slot_id;
DROP INDEX IF EXISTS idx_reschedule_request_new_slot_id;

-- 2. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE reschedule_request;

-- 3. МЕРЕЊЕ БЕЗ ИНДЕКСИ
EXPLAIN ANALYZE
SELECT *
FROM reschedule_overview
WHERE status = 'pending';

-- Ова е "Пред оптимизација"


-- 4. КРЕИРАЊЕ НА ИНДЕКСИТЕ
CREATE INDEX IF NOT EXISTS idx_reschedule_request_status
    ON reschedule_request(status);

CREATE INDEX IF NOT EXISTS idx_reschedule_request_old_slot_id
    ON reschedule_request(old_slot_id);

CREATE INDEX IF NOT EXISTS idx_reschedule_request_new_slot_id
    ON reschedule_request(new_slot_id);

-- 5. ОСВЕЖУВАЊЕ НА СТАТИСТИКИ
ANALYZE reschedule_request;

-- 6. МЕРЕЊЕ СО ИНДЕКСИ
EXPLAIN ANALYZE
SELECT *
FROM reschedule_overview
WHERE status = 'pending';

-- Ова е "После оптимизација"




