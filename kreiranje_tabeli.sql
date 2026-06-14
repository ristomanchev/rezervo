-- ========================
-- CLEAN START
-- ========================
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- ROLE
CREATE TABLE role (
                      role_id SERIAL NOT NULL,
                      name VARCHAR(50) NOT NULL,

                      CONSTRAINT pk_role PRIMARY KEY (role_id),
                      CONSTRAINT uq_role_name UNIQUE (name),
                      CHECK (length(name) > 0)
);

-- USER
CREATE TABLE "user" (
                        user_id SERIAL NOT NULL,
                        email VARCHAR(100) NOT NULL,
                        password VARCHAR(255) NOT NULL,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMP(7),

                        CONSTRAINT pk_user PRIMARY KEY (user_id),
                        CONSTRAINT uq_user_email UNIQUE (email),

                        CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
                        CHECK (
                            length(password) >= 8
                                AND password ~ '[A-Z]'
                                AND password ~ '[a-z]'
                                AND password ~ '[0-9]'
                                AND password ~ '[^A-Za-z0-9]'
                            )
);

-- USER ROLE
CREATE TABLE user_role (
                           user_role_id SERIAL NOT NULL,
                           user_id INT NOT NULL DEFAULT 1,
                           role_id INT NOT NULL DEFAULT 1,

                           CONSTRAINT pk_user_role PRIMARY KEY (user_role_id),
                           CONSTRAINT uq_user_role_user_role UNIQUE (user_id, role_id),

                           CONSTRAINT fk_user_role_user
                               FOREIGN KEY (user_id) REFERENCES "user"(user_id)
                                   ON DELETE SET DEFAULT ON UPDATE CASCADE,

                           CONSTRAINT fk_user_role_role
                               FOREIGN KEY (role_id) REFERENCES role(role_id)
                                   ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- CUSTOMER
CREATE TABLE customer (
                          customer_id SERIAL NOT NULL,
                          user_id INT NOT NULL DEFAULT 1,
                          first_name VARCHAR(50) CHECK (first_name IS NULL OR first_name ~ '^[A-Za-z]+$'),
                          last_name VARCHAR(50) CHECK (last_name IS NULL OR last_name ~ '^[A-Za-z]+$'),
                          phone VARCHAR(20),
                          created_at TIMESTAMP(7),

                          CONSTRAINT pk_customer PRIMARY KEY (customer_id),
                          CONSTRAINT uq_customer_user UNIQUE (user_id),

                          CHECK (phone IS NULL OR phone ~ '^[0-9+()-]{6,20}$'),

                          CONSTRAINT fk_customer_user
                              FOREIGN KEY (user_id) REFERENCES "user"(user_id)
                                  ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- EMPLOYEE
CREATE TABLE employee (
                          employee_id SERIAL NOT NULL,
                          user_id INT NOT NULL DEFAULT 1,
                          first_name VARCHAR(50) CHECK (last_name IS NULL OR last_name ~ '^[A-Za-z]+$'),
                          last_name VARCHAR(50) CHECK (last_name IS NULL OR last_name ~ '^[A-Za-z]+$'),
                          hire_date DATE,
                          bio TEXT,
                          is_active BOOLEAN NOT NULL DEFAULT TRUE,
                          created_at TIMESTAMP(7),

                          CONSTRAINT pk_employee PRIMARY KEY (employee_id),
                          CONSTRAINT uq_employee_user UNIQUE (user_id),

                          CHECK (hire_date IS NULL OR hire_date <= CURRENT_DATE),

                          CONSTRAINT fk_employee_user
                              FOREIGN KEY (user_id) REFERENCES "user"(user_id)
                                  ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- MANAGER
CREATE TABLE manager (
                         manager_id SERIAL NOT NULL,
                         user_id INT NOT NULL DEFAULT 1,
                         created_at TIMESTAMP(7),

                         CONSTRAINT pk_manager PRIMARY KEY (manager_id),
                         CONSTRAINT uq_manager_user UNIQUE (user_id),

                         CONSTRAINT fk_manager_user
                             FOREIGN KEY (user_id) REFERENCES "user"(user_id)
                                 ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- BUSINESS
CREATE TABLE business (
                          business_id SERIAL NOT NULL,
                          name VARCHAR(100),
                          description TEXT,
                          phone VARCHAR(20),
                          email VARCHAR(100),
                          created_at TIMESTAMP(7),

                          CONSTRAINT pk_business PRIMARY KEY (business_id),

                          CHECK (name IS NULL OR length(name) > 0),
                          CHECK (email IS NULL OR email ~* '^[^@]+@[^@]+\.[^@]+$'),
                          CHECK (phone IS NULL OR phone ~ '^[0-9+()-]{6,20}$')

);

-- BUSINESS MANAGER
CREATE TABLE business_manager (
                                  business_manager_id SERIAL NOT NULL,
                                  business_id INT NOT NULL DEFAULT 1,
                                  manager_id INT NOT NULL DEFAULT 1,
                                  assigned_at TIMESTAMP(7),
                                  valid_to DATE,

                                  CONSTRAINT pk_business_manager PRIMARY KEY (business_manager_id),
                                  CONSTRAINT uq_business_manager_business_manager UNIQUE (business_id, manager_id),

                                  CONSTRAINT fk_business_manager_business
                                      FOREIGN KEY (business_id) REFERENCES business(business_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                  CONSTRAINT fk_business_manager_manager
                                      FOREIGN KEY (manager_id) REFERENCES manager(manager_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- BUSINESS EMPLOYEE
CREATE TABLE business_employee (
                                   business_employee_id SERIAL NOT NULL,
                                   business_id INT NOT NULL DEFAULT 1,
                                   employee_id INT NOT NULL DEFAULT 1,
                                   date_start DATE,
                                   date_finish DATE,

                                   CONSTRAINT pk_business_employee PRIMARY KEY (business_employee_id),
                                   CONSTRAINT uq_business_employee_business_employee UNIQUE (business_id, employee_id),

                                   CHECK (date_finish IS NULL OR date_finish > date_start),

                                   CONSTRAINT fk_business_employee_business
                                       FOREIGN KEY (business_id) REFERENCES business(business_id)
                                           ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                   CONSTRAINT fk_business_employee_employee
                                       FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                           ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- MANAGER EMPLOYEE BUSINESS
CREATE TABLE manager_employee_business (
                                           meb_id SERIAL NOT NULL,
                                           manager_id INT NOT NULL DEFAULT 1,
                                           employee_id INT NOT NULL DEFAULT 1,
                                           business_id INT NOT NULL DEFAULT 1,
                                           date_start TIMESTAMP(7),
                                           date_finish DATE,

                                           CONSTRAINT pk_manager_employee_business PRIMARY KEY (meb_id),
                                           CONSTRAINT uq_manager_employee_business_triplet
                                               UNIQUE (manager_id, employee_id, business_id),

                                           CONSTRAINT fk_meb_manager
                                               FOREIGN KEY (manager_id) REFERENCES manager(manager_id)
                                                   ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                           CONSTRAINT fk_meb_employee
                                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                                   ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                           CONSTRAINT fk_meb_business
                                               FOREIGN KEY (business_id) REFERENCES business(business_id)
                                                   ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- SPECIALTY
CREATE TABLE specialty (
                           specialty_id SERIAL NOT NULL,
                           name VARCHAR(100) NOT NULL,

                           CONSTRAINT pk_specialty PRIMARY KEY (specialty_id),
                           CONSTRAINT uq_specialty_name UNIQUE (name),
                           CHECK (length(name) > 0)
);

-- BUSINESS SPECIALTY
CREATE TABLE business_specialty (
                                    business_specialty_id SERIAL NOT NULL,
                                    business_id INT NOT NULL DEFAULT 1,
                                    specialty_id INT NOT NULL DEFAULT 1,

                                    CONSTRAINT pk_business_specialty PRIMARY KEY (business_specialty_id),
                                    CONSTRAINT uq_business_specialty_business_specialty UNIQUE (business_id, specialty_id),

                                    CONSTRAINT fk_business_specialty_business
                                        FOREIGN KEY (business_id) REFERENCES business(business_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                    CONSTRAINT fk_business_specialty_specialty
                                        FOREIGN KEY (specialty_id) REFERENCES specialty(specialty_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- EMPLOYEE BUSINESS SPECIALTY
CREATE TABLE employee_business_specialty (
                                             ebs_id SERIAL NOT NULL,
                                             employee_id INT NOT NULL DEFAULT 1,
                                             business_id INT NOT NULL DEFAULT 1,
                                             specialty_id INT NOT NULL DEFAULT 1,

                                             CONSTRAINT pk_employee_business_specialty PRIMARY KEY (ebs_id),
                                             CONSTRAINT uq_employee_business_specialty_triplet
                                                 UNIQUE (employee_id, business_id, specialty_id),

                                             CONSTRAINT fk_ebs_employee
                                                 FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                             CONSTRAINT fk_ebs_business
                                                 FOREIGN KEY (business_id) REFERENCES business(business_id)
                                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                             CONSTRAINT fk_ebs_specialty
                                                 FOREIGN KEY (specialty_id) REFERENCES specialty(specialty_id)
                                                     ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- SERVICE CATEGORY
CREATE TABLE service_category (
                                  service_category_id SERIAL NOT NULL,
                                  name VARCHAR(100),
                                  parent_category_id INT,

                                  CONSTRAINT pk_service_category PRIMARY KEY (service_category_id),

                                  CHECK (parent_category_id IS NULL OR parent_category_id <> service_category_id),

                                  CONSTRAINT fk_service_category_parent
                                      FOREIGN KEY (parent_category_id)
                                          REFERENCES service_category(service_category_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- SERVICE
CREATE TABLE service (
                         service_id SERIAL NOT NULL,
                         category_id INT DEFAULT 1,
                         name VARCHAR(100),
                         description TEXT,

                         CONSTRAINT pk_service PRIMARY KEY (service_id),

                         CHECK (length(name) > 0),

                         CONSTRAINT fk_service_category
                             FOREIGN KEY (category_id) REFERENCES service_category(service_category_id)
                                 ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- BUSINESS SERVICE
CREATE TABLE business_service (
                                  business_service_id SERIAL NOT NULL,
                                  business_id INT NOT NULL DEFAULT 1,
                                  service_id INT NOT NULL DEFAULT 1,
                                  price NUMERIC(10,2),
                                  duration_minutes INT,
                                  is_active BOOLEAN NOT NULL DEFAULT TRUE,

                                  CONSTRAINT pk_business_service PRIMARY KEY (business_service_id),
                                  CONSTRAINT uq_business_service_business_service UNIQUE (business_id, service_id),

                                  CHECK (price >= 0),
                                  CHECK (duration_minutes IS NULL OR duration_minutes > 0),

                                  CONSTRAINT fk_business_service_business
                                      FOREIGN KEY (business_id) REFERENCES business(business_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                  CONSTRAINT fk_business_service_service
                                      FOREIGN KEY (service_id) REFERENCES service(service_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- EMPLOYEE SERVICE
CREATE TABLE employee_service (
                                  employee_service_id SERIAL NOT NULL,
                                  employee_id INT NOT NULL DEFAULT 1,
                                  service_id INT NOT NULL DEFAULT 1,

                                  CONSTRAINT pk_employee_service PRIMARY KEY (employee_service_id),
                                  CONSTRAINT uq_employee_service_employee_service UNIQUE (employee_id, service_id),

                                  CONSTRAINT fk_employee_service_employee
                                      FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                  CONSTRAINT fk_employee_service_service
                                      FOREIGN KEY (service_id) REFERENCES service(service_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- BUSINESS LOCATION
CREATE TABLE business_location (
                                   location_id SERIAL NOT NULL,
                                   business_id INT NOT NULL DEFAULT 1,
                                   address VARCHAR(255),
                                   city VARCHAR(100),
                                   phone VARCHAR(20),

                                   CONSTRAINT pk_business_location PRIMARY KEY (location_id),

                                   CHECK (phone IS NULL OR phone ~ '^[0-9+()-]{6,20}$'),

                                   CONSTRAINT fk_business_location_business
                                       FOREIGN KEY (business_id) REFERENCES business(business_id)
                                           ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- BUSINESS HOUR
CREATE TABLE business_hour (
                               business_hours_id SERIAL NOT NULL,
                               business_id INT NOT NULL DEFAULT 1,
                               day_of_week VARCHAR(15),
                               open_time TIME,
                               close_time TIME,
                               is_open BOOLEAN NOT NULL DEFAULT TRUE,

                               CONSTRAINT pk_business_hour PRIMARY KEY (business_hours_id),

                               CHECK (open_time < close_time),

                               CONSTRAINT fk_business_hour_business
                                   FOREIGN KEY (business_id) REFERENCES business(business_id)
                                       ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- WORKING SCHEDULE
CREATE TABLE working_schedule (
                                  schedule_id SERIAL NOT NULL,
                                  employee_id INT NOT NULL DEFAULT 1,
                                  business_id INT NOT NULL DEFAULT 1,
                                  business_hours_id INT DEFAULT 1,
                                  day_of_week VARCHAR(15),
                                  start_time TIME,
                                  end_time TIME,
                                  is_working BOOLEAN NOT NULL DEFAULT TRUE,

                                  CONSTRAINT pk_working_schedule PRIMARY KEY (schedule_id),

                                  CHECK (start_time < end_time),

                                  CONSTRAINT fk_working_schedule_employee
                                      FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                  CONSTRAINT fk_working_schedule_business
                                      FOREIGN KEY (business_id) REFERENCES business(business_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                  CONSTRAINT fk_working_schedule_business_hour
                                      FOREIGN KEY (business_hours_id) REFERENCES business_hour(business_hours_id)
                                          ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- TIME SLOT
CREATE TABLE time_slot (
                           slot_id SERIAL NOT NULL,
                           employee_id INT NOT NULL DEFAULT 1,
                           business_id INT NOT NULL DEFAULT 1,
                           "date" DATE,
                           start_time TIME,
                           end_time TIME,
                           is_available BOOLEAN NOT NULL DEFAULT TRUE,

                           CONSTRAINT pk_time_slot PRIMARY KEY (slot_id),

                           CHECK (start_time < end_time),

                           CONSTRAINT fk_time_slot_employee
                               FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                   ON DELETE SET DEFAULT ON UPDATE CASCADE,

                           CONSTRAINT fk_time_slot_business
                               FOREIGN KEY (business_id) REFERENCES business(business_id)
                                   ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- APPOINTMENT
CREATE TABLE appointment (
                             appointment_id SERIAL NOT NULL,
                             customer_id INT NOT NULL DEFAULT 1,
                             employee_id INT NOT NULL DEFAULT 1,
                             business_id INT NOT NULL DEFAULT 1,
                             service_id INT NOT NULL DEFAULT 1,
                             slot_id INT NOT NULL DEFAULT 1,
                             status VARCHAR(50),
                             created_at TIMESTAMP(7),

                             CONSTRAINT pk_appointment PRIMARY KEY (appointment_id),

                             CHECK (status IN ('pending','confirmed','cancelled','completed')),

                             CONSTRAINT fk_appointment_customer
                                 FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_employee
                                 FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_business
                                 FOREIGN KEY (business_id) REFERENCES business(business_id)
                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_service
                                 FOREIGN KEY (service_id) REFERENCES service(service_id)
                                     ON DELETE SET DEFAULT ON UPDATE CASCADE,

                             CONSTRAINT fk_appointment_slot
                                 FOREIGN KEY (slot_id) REFERENCES time_slot(slot_id)
                                     ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- RESCHEDULE REQUEST
CREATE TABLE reschedule_request (
                                    request_id SERIAL NOT NULL,
                                    appointment_id INT NOT NULL DEFAULT 1,
                                    old_slot_id INT NOT NULL DEFAULT 1,
                                    new_slot_id INT NOT NULL DEFAULT 1,
                                    manager_id INT NOT NULL DEFAULT 1,
                                    employee_id INT,
                                    status VARCHAR(50),
                                    reason TEXT,
                                    created_at TIMESTAMP(7),

                                    CONSTRAINT pk_reschedule_request PRIMARY KEY (request_id),

                                    CHECK (old_slot_id <> new_slot_id),

                                    CONSTRAINT fk_reschedule_request_appointment
                                        FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                    CONSTRAINT fk_reschedule_request_old_slot
                                        FOREIGN KEY (old_slot_id) REFERENCES time_slot(slot_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                    CONSTRAINT fk_reschedule_request_new_slot
                                        FOREIGN KEY (new_slot_id) REFERENCES time_slot(slot_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                    CONSTRAINT fk_reschedule_request_manager
                                        FOREIGN KEY (manager_id) REFERENCES manager(manager_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE,

                                    CONSTRAINT fk_reschedule_request_employee
                                        FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                            ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- REVIEW
CREATE TABLE review (
                        review_id SERIAL NOT NULL,
                        appointment_id INT NOT NULL DEFAULT 1,
                        customer_id INT,
                        employee_id INT,
                        manager_id INT NOT NULL DEFAULT 1,
                        business_id INT,
                        rating INT,
                        comment TEXT,
                        created_at TIMESTAMP(7),

                        CONSTRAINT pk_review PRIMARY KEY (review_id),

                        CHECK (rating BETWEEN 1 AND 5),

                        CONSTRAINT fk_review_appointment
                            FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
                                ON DELETE SET DEFAULT ON UPDATE CASCADE,

                        CONSTRAINT fk_review_customer
                            FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
                                ON DELETE SET DEFAULT ON UPDATE CASCADE,

                        CONSTRAINT fk_review_employee
                            FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                ON DELETE SET DEFAULT ON UPDATE CASCADE,

                        CONSTRAINT fk_review_manager
                            FOREIGN KEY (manager_id) REFERENCES manager(manager_id)
                                ON DELETE SET DEFAULT ON UPDATE CASCADE,

                        CONSTRAINT fk_review_business
                            FOREIGN KEY (business_id) REFERENCES business(business_id)
                                ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- CANCELLATION
CREATE TABLE cancellation (
                              cancellation_id SERIAL NOT NULL,
                              appointment_id INT NOT NULL DEFAULT 1,
                              cancelled_by VARCHAR(50),
                              reason TEXT,
                              refund_amount NUMERIC(10,2),
                              created_at TIMESTAMP(7),
                              employee_id INT NOT NULL DEFAULT 1,

                              CONSTRAINT pk_cancellation PRIMARY KEY (cancellation_id),
                              CONSTRAINT uq_cancellation_appointment UNIQUE (appointment_id),

                              CHECK (refund_amount IS NULL OR refund_amount >= 0),

                              CONSTRAINT fk_cancellation_appointment
                                  FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id)
                                      ON DELETE SET DEFAULT ON UPDATE CASCADE,

                              CONSTRAINT fk_cancellation_employee
                                  FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                      ON DELETE SET DEFAULT ON UPDATE CASCADE
);

-- GALLERY ITEM
CREATE TABLE gallery_item (
                              gallery_item_id SERIAL NOT NULL,
                              business_id INT NOT NULL DEFAULT 1,
                              employee_id INT,
                              image_url VARCHAR(255),
                              description TEXT,
                              uploaded_at TIMESTAMP(7),

                              CONSTRAINT pk_gallery_item PRIMARY KEY (gallery_item_id),

                              CHECK (image_url IS NULL OR image_url ~* '^https?://'),

                              CONSTRAINT fk_gallery_item_business
                                  FOREIGN KEY (business_id) REFERENCES business(business_id)
                                      ON DELETE SET DEFAULT ON UPDATE CASCADE,

                              CONSTRAINT fk_gallery_item_employee
                                  FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
                                      ON DELETE SET DEFAULT ON UPDATE CASCADE
);
-- ========================
-- BASE TABLES
-- ========================
INSERT INTO role VALUES (1, 'default');

INSERT INTO "user"
VALUES (1, 'default@system.local', 'Aa123456!', TRUE, CURRENT_TIMESTAMP);

-- ========================
-- CORE ENTITIES
-- ========================
INSERT INTO customer
VALUES (1, 1, 'Default', 'Customer', '+38970000000', CURRENT_TIMESTAMP);

INSERT INTO employee
VALUES (1, 1, 'Default', 'Employee', CURRENT_DATE, NULL, TRUE, CURRENT_TIMESTAMP);

INSERT INTO manager
VALUES (1, 1, CURRENT_TIMESTAMP);

INSERT INTO business
VALUES (1, 'Default Business', 'Default description', '+38970000000', 'business@mail.com', CURRENT_TIMESTAMP);

-- ========================
-- SPECIALTY
-- ========================
INSERT INTO specialty
VALUES (1, 'Default Specialty');

INSERT INTO business_specialty
VALUES (1, 1, 1);

INSERT INTO employee_business_specialty
VALUES (1, 1, 1, 1);

-- ========================
-- USER ROLE
-- ========================
INSERT INTO user_role
VALUES (1, 1, 1);

-- ========================
-- RELATION TABLES
-- ========================
INSERT INTO business_manager
VALUES (1, 1, 1, CURRENT_TIMESTAMP, NULL);

INSERT INTO business_employee
VALUES (1, 1, 1, CURRENT_DATE, NULL);

INSERT INTO manager_employee_business
VALUES (1, 1, 1, 1, CURRENT_TIMESTAMP, NULL);

-- ========================
-- SERVICES
-- ========================
INSERT INTO service_category
VALUES (1, 'Default Category', NULL);

INSERT INTO service
VALUES (1, 1, 'Default Service', 'Default description');

INSERT INTO business_service
VALUES (1, 1, 1, 10.00, 30, TRUE);

INSERT INTO employee_service
VALUES (1, 1, 1);

-- ========================
-- LOCATION + HOURS
-- ========================
INSERT INTO business_location
VALUES (1, 1, 'Main Street 1', 'Skopje', '+38970000000');

INSERT INTO business_hour
VALUES (1, 1, 'Mon', '08:00', '17:00', TRUE);

-- ========================
-- WORKING SCHEDULE
-- ========================
INSERT INTO working_schedule
VALUES (1, 1, 1, 1, 'Mon', '08:00', '17:00', TRUE);

-- ========================
-- TIME SLOTS (2 REQUIRED)
-- ========================
INSERT INTO time_slot
VALUES (1, 1, 1, CURRENT_DATE, '10:00', '10:30', TRUE);

INSERT INTO time_slot
VALUES (2, 1, 1, CURRENT_DATE, '11:00', '11:30', TRUE);

-- ========================
-- APPOINTMENT
-- ========================
INSERT INTO appointment
VALUES (1, 1, 1, 1, 1, 1, 'confirmed', CURRENT_TIMESTAMP);

-- ========================
-- RESCHEDULE (FIXED)
-- ========================
INSERT INTO reschedule_request
VALUES (1, 1, 1, 2, 1, 1, 'pending', 'Change time', CURRENT_TIMESTAMP);

-- ========================
-- REVIEW
-- ========================
INSERT INTO review
VALUES (1, 1, 1, 1, 1, 1, 5, 'Great service', CURRENT_TIMESTAMP);

-- ========================
-- CANCELLATION
-- ========================
INSERT INTO cancellation
VALUES (1, 1, 'employee', 'No reason', 0.00, CURRENT_TIMESTAMP, 1);

-- ========================
-- GALLERY
-- ========================
INSERT INTO gallery_item
VALUES (1, 1, 1, 'https://example.com/image.jpg', 'Default image', CURRENT_TIMESTAMP);

ALTER SEQUENCE role_role_id_seq RESTART WITH 2;
ALTER SEQUENCE user_user_id_seq RESTART WITH 2;
ALTER SEQUENCE user_role_user_role_id_seq RESTART WITH 2;
ALTER SEQUENCE customer_customer_id_seq RESTART WITH 2;
ALTER SEQUENCE employee_employee_id_seq RESTART WITH 2;
ALTER SEQUENCE manager_manager_id_seq RESTART WITH 2;
ALTER SEQUENCE business_business_id_seq RESTART WITH 2;

ALTER SEQUENCE specialty_specialty_id_seq RESTART WITH 2;
ALTER SEQUENCE business_specialty_business_specialty_id_seq RESTART WITH 2;
ALTER SEQUENCE employee_business_specialty_ebs_id_seq RESTART WITH 2;

ALTER SEQUENCE business_manager_business_manager_id_seq RESTART WITH 2;
ALTER SEQUENCE business_employee_business_employee_id_seq RESTART WITH 2;
ALTER SEQUENCE manager_employee_business_meb_id_seq RESTART WITH 2;

ALTER SEQUENCE service_category_service_category_id_seq RESTART WITH 2;
ALTER SEQUENCE service_service_id_seq RESTART WITH 2;
ALTER SEQUENCE business_service_business_service_id_seq RESTART WITH 2;
ALTER SEQUENCE employee_service_employee_service_id_seq RESTART WITH 2;

ALTER SEQUENCE business_location_location_id_seq RESTART WITH 2;
ALTER SEQUENCE business_hour_business_hours_id_seq RESTART WITH 2;
ALTER SEQUENCE working_schedule_schedule_id_seq RESTART WITH 2;

-- IMPORTANT (2 rows inserted already)
ALTER SEQUENCE time_slot_slot_id_seq RESTART WITH 3;

ALTER SEQUENCE appointment_appointment_id_seq RESTART WITH 2;
ALTER SEQUENCE reschedule_request_request_id_seq RESTART WITH 2;
ALTER SEQUENCE review_review_id_seq RESTART WITH 2;
ALTER SEQUENCE cancellation_cancellation_id_seq RESTART WITH 2;
ALTER SEQUENCE gallery_item_gallery_item_id_seq RESTART WITH 2;