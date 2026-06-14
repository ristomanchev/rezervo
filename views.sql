-- =========================================
-- 1. CUSTOMER PROFILE VIEW
-- =========================================
DROP VIEW IF EXISTS customer_profile_view;

CREATE VIEW customer_profile_view AS
SELECT
    u.user_id,
    u.email,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.phone,

    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    COUNT(DISTINCT a.business_id) AS businesses_visited,
    AVG(r.rating) AS avg_given_rating,
    COUNT(r.review_id) AS total_reviews_written,
    MAX(a.created_at) AS last_appointment_date

FROM customer c
         JOIN "user" u ON c.user_id = u.user_id
         LEFT JOIN appointment a ON c.customer_id = a.customer_id
         LEFT JOIN review r ON c.customer_id = r.customer_id

GROUP BY
    u.user_id,
    u.email,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.phone;
select count(*) from customer_profile_view;


-- =========================================
-- 2. CUSTOMER APPOINTMENTS VIEW
-- =========================================
DROP VIEW IF EXISTS customer_appointments_view;

CREATE VIEW customer_appointments_view AS
SELECT
    a.appointment_id,
    a.status,
    a.created_at,

    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,

    b.business_id,
    b.name AS business_name,

    s.service_id,
    s.name AS service_name,

    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,

    ts.date,
    ts.start_time,
    ts.end_time,

    bl.city

FROM appointment a
         JOIN customer c ON a.customer_id = c.customer_id
         JOIN business b ON a.business_id = b.business_id
         JOIN service s ON a.service_id = s.service_id
         JOIN employee e ON a.employee_id = e.employee_id
         JOIN time_slot ts ON a.slot_id = ts.slot_id
         LEFT JOIN business_location bl ON b.business_id = bl.business_id

WHERE a.status <> 'cancelled';


-- =========================================
-- 3. AVAILABLE SLOTS VIEW
-- =========================================
DROP VIEW IF EXISTS available_slots;

CREATE VIEW available_slots AS
SELECT
    ts.slot_id,
    ts.date,
    ts.start_time,
    ts.end_time,

    b.business_id,
    b.name AS business_name,

    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,

    s.service_id,
    s.name AS service_name,

    bs.price,
    bs.duration_minutes

FROM time_slot ts
         JOIN business b ON ts.business_id = b.business_id
         JOIN employee e ON ts.employee_id = e.employee_id
         JOIN employee_service es ON e.employee_id = es.employee_id
         JOIN service s ON es.service_id = s.service_id
         JOIN business_service bs
              ON bs.business_id = b.business_id
                  AND bs.service_id = s.service_id

WHERE ts.is_available = TRUE
  AND bs.is_active = TRUE;


-- =========================================
-- 4. BUSINESS SERVICES VIEW
-- =========================================
DROP VIEW IF EXISTS business_services_view;

CREATE VIEW business_services_view AS
SELECT
    b.business_id,
    b.name AS business_name,
    b.description,
    s.name AS service_name,
    bs.price,
    bs.duration_minutes
FROM business b
         JOIN business_service bs ON b.business_id = bs.business_id
         JOIN service s ON bs.service_id = s.service_id
WHERE bs.is_active = TRUE;


-- =========================================
-- 5. BUSINESS OVERVIEW VIEW
-- =========================================
DROP VIEW IF EXISTS business_overview;

CREATE VIEW business_overview AS
SELECT
    b.business_id,
    b.name,
    b.email,
    COUNT(DISTINCT be.employee_id) AS employee_count,
    COUNT(DISTINCT bm.manager_id) AS manager_count
FROM business b
         LEFT JOIN business_employee be ON b.business_id = be.business_id
         LEFT JOIN business_manager bm ON b.business_id = bm.business_id
GROUP BY b.business_id, b.name, b.email;


-- =========================================
-- 6. REVIEW SUMMARY VIEW
-- =========================================
-- DA KAZHEME DEKA E MATERIJALIZIRAN VIEW
DROP VIEW IF EXISTS review_summary;

CREATE VIEW review_summary AS
SELECT
    b.business_id,
    b.name AS business_name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS total_reviews
FROM review r
         JOIN business b ON r.business_id = b.business_id
GROUP BY b.business_id, b.name;


-- =========================================
-- 7. REVIEW DETAILS VIEW
-- =========================================
-- MATERIJALIZIRAN VIEW
DROP VIEW IF EXISTS review_details;

CREATE VIEW review_details AS
SELECT
    r.review_id,
    b.name AS business_name,
    r.rating,
    r.comment,
    r.created_at
FROM review r
         JOIN business b ON r.business_id = b.business_id;


-- =========================================
-- 8. RESCHEDULE OVERVIEW VIEW
-- =========================================
DROP VIEW IF EXISTS reschedule_overview;

CREATE VIEW reschedule_overview AS
SELECT
    rr.request_id,
    rr.status,
    rr.reason,
    ts_old.date AS old_date,
    ts_old.start_time AS old_time,
    ts_new.date AS new_date,
    ts_new.start_time AS new_time
FROM reschedule_request rr
         JOIN time_slot ts_old ON rr.old_slot_id = ts_old.slot_id
         JOIN time_slot ts_new ON rr.new_slot_id = ts_new.slot_id;


-- =========================================
-- 9. BUSINESS LOCATION VIEW
-- =========================================
DROP VIEW IF EXISTS business_location_view;

CREATE VIEW business_location_view AS
SELECT
    b.business_id,
    b.name AS business_name,
    bl.address,
    bl.city,
    bl.phone
FROM business_location bl
         JOIN business b ON bl.business_id = b.business_id;