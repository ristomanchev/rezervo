-- =========================================
-- USERS
-- =========================================
INSERT INTO "user" (email,password,is_active,created_at)
SELECT
    'user' || gs || '@mail.com',
    'Aa123456!',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(2,1001101) gs;

-- =========================================
-- ROLES
-- =========================================
INSERT INTO role (role_id,name)
VALUES (2,'customer'),(3,'employee'),(4,'manager')
ON CONFLICT DO NOTHING;

-- =========================================
-- USER ROLE
-- =========================================
INSERT INTO user_role (user_id,role_id)
SELECT gs,2 FROM generate_series(2,1000001) gs;

INSERT INTO user_role (user_id,role_id)
SELECT gs,3 FROM generate_series(1000002,1001001) gs;

INSERT INTO user_role (user_id,role_id)
SELECT gs,4 FROM generate_series(1001002,1001101) gs;

-- =========================================
-- CUSTOMER (1M)
-- =========================================
INSERT INTO customer (user_id,first_name,last_name,phone,created_at)
SELECT
    gs,
    'John','Smith',
    '+3897'||lpad(gs::text,7,'0'),
    CURRENT_TIMESTAMP
FROM generate_series(2,1000001) gs;

-- =========================================
-- EMPLOYEE (1000)
-- =========================================
INSERT INTO employee (user_id,first_name,last_name,hire_date,bio,is_active,created_at)
SELECT
    gs,
    'Emp','Worker',
    CURRENT_DATE,
    'bio',
    TRUE,
    CURRENT_TIMESTAMP
FROM generate_series(1000002,1001001) gs;

-- =========================================
-- MANAGER (100)
-- =========================================
INSERT INTO manager (user_id,created_at)
SELECT
    gs,
    CURRENT_TIMESTAMP
FROM generate_series(1001002,1001101) gs;

-- =========================================
-- BUSINESS (100)
-- =========================================
INSERT INTO business (name,description,phone,email,created_at)
SELECT
    'Business '||gs,
    'Desc',
    '+38970'||lpad(gs::text,6,'0'),
    'biz'||gs||'@mail.com',
    CURRENT_TIMESTAMP
FROM generate_series(1,100) gs;

-- =========================================
-- SPECIALTY (100)
-- =========================================
INSERT INTO specialty (name)
SELECT 'Specialty '||gs
FROM generate_series(1,100) gs;

-- =========================================
-- BUSINESS SPECIALTY (UNIQUE SAFE)
-- =========================================
INSERT INTO business_specialty (business_id,specialty_id)
SELECT b,s
FROM generate_series(1,100) b
         JOIN generate_series(1,100) s ON TRUE
WHERE NOT (b=1 AND s=1);

-- =========================================
-- EMPLOYEE BUSINESS SPECIALTY
-- =========================================
INSERT INTO employee_business_specialty (employee_id,business_id,specialty_id)
SELECT e, ((e-1)%100)+1, ((e-1)%100)+1
FROM generate_series(2,1000) e;

-- =========================================
-- BUSINESS MANAGER
-- =========================================
INSERT INTO business_manager (business_id,manager_id,assigned_at)
SELECT b,b,CURRENT_TIMESTAMP
FROM generate_series(2,100) b;

-- =========================================
-- BUSINESS EMPLOYEE
-- =========================================
INSERT INTO business_employee (business_id,employee_id,date_start)
SELECT ((e-1)%100)+1, e, CURRENT_DATE
FROM generate_series(2,1000) e;

-- =========================================
-- MANAGER EMPLOYEE BUSINESS (NO DUPLICATES)
-- =========================================
INSERT INTO manager_employee_business (manager_id,employee_id,business_id,date_start)
SELECT m,e,m,CURRENT_TIMESTAMP
FROM generate_series(1,100) m
         JOIN generate_series(1,1000) e ON TRUE
WHERE NOT (m=1 AND e=1);

-- =========================================
-- SERVICE CATEGORY (1000)
-- =========================================
INSERT INTO service_category (name)
SELECT 'Category '||gs
FROM generate_series(1,1000) gs;

-- =========================================
-- SERVICE (1000)
-- =========================================
INSERT INTO service (category_id,name,description)
SELECT gs,'Service '||gs,'Desc'
FROM generate_series(1,1000) gs;

-- =========================================
-- BUSINESS SERVICE (UNIQUE SAFE)
-- =========================================
INSERT INTO business_service (business_id,service_id,price,duration_minutes,is_active)
SELECT b,s,20,30,TRUE
FROM generate_series(1,100) b
         JOIN generate_series(1,1000) s ON TRUE
WHERE NOT (b=1 AND s=1);

-- =========================================
-- EMPLOYEE SERVICE
-- =========================================
INSERT INTO employee_service (employee_id,service_id)
SELECT e, ((e-1)%1000)+1
FROM generate_series(2,1000) e;

-- =========================================
-- BUSINESS LOCATION
-- =========================================
INSERT INTO business_location (business_id,address,city,phone)
SELECT b,'Address '||b,'Skopje','+38970'||lpad(b::text,6,'0')
FROM generate_series(2,100) b;

-- =========================================
-- BUSINESS HOUR
-- =========================================
INSERT INTO business_hour (business_id,day_of_week,open_time,close_time,is_open)
SELECT b,'Mon','08:00','17:00',TRUE
FROM generate_series(2,100) b;

-- =========================================
-- WORKING SCHEDULE
-- =========================================
INSERT INTO working_schedule (employee_id,business_id,business_hours_id,day_of_week,start_time,end_time,is_working)
SELECT e, ((e-1)%100)+1,1,'Mon','08:00','17:00',TRUE
FROM generate_series(2,1000) e;

-- =========================================
-- TIME SLOT (SAFE)
-- =========================================
INSERT INTO time_slot (employee_id,business_id,date,start_time,end_time,is_available)
SELECT
    ((gs-2)%1000)+1,
    ((gs-2)%100)+1,
    CURRENT_DATE,
    '08:00','08:30',TRUE
FROM generate_series(2,1000001) gs;

-- =========================================
-- APPOINTMENT
-- =========================================
INSERT INTO appointment (customer_id,employee_id,business_id,service_id,slot_id,status,created_at)
SELECT
    ((gs-2)%1000000)+1,
    ((gs-2)%1000)+1,
    ((gs-2)%100)+1,
    ((gs-2)%1000)+1,
    gs,
    'confirmed',
    CURRENT_TIMESTAMP
FROM generate_series(2,1000001) gs;

-- =========================================
-- RESCHEDULE REQUEST
-- =========================================
INSERT INTO reschedule_request (appointment_id,old_slot_id,new_slot_id,manager_id,employee_id,status,reason,created_at)
SELECT
    gs,
    gs,
    gs+1,
    ((gs-2)%100)+1,
    ((gs-2)%1000)+1,
    'pending',
    'Change',
    CURRENT_TIMESTAMP
FROM generate_series(2,100001) gs;

-- =========================================
-- REVIEW
-- =========================================
INSERT INTO review (appointment_id,customer_id,employee_id,manager_id,business_id,rating,comment,created_at)
SELECT
    gs,
    ((gs-2)%1000000)+1,
    ((gs-2)%1000)+1,
    ((gs-2)%100)+1,
    ((gs-2)%100)+1,
    (gs%5)+1,
    'Review',
    CURRENT_TIMESTAMP
FROM generate_series(2,500001) gs;

-- =========================================
-- CANCELLATION
-- =========================================
INSERT INTO cancellation (appointment_id,cancelled_by,reason,refund_amount,created_at,employee_id)
SELECT
    gs,
    'employee',
    'Reason',
    0,
    CURRENT_TIMESTAMP,
    ((gs-2)%1000)+1
FROM generate_series(2,100001) gs;

-- =========================================
-- GALLERY
-- =========================================
INSERT INTO gallery_item (business_id,employee_id,image_url,description,uploaded_at)
SELECT
    ((gs-2)%100)+1,
    ((gs-2)%1000)+1,
    'https://example.com/img'||gs||'.jpg',
    'Image',
    CURRENT_TIMESTAMP
FROM generate_series(2,100001) gs;



-------------------------

BEGIN;

SET LOCAL synchronous_commit = OFF;

-- =====================================================
-- ADD TIME SLOTS
-- Adds: 19,899,998
-- Uses real employee IDs and business IDs from your DB
-- =====================================================

WITH
    employees AS (
        SELECT employee_id, ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
        FROM employee
    ),
    businesses AS (
        SELECT business_id, ROW_NUMBER() OVER (ORDER BY business_id) AS rn
        FROM business
    ),
    counts AS (
        SELECT
            (SELECT COUNT(*) FROM employees) AS employee_count,
            (SELECT COUNT(*) FROM businesses) AS business_count
    )
INSERT INTO time_slot (
    employee_id,
    business_id,
    date,
    start_time,
    end_time,
    is_available
)
SELECT
    e.employee_id,
    b.business_id,
    CURRENT_DATE + (((gs - 1) / 48000)::int),
    (TIME '08:00' + (((gs - 1) % 18) * INTERVAL '30 minutes'))::time,
    (TIME '08:30' + (((gs - 1) % 18) * INTERVAL '30 minutes'))::time,
    TRUE
FROM generate_series(1, 19899998) gs
         CROSS JOIN counts c
         JOIN employees e
              ON e.rn = ((gs - 1) % c.employee_count) + 1
         JOIN businesses b
              ON b.rn = ((gs - 1) % c.business_count) + 1;


-- =====================================================
-- ADD APPOINTMENTS
-- Adds: 4,989,999
-- Uses real customer, employee, business, service, slot IDs
-- =====================================================

WITH
    customers AS (
        SELECT customer_id, ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
        FROM customer
    ),
    employees AS (
        SELECT employee_id, ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
        FROM employee
    ),
    businesses AS (
        SELECT business_id, ROW_NUMBER() OVER (ORDER BY business_id) AS rn
        FROM business
    ),
    services AS (
        SELECT service_id, ROW_NUMBER() OVER (ORDER BY service_id) AS rn
        FROM service
    ),
    slots AS (
        SELECT slot_id, ROW_NUMBER() OVER (ORDER BY slot_id) AS rn
        FROM time_slot
    ),
    counts AS (
        SELECT
            (SELECT COUNT(*) FROM customers) AS customer_count,
            (SELECT COUNT(*) FROM employees) AS employee_count,
            (SELECT COUNT(*) FROM businesses) AS business_count,
            (SELECT COUNT(*) FROM services) AS service_count,
            (SELECT COUNT(*) FROM slots) AS slot_count
    )
INSERT INTO appointment (
    customer_id,
    employee_id,
    business_id,
    service_id,
    slot_id,
    status,
    created_at
)
SELECT
    cst.customer_id,
    e.employee_id,
    b.business_id,
    s.service_id,
    ts.slot_id,
    'confirmed',
    CURRENT_TIMESTAMP
FROM generate_series(1, 4989999) gs
         CROSS JOIN counts c
         JOIN customers cst
              ON cst.rn = ((gs - 1) % c.customer_count) + 1
         JOIN employees e
              ON e.rn = ((gs - 1) % c.employee_count) + 1
         JOIN businesses b
              ON b.rn = ((gs - 1) % c.business_count) + 1
         JOIN services s
              ON s.rn = ((gs - 1) % c.service_count) + 1
         JOIN slots ts
              ON ts.rn = ((gs - 1) % c.slot_count) + 1;


-- =====================================================
-- ADD REVIEWS
-- Adds: 4,997,499
-- Uses real appointment, customer, employee, manager, business IDs
-- =====================================================

WITH
    appointments AS (
        SELECT appointment_id, ROW_NUMBER() OVER (ORDER BY appointment_id) AS rn
        FROM appointment
    ),
    customers AS (
        SELECT customer_id, ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
        FROM customer
    ),
    employees AS (
        SELECT employee_id, ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
        FROM employee
    ),
    managers AS (
        SELECT manager_id, ROW_NUMBER() OVER (ORDER BY manager_id) AS rn
        FROM manager
    ),
    businesses AS (
        SELECT business_id, ROW_NUMBER() OVER (ORDER BY business_id) AS rn
        FROM business
    ),
    counts AS (
        SELECT
            (SELECT COUNT(*) FROM appointments) AS appointment_count,
            (SELECT COUNT(*) FROM customers) AS customer_count,
            (SELECT COUNT(*) FROM employees) AS employee_count,
            (SELECT COUNT(*) FROM managers) AS manager_count,
            (SELECT COUNT(*) FROM businesses) AS business_count
    )
INSERT INTO review (
    appointment_id,
    customer_id,
    employee_id,
    manager_id,
    business_id,
    rating,
    comment,
    created_at
)
SELECT
    a.appointment_id,
    cst.customer_id,
    e.employee_id,
    m.manager_id,
    b.business_id,
    ((gs - 1) % 5) + 1,
    'Review',
    CURRENT_TIMESTAMP
FROM generate_series(1, 4997499) gs
         CROSS JOIN counts c
         JOIN appointments a
              ON a.rn = ((gs - 1) % c.appointment_count) + 1
         JOIN customers cst
              ON cst.rn = ((gs - 1) % c.customer_count) + 1
         JOIN employees e
              ON e.rn = ((gs - 1) % c.employee_count) + 1
         JOIN managers m
              ON m.rn = ((gs - 1) % c.manager_count) + 1
         JOIN businesses b
              ON b.rn = ((gs - 1) % c.business_count) + 1;

COMMIT;


-- ===============================================z======
-- CHECK COUNTS
-- =====================================================

SELECT 'time_slot' AS table_name, COUNT(*) AS total_rows FROM time_slot
UNION ALL
SELECT 'appointment', COUNT(*) FROM appointment
UNION ALL
SELECT 'review', COUNT(*) FROM review;