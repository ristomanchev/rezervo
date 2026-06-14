
-- customer_appointments_view
EXPLAIN ANALYZE
SELECT *
FROM customer_appointments_view
WHERE customer_id = 100;

CREATE INDEX IF NOT EXISTS idx_appointment_customer_not_cancelled
    ON appointment(customer_id)
    WHERE status <> 'cancelled';

ANALYZE appointment;

-- Пред оптимизација:   644.544 ms
-- После оптимизација:   2.756 ms


-- available_slots

EXPLAIN ANALYZE
SELECT *
FROM available_slots
WHERE business_id = 1
  AND date = CURRENT_DATE;

CREATE INDEX IF NOT EXISTS idx_time_slot_available_business_date
    ON time_slot(business_id, date)
    WHERE is_available = TRUE;

ANALYZE time_slot;

-- Пред оптимизација:   429.479 ms
-- После оптимизација:   1.090 ms


-- review summary

EXPLAIN ANALYZE
SELECT *
FROM review_summary
WHERE business_id = 1;

CREATE INDEX IF NOT EXISTS idx_review_business_rating_summary
    ON review(business_id, rating);

ANALYZE review;

-- Пред оптимизација:   627.643 ms
-- После оптимизација:   29.151 ms

-- review_details

EXPLAIN ANALYZE
SELECT *
FROM review_details
WHERE rating = 5;

CREATE INDEX IF NOT EXISTS idx_review_rating_details
    ON review(rating);

ANALYZE review;

-- Пред оптимизација:   800.553 ms
-- После оптимизација:  340.962 ms



-- customer_profile_view

EXPLAIN ANALYZE
SELECT *
FROM customer_profile_view
WHERE customer_id = 100;
--
-- CREATE INDEX IF NOT EXISTS idx_appointment_customer_profile
--     ON appointment(customer_id, created_at);

CREATE INDEX IF NOT EXISTS idx_review_customer_profile
    ON review(customer_id, rating);

ANALYZE appointment;
ANALYZE review;

EXPLAIN ANALYZE
SELECT *
FROM customer_profile_view
WHERE customer_id = 100;

-- Пред оптимизација:   708.985 ms
-- После оптимизација:    0.767 ms

-- reschedule_overview

EXPLAIN ANALYZE
SELECT *
FROM reschedule_overview
WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_reschedule_request_status
    ON reschedule_request(status);

CREATE INDEX IF NOT EXISTS idx_reschedule_request_old_slot_id
    ON reschedule_request(old_slot_id);

CREATE INDEX IF NOT EXISTS idx_reschedule_request_new_slot_id
    ON reschedule_request(new_slot_id);

ANALYZE reschedule_request;

EXPLAIN ANALYZE
SELECT *
FROM reschedule_overview
WHERE status = 'pending';