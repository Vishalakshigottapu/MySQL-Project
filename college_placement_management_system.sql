-- =====================================================================
-- COLLEGE PLACEMENT MANAGEMENT AND RECRUITMENT DATABASE
-- =====================================================================
--
-- PART 1  : Database & Table Creation
-- PART 2  : Sample Data
-- PART 3  : Indexes
-- PART 4  : Views
-- PART 5  : Stored Procedures
-- PART 6  : Triggers
-- PART 7  : Query Bank
-- RDBMS : MySQL 8.0+
-- =====================================================================

-- =====================================================================
-- PART 1: DATABASE & TABLE CREATION
-- =====================================================================

CREATE DATABASE IF NOT EXISTS college_placement_db;
USE college_placement_db;

-- =====================================================================
-- RESET EXISTING PROJECT OBJECTS
-- This only removes previously-created project objects so the original
-- queries below can be executed again without changing their content.
-- =====================================================================

USE college_placement_db;

DROP VIEW IF EXISTS vw_student_placement_summary;
DROP VIEW IF EXISTS vw_company_job_roles;
DROP VIEW IF EXISTS vw_placement_drive_participation;
DROP VIEW IF EXISTS vw_application_tracking;
DROP VIEW IF EXISTS vw_interview_performance;
DROP VIEW IF EXISTS vw_selection_offer_details;
DROP VIEW IF EXISTS vw_department_placement_statistics;
DROP VIEW IF EXISTS vw_company_recruitment_statistics;
DROP VIEW IF EXISTS vw_student_skill_profile;
DROP VIEW IF EXISTS vw_open_job_roles;

DROP TRIGGER IF EXISTS trg_student_before_insert;
DROP TRIGGER IF EXISTS trg_student_before_update;
DROP TRIGGER IF EXISTS trg_interview_before_insert;
DROP TRIGGER IF EXISTS trg_interview_before_update;
DROP TRIGGER IF EXISTS trg_selection_after_insert;
DROP TRIGGER IF EXISTS trg_selection_after_update;
DROP TRIGGER IF EXISTS trg_offer_before_insert;
DROP TRIGGER IF EXISTS trg_offer_date_validation;

DROP PROCEDURE IF EXISTS sp_get_student_details;
DROP PROCEDURE IF EXISTS sp_department_student_count;
DROP PROCEDURE IF EXISTS sp_department_average_cgpa;
DROP PROCEDURE IF EXISTS sp_check_student_eligibility;
DROP PROCEDURE IF EXISTS sp_company_recruitment_summary;
DROP PROCEDURE IF EXISTS sp_students_above_cgpa;
DROP PROCEDURE IF EXISTS sp_update_placement_status;
DROP PROCEDURE IF EXISTS sp_student_skill_profile;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS offers;
DROP TABLE IF EXISTS selections;
DROP TABLE IF EXISTS interview_rounds;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS company_drives;
DROP TABLE IF EXISTS placement_drives;
DROP TABLE IF EXISTS job_roles;
DROP TABLE IF EXISTS student_skills;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS departments;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- END OF RESET BLOCK
-- =====================================================================

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_code VARCHAR(20) NOT NULL UNIQUE,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    hod_name VARCHAR(100),
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- ============================================================
-- 2. STUDENTS
-- ============================================================

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    roll_no VARCHAR(30) NOT NULL UNIQUE,
    registration_no VARCHAR(30) UNIQUE,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    department_id INT NOT NULL,
    admission_year YEAR NOT NULL,
    graduation_year YEAR NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,
    backlogs INT DEFAULT 0,
    placement_status VARCHAR(30) DEFAULT 'Not Placed',

    CONSTRAINT chk_student_cgpa
        CHECK (cgpa BETWEEN 0.00 AND 10.00),

    CONSTRAINT chk_student_backlogs
        CHECK (backlogs >= 0),

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);
-- ============================================================
-- 3. SKILLS
-- ============================================================

CREATE TABLE skills (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    skill_category VARCHAR(50) NOT NULL,
    skill_level VARCHAR(30)
);
-- ============================================================
-- 4. STUDENT_SKILLS
-- ============================================================

CREATE TABLE student_skills (
    student_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level VARCHAR(30) NOT NULL,
    years_of_experience DECIMAL(3,1) DEFAULT 0.0,

    PRIMARY KEY (student_id, skill_id),

    FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    FOREIGN KEY (skill_id)
        REFERENCES skills(skill_id),

    CONSTRAINT chk_skill_experience
        CHECK (years_of_experience >= 0)
);
-- ============================================================
-- 5. COMPANIES
-- ============================================================

CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL UNIQUE,
    industry VARCHAR(100),
    company_type VARCHAR(50),
    headquarters VARCHAR(100),
    website VARCHAR(200),
    contact_person VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15),
    company_status VARCHAR(30) DEFAULT 'Active',
    registered_on DATE
);
-- ============================================================
-- 6. JOB_ROLES
-- ============================================================

CREATE TABLE job_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    role_title VARCHAR(100) NOT NULL,
    job_description VARCHAR(500),
    employment_type VARCHAR(50) DEFAULT 'Full-Time',
    work_location VARCHAR(100),
    minimum_cgpa DECIMAL(4,2),
    maximum_backlogs INT DEFAULT 0,
    minimum_graduation_year YEAR,
    salary_package DECIMAL(10,2),
    bond_required BOOLEAN DEFAULT FALSE,
    role_status VARCHAR(30) DEFAULT 'Open',

    CONSTRAINT chk_role_cgpa
        CHECK (minimum_cgpa BETWEEN 0.00 AND 10.00),

    CONSTRAINT chk_role_backlogs
        CHECK (maximum_backlogs >= 0),

    FOREIGN KEY (company_id)
        REFERENCES companies(company_id)
);
-- ============================================================
-- 7. PLACEMENT_DRIVES
-- ============================================================

CREATE TABLE placement_drives (
    drive_id INT AUTO_INCREMENT PRIMARY KEY,
    drive_name VARCHAR(150) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    drive_type VARCHAR(50) DEFAULT 'On-Campus',
    registration_start DATE,
    registration_end DATE,
    drive_start_date DATE,
    drive_end_date DATE,
    venue VARCHAR(150),
    drive_status VARCHAR(30) DEFAULT 'Upcoming',

    CONSTRAINT chk_drive_dates
        CHECK (registration_end >= registration_start)
);
-- ============================================================
-- 8. COMPANY_DRIVES
-- ============================================================

CREATE TABLE company_drives (
    company_drive_id INT AUTO_INCREMENT PRIMARY KEY,
    drive_id INT NOT NULL,
    company_id INT NOT NULL,
    registration_start DATE,
    registration_end DATE,
    eligible_departments VARCHAR(500),
    minimum_cgpa DECIMAL(4,2),
    maximum_backlogs INT DEFAULT 0,
    drive_status VARCHAR(30) DEFAULT 'Open',

    UNIQUE (drive_id, company_id),

    CONSTRAINT chk_company_drive_cgpa
        CHECK (minimum_cgpa BETWEEN 0.00 AND 10.00),

    CONSTRAINT chk_company_drive_backlogs
        CHECK (maximum_backlogs >= 0),

    FOREIGN KEY (drive_id)
        REFERENCES placement_drives(drive_id),

    FOREIGN KEY (company_id)
        REFERENCES companies(company_id)
);
-- ============================================================
-- 9. APPLICATIONS
-- ============================================================

CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    company_drive_id INT NOT NULL,
    role_id INT NOT NULL,
    application_date DATE NOT NULL,
    application_status VARCHAR(30) DEFAULT 'Applied',
    eligibility_status VARCHAR(30) DEFAULT 'Pending',
    resume_submitted BOOLEAN DEFAULT FALSE,
    remarks VARCHAR(255),

    UNIQUE (student_id, company_drive_id, role_id),

    FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    FOREIGN KEY (company_drive_id)
        REFERENCES company_drives(company_drive_id),

    FOREIGN KEY (role_id)
        REFERENCES job_roles(role_id)
);
-- ============================================================
-- 10. INTERVIEW_ROUNDS
-- ============================================================

CREATE TABLE interview_rounds (
    round_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    round_number INT NOT NULL,
    round_name VARCHAR(100) NOT NULL,
    scheduled_date DATETIME,
    interview_mode VARCHAR(30),
    interviewer_name VARCHAR(100),
    score DECIMAL(5,2),
    round_status VARCHAR(30) DEFAULT 'Scheduled',
    feedback VARCHAR(500),

    UNIQUE (application_id, round_number),

    CONSTRAINT chk_round_number
        CHECK (round_number > 0),

    CONSTRAINT chk_round_score
        CHECK (score IS NULL OR score BETWEEN 0 AND 100),

    FOREIGN KEY (application_id)
        REFERENCES applications(application_id)
);
-- ============================================================
-- 11. SELECTIONS
-- ============================================================

CREATE TABLE selections (
    selection_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL UNIQUE,
    selection_date DATE NOT NULL,
    selection_status VARCHAR(30) NOT NULL,
    final_score DECIMAL(5,2),
    selected_by VARCHAR(100),
    remarks VARCHAR(255),

    CONSTRAINT chk_selection_score
        CHECK (final_score IS NULL OR final_score BETWEEN 0 AND 100),

    FOREIGN KEY (application_id)
        REFERENCES applications(application_id)
);
-- ============================================================
-- 12. OFFERS
-- ============================================================

CREATE TABLE offers (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    selection_id INT NOT NULL UNIQUE,
    offer_date DATE NOT NULL,
    joining_date DATE,
    annual_ctc DECIMAL(10,2),
    offer_type VARCHAR(50) DEFAULT 'Full-Time',
    offer_status VARCHAR(30) DEFAULT 'Issued',
    offer_reference_no VARCHAR(50) UNIQUE,

    CONSTRAINT chk_offer_ctc
        CHECK (annual_ctc >= 0),

    CONSTRAINT chk_joining_date
        CHECK (joining_date IS NULL OR joining_date >= offer_date),

    FOREIGN KEY (selection_id)
        REFERENCES selections(selection_id)
);
-- =====================================================================
-- PART 2: SAMPLE DATA
-- =====================================================================

USE college_placement_db;


-- =====================================================================
-- 1. DEPARTMENTS
-- =====================================================================

INSERT INTO departments
(department_id, department_code, department_name, hod_name, location)
VALUES
(1, 'CSE',  'Computer Science and Engineering', 'Dr. Ramesh Kumar', 'Block A'),
(2, 'ECE',  'Electronics and Communication Engineering', 'Dr. S. Lakshmi', 'Block B'),
(3, 'EEE',  'Electrical and Electronics Engineering', 'Dr. Prasad Rao', 'Block C'),
(4, 'MECH', 'Mechanical Engineering', 'Dr. Arun Kumar', 'Block D'),
(5, 'CIVIL','Civil Engineering', 'Dr. Venkat Rao', 'Block E'),
(6, 'CHEM', 'Chemical Engineering', 'Dr. Kiran Kumar', 'Block F');


-- =====================================================================
-- 2. STUDENTS
-- =====================================================================

INSERT INTO students
(student_id, roll_no, registration_no, student_name, email, phone,
 department_id, admission_year, graduation_year, cgpa, backlogs, placement_status)
VALUES
(1, 'CSE001', 'REG2023CSE001', 'Arjun Reddy',
 'arjun.reddy@gmail.com', '9000000001', 1, 2023, 2027, 9.10, 0, 'Placed'),

(2, 'CSE002', 'REG2023CSE002', 'Priya Sharma',
 'priya.sharma@gmail.com', '9000000002', 1, 2023, 2027, 8.75, 0, 'Placed'),

(3, 'CSE003', 'REG2023CSE003', 'Rahul Verma',
 'rahul.verma@gmail.com', '9000000003', 1, 2023, 2027, 8.20, 1, 'Placed'),

(4, 'CSE004', 'REG2023CSE004', 'Sneha Reddy',
 'sneha.reddy@gmail.com', '9000000004', 1, 2023, 2027, 9.35, 0, 'Placed'),

(5, 'ECE001', 'REG2023ECE001', 'Kiran Kumar',
 'kiran.kumar@gmail.com', '9000000005', 2, 2023, 2027, 8.60, 0, 'Placed'),

(6, 'ECE002', 'REG2023ECE002', 'Ananya Rao',
 'ananya.rao@gmail.com', '9000000006', 2, 2023, 2027, 8.95, 0, 'Placed'),

(7, 'EEE001', 'REG2023EEE001', 'Vivek Singh',
 'vivek.singh@gmail.com', '9000000007', 3, 2023, 2027, 7.85, 1, 'Not Placed'),

(8, 'MECH001', 'REG2023MECH001', 'Rohit Kumar',
 'rohit.kumar@gmail.com', '9000000008', 4, 2023, 2027, 7.65, 2, 'Not Placed'),

(9, 'CIVIL001', 'REG2023CIVIL001', 'Pooja Devi',
 'pooja.devi@gmail.com', '9000000009', 5, 2023, 2027, 8.15, 0, 'Placed'),

(10, 'CHEM001', 'REG2023CHEM001', 'Sai Krishna',
 'sai.krishna@gmail.com', '9000000010', 6, 2023, 2027, 7.95, 0, 'Not Placed'),

(11, 'CSE005', 'REG2023CSE005', 'Megha Nair',
 'megha.nair@gmail.com', '9000000011', 1, 2023, 2027, 8.55, 0, 'Placed'),

(12, 'CSE006', 'REG2023CSE006', 'Aditya Rao',
 'aditya.rao@gmail.com', '9000000012', 1, 2023, 2027, 7.45, 2, 'Not Placed');


-- =====================================================================
-- 3. SKILLS
-- =====================================================================

INSERT INTO skills
(skill_id, skill_name, skill_category, skill_level)
VALUES
(1, 'Python', 'Programming', 'Advanced'),
(2, 'Java', 'Programming', 'Intermediate'),
(3, 'SQL', 'Database', 'Advanced'),
(4, 'JavaScript', 'Web Development', 'Intermediate'),
(5, 'React', 'Web Development', 'Intermediate'),
(6, 'Machine Learning', 'Artificial Intelligence', 'Intermediate'),
(7, 'Data Structures', 'Computer Science', 'Advanced'),
(8, 'HTML/CSS', 'Web Development', 'Advanced'),
(9, 'Cloud Computing', 'Cloud', 'Beginner'),
(10, 'Git', 'Tools', 'Intermediate');


-- =====================================================================
-- 4. STUDENT_SKILLS
-- =====================================================================

INSERT INTO student_skills
(student_id, skill_id, proficiency_level, years_of_experience)
VALUES
(1, 1, 'Advanced', 2.0),
(1, 3, 'Advanced', 2.0),
(1, 7, 'Advanced', 2.5),
(1, 10, 'Intermediate', 1.5),

(2, 1, 'Intermediate', 1.5),
(2, 3, 'Advanced', 2.0),
(2, 4, 'Advanced', 2.0),
(2, 5, 'Intermediate', 1.0),

(3, 2, 'Intermediate', 2.0),
(3, 3, 'Advanced', 2.0),
(3, 7, 'Advanced', 2.0),

(4, 1, 'Advanced', 2.5),
(4, 6, 'Advanced', 2.0),
(4, 7, 'Advanced', 2.5),

(5, 2, 'Advanced', 2.0),
(5, 3, 'Intermediate', 1.5),
(5, 10, 'Intermediate', 1.0),

(6, 1, 'Advanced', 2.0),
(6, 3, 'Advanced', 2.0),
(6, 6, 'Intermediate', 1.5),

(7, 3, 'Intermediate', 1.0),
(7, 8, 'Advanced', 2.0),

(8, 2, 'Intermediate', 1.5),
(8, 10, 'Intermediate', 1.0),

(9, 3, 'Intermediate', 1.0),
(9, 8, 'Advanced', 2.0),

(10, 1, 'Intermediate', 1.5),
(10, 3, 'Intermediate', 1.0),

(11, 1, 'Advanced', 2.0),
(11, 4, 'Intermediate', 1.5),
(11, 5, 'Intermediate', 1.0),
(11, 7, 'Advanced', 2.0),

(12, 3, 'Intermediate', 1.0),
(12, 7, 'Intermediate', 1.5);


-- =====================================================================
-- 5. COMPANIES
-- =====================================================================

INSERT INTO companies
(company_id, company_name, industry, company_type, headquarters,
 website, contact_person, contact_email, contact_phone,
 company_status, registered_on)
VALUES
(1, 'TechNova Solutions', 'Information Technology', 'Private',
 'Bangalore', 'https://technova.example.com',
 'Amit Sharma', 'amit@technova.example.com', '9100000001',
 'Active', '2026-01-10'),

(2, 'DataSphere Analytics', 'Data Analytics', 'Private',
 'Hyderabad', 'https://datasphere.example.com',
 'Neha Kapoor', 'neha@datasphere.example.com', '9100000002',
 'Active', '2026-01-15'),

(3, 'CloudMatrix Systems', 'Cloud Computing', 'Private',
 'Pune', 'https://cloudmatrix.example.com',
 'Ravi Mehta', 'ravi@cloudmatrix.example.com', '9100000003',
 'Active', '2026-01-20'),

(4, 'FinEdge Technologies', 'Financial Technology', 'Private',
 'Mumbai', 'https://finedge.example.com',
 'Kavya Rao', 'kavya@finedge.example.com', '9100000004',
 'Active', '2026-02-01'),

(5, 'InnovaSoft', 'Software Development', 'Private',
 'Chennai', 'https://innovasoft.example.com',
 'Suresh Kumar', 'suresh@innovasoft.example.com', '9100000005',
 'Active', '2026-02-05'),

(6, 'Global Systems Ltd', 'Information Technology', 'Public',
 'Bangalore', 'https://globalsystems.example.com',
 'Meena Iyer', 'meena@globalsystems.example.com', '9100000006',
 'Active', '2026-02-10'),

(7, 'AIWorks Technologies', 'Artificial Intelligence', 'Private',
 'Hyderabad', 'https://aiworks.example.com',
 'Vikram Rao', 'vikram@aiworks.example.com', '9100000007',
 'Active', '2026-02-15'),

(8, 'NextGen Digital', 'Digital Services', 'Private',
 'Delhi', 'https://nextgen.example.com',
 'Pavan Singh', 'pavan@nextgen.example.com', '9100000008',
 'Active', '2026-02-20');


-- =====================================================================
-- 6. JOB_ROLES
-- =====================================================================

INSERT INTO job_roles
(role_id, company_id, role_title, job_description, employment_type,
 work_location, minimum_cgpa, maximum_backlogs,
 minimum_graduation_year, salary_package, bond_required, role_status)
VALUES
(1, 1, 'Software Engineer',
 'Develop and maintain software applications',
 'Full-Time', 'Bangalore',
 7.50, 0, 2027, 850000.00, FALSE, 'Open'),

(2, 1, 'Backend Developer',
 'Develop REST APIs and backend services',
 'Full-Time', 'Bangalore',
 7.00, 1, 2027, 800000.00, FALSE, 'Open'),

(3, 2, 'Data Analyst',
 'Analyze business data and create reports',
 'Full-Time', 'Hyderabad',
 7.50, 0, 2027, 750000.00, FALSE, 'Open'),

(4, 2, 'Junior Data Scientist',
 'Build machine learning models and pipelines',
 'Full-Time', 'Hyderabad',
 8.00, 0, 2027, 900000.00, FALSE, 'Open'),

(5, 3, 'Cloud Engineer',
 'Design and maintain cloud infrastructure',
 'Full-Time', 'Pune',
 7.50, 0, 2027, 950000.00, TRUE, 'Open'),

(6, 4, 'Software Developer',
 'Develop financial technology applications',
 'Full-Time', 'Mumbai',
 7.00, 0, 2027, 780000.00, FALSE, 'Open'),

(7, 5, 'Full Stack Developer',
 'Develop frontend and backend applications',
 'Full-Time', 'Chennai',
 7.50, 0, 2027, 820000.00, FALSE, 'Open'),

(8, 6, 'Graduate Engineer Trainee',
 'Work on enterprise software projects',
 'Full-Time', 'Bangalore',
 7.00, 2, 2027, 650000.00, TRUE, 'Open'),

(9, 7, 'Machine Learning Engineer',
 'Develop and deploy machine learning solutions',
 'Full-Time', 'Hyderabad',
 8.00, 0, 2027, 1000000.00, FALSE, 'Open'),

(10, 8, 'Web Developer',
 'Develop responsive web applications',
 'Full-Time', 'Delhi',
 6.50, 2, 2027, 600000.00, FALSE, 'Open'),

(11, 5, 'Java Developer',
 'Develop Java based enterprise applications',
 'Full-Time', 'Chennai',
 7.00, 1, 2027, 700000.00, FALSE, 'Open'),

(12, 3, 'DevOps Engineer',
 'Automate deployment and infrastructure management',
 'Full-Time', 'Pune',
 7.50, 0, 2027, 900000.00, TRUE, 'Open');


-- =====================================================================
-- 7. PLACEMENT_DRIVES
-- =====================================================================

INSERT INTO placement_drives
(drive_id, drive_name, academic_year, drive_type,
 registration_start, registration_end,
 drive_start_date, drive_end_date, venue, drive_status)
VALUES
(1, 'Campus Recruitment Drive 2026 - Phase 1',
 '2026-27', 'On-Campus',
 '2026-08-01', '2026-08-10',
 '2026-08-15', '2026-08-20',
 'Main Auditorium', 'Completed'),

(2, 'Campus Recruitment Drive 2026 - Phase 2',
 '2026-27', 'On-Campus',
 '2026-09-01', '2026-09-10',
 '2026-09-15', '2026-09-22',
 'Placement Hall', 'Completed'),

(3, 'Technology Hiring Drive',
 '2026-27', 'On-Campus',
 '2026-10-01', '2026-10-10',
 '2026-10-15', '2026-10-25',
 'Main Auditorium', 'Upcoming'),

(4, 'Open Placement Drive',
 '2026-27', 'Off-Campus',
 '2026-11-01', '2026-11-10',
 '2026-11-15', '2026-11-20',
 'Online', 'Upcoming');


-- =====================================================================
-- 8. COMPANY_DRIVES
-- =====================================================================

INSERT INTO company_drives
(company_drive_id, drive_id, company_id,
 registration_start, registration_end,
 eligible_departments, minimum_cgpa,
 maximum_backlogs, drive_status)
VALUES
(1, 1, 1,
 '2026-08-01', '2026-08-10',
 'CSE,ECE', 7.50, 0, 'Completed'),

(2, 1, 2,
 '2026-08-01', '2026-08-10',
 'CSE,ECE', 7.50, 0, 'Completed'),

(3, 1, 5,
 '2026-08-01', '2026-08-10',
 'CSE,ECE', 7.00, 1, 'Completed'),

(4, 2, 3,
 '2026-09-01', '2026-09-10',
 'CSE,ECE', 7.50, 0, 'Completed'),

(5, 2, 4,
 '2026-09-01', '2026-09-10',
 'CSE,ECE,EEE', 7.00, 0, 'Completed'),

(6, 2, 6,
 '2026-09-01', '2026-09-10',
 'CSE,ECE,EEE,MECH', 7.00, 2, 'Completed'),

(7, 3, 7,
 '2026-10-01', '2026-10-10',
 'CSE,ECE', 8.00, 0, 'Open'),

(8, 3, 8,
 '2026-10-01', '2026-10-10',
 'CSE,ECE,MECH,CIVIL', 6.50, 2, 'Open');


-- =====================================================================
-- 9. APPLICATIONS
-- =====================================================================

INSERT INTO applications
(application_id, student_id, company_drive_id, role_id,
 application_date, application_status, eligibility_status,
 resume_submitted, remarks)
VALUES
(1,  1, 1, 1, '2026-08-03', 'Selected', 'Eligible', TRUE, 'Strong technical profile'),
(2,  2, 1, 1, '2026-08-03', 'Selected', 'Eligible', TRUE, 'Good coding skills'),
(3,  3, 1, 2, '2026-08-04', 'Selected', 'Eligible', TRUE, 'Backend experience'),

(4,  4, 2, 3, '2026-08-04', 'Selected', 'Eligible', TRUE, 'Excellent analytical skills'),
(5,  6, 2, 4, '2026-08-05', 'Selected', 'Eligible', TRUE, 'Strong ML background'),

(6,  5, 3, 7, '2026-08-05', 'Rejected', 'Eligible', TRUE, 'Rejected after interview'),
(7,  11, 3, 7, '2026-08-06', 'Selected', 'Eligible', TRUE, 'Good full stack skills'),

(8,  1, 4, 5, '2026-09-03', 'Selected', 'Eligible', TRUE, 'Cloud certification'),
(9,  4, 4, 12, '2026-09-03', 'Selected', 'Eligible', TRUE, 'Strong DevOps skills'),

(10, 2, 5, 6, '2026-09-04', 'Selected', 'Eligible', TRUE, 'Good programming skills'),
(11, 3, 6, 8, '2026-09-05', 'Selected', 'Eligible', TRUE, 'Eligible with one backlog'),
(12, 5, 6, 8, '2026-09-05', 'Rejected', 'Eligible', TRUE, 'Not selected'),

(13, 7, 6, 8, '2026-09-06', 'Rejected', 'Eligible', TRUE, 'Not selected'),
(14, 8, 6, 8, '2026-09-06', 'Rejected', 'Eligible', TRUE, 'Not selected'),

(15, 4, 7, 9, '2026-10-02', 'Applied', 'Eligible', TRUE, 'Application under review'),
(16, 6, 7, 9, '2026-10-02', 'Applied', 'Eligible', TRUE, 'Application under review'),
(17, 11, 8, 10, '2026-10-03', 'Applied', 'Eligible', TRUE, 'Application submitted'),
(18, 9, 8, 10, '2026-10-04', 'Applied', 'Eligible', TRUE, 'Application submitted');


-- =====================================================================
-- 10. INTERVIEW_ROUNDS
-- =====================================================================

INSERT INTO interview_rounds
(round_id, application_id, round_number, round_name,
 scheduled_date, interview_mode, interviewer_name,
 score, round_status, feedback)
VALUES
(1,  1, 1, 'Aptitude Test',
 '2026-08-12 10:00:00', 'Online', 'TechNova HR', 88, 'Completed',
 'Good aptitude performance'),

(2,  1, 2, 'Technical Interview',
 '2026-08-15 10:00:00', 'Online', 'Arun Mehta', 91, 'Completed',
 'Strong programming fundamentals'),

(3,  1, 3, 'HR Interview',
 '2026-08-18 11:00:00', 'Online', 'Priya Shah', 90, 'Completed',
 'Good communication'),

(4,  2, 1, 'Aptitude Test',
 '2026-08-12 10:00:00', 'Online', 'TechNova HR', 84, 'Completed',
 'Good performance'),

(5,  2, 2, 'Technical Interview',
 '2026-08-15 11:00:00', 'Online', 'Arun Mehta', 88, 'Completed',
 'Good technical knowledge'),

(6,  3, 1, 'Technical Interview',
 '2026-08-15 12:00:00', 'Online', 'TechNova Panel', 86, 'Completed',
 'Good backend knowledge'),

(7,  3, 2, 'HR Interview',
 '2026-08-18 12:00:00', 'Online', 'Priya Shah', 85, 'Completed',
 'Good communication'),

(8,  4, 1, 'Aptitude Test',
 '2026-08-12 10:30:00', 'Online', 'DataSphere HR', 90, 'Completed',
 'Excellent analytical ability'),

(9,  4, 2, 'Technical Interview',
 '2026-08-15 14:00:00', 'Online', 'Rahul Menon', 93, 'Completed',
 'Excellent SQL skills'),

(10, 5, 1, 'Technical Interview',
 '2026-08-15 15:00:00', 'Online', 'DataSphere Panel', 94, 'Completed',
 'Strong machine learning knowledge'),

(11, 5, 2, 'HR Interview',
 '2026-08-18 15:00:00', 'Online', 'DataSphere HR', 92, 'Completed',
 'Excellent communication'),

(12, 6, 1, 'Technical Interview',
 '2026-08-17 10:00:00', 'Online', 'InnovaSoft Panel', 68, 'Completed',
 'Needs improvement in problem solving'),

(13, 6, 2, 'HR Interview',
 '2026-08-19 10:00:00', 'Online', 'InnovaSoft HR', 65, 'Completed',
 'Average performance'),

(14, 7, 1, 'Technical Interview',
 '2026-08-17 11:00:00', 'Online', 'InnovaSoft Panel', 87, 'Completed',
 'Strong full stack knowledge'),

(15, 7, 2, 'HR Interview',
 '2026-08-19 11:00:00', 'Online', 'InnovaSoft HR', 89, 'Completed',
 'Good communication'),

(16, 8, 1, 'Technical Interview',
 '2026-09-12 10:00:00', 'Online', 'CloudMatrix Panel', 92, 'Completed',
 'Strong cloud fundamentals'),

(17, 8, 2, 'HR Interview',
 '2026-09-16 10:00:00', 'Online', 'CloudMatrix HR', 91, 'Completed',
 'Good leadership skills'),

(18, 9, 1, 'Technical Interview',
 '2026-09-12 11:00:00', 'Online', 'CloudMatrix Panel', 94, 'Completed',
 'Excellent DevOps knowledge'),

(19, 9, 2, 'HR Interview',
 '2026-09-16 11:00:00', 'Online', 'CloudMatrix HR', 93, 'Completed',
 'Excellent communication'),

(20, 10, 1, 'Technical Interview',
 '2026-09-13 10:00:00', 'Online', 'FinEdge Panel', 89, 'Completed',
 'Strong programming skills'),

(21, 10, 2, 'HR Interview',
 '2026-09-17 10:00:00', 'Online', 'FinEdge HR', 88, 'Completed',
 'Good performance'),

(22, 11, 1, 'Aptitude Test',
 '2026-09-14 10:00:00', 'Online', 'Global Systems HR', 80, 'Completed',
 'Good aptitude performance'),

(23, 11, 2, 'Technical Interview',
 '2026-09-18 10:00:00', 'Online', 'Global Systems Panel', 82, 'Completed',
 'Good technical skills'),

(24, 12, 1, 'Aptitude Test',
 '2026-09-14 11:00:00', 'Online', 'Global Systems HR', 72, 'Completed',
 'Average aptitude performance'),

(25, 12, 2, 'Technical Interview',
 '2026-09-18 11:00:00', 'Online', 'Global Systems Panel', 70, 'Completed',
 'Needs improvement'),

(26, 13, 1, 'Aptitude Test',
 '2026-09-14 12:00:00', 'Online', 'Global Systems HR', 64, 'Completed',
 'Average performance'),

(27, 13, 2, 'Technical Interview',
 '2026-09-18 12:00:00', 'Online', 'Global Systems Panel', 61, 'Completed',
 'Technical gaps'),

(28, 14, 1, 'Aptitude Test',
 '2026-09-14 13:00:00', 'Online', 'Global Systems HR', 60, 'Completed',
 'Average performance'),

(29, 14, 2, 'Technical Interview',
 '2026-09-18 13:00:00', 'Online', 'Global Systems Panel', 58, 'Completed',
 'Needs improvement');


-- =====================================================================
-- 11. SELECTIONS
-- =====================================================================

INSERT INTO selections
(selection_id, application_id, selection_date,
 selection_status, final_score, selected_by, remarks)
VALUES
(1,  1,  '2026-08-19', 'Selected', 90.00, 'TechNova Selection Panel',
 'Selected for Software Engineer'),

(2,  2,  '2026-08-19', 'Selected', 86.00, 'TechNova Selection Panel',
 'Selected for Software Engineer'),

(3,  3,  '2026-08-19', 'Selected', 85.50, 'TechNova Selection Panel',
 'Selected for Backend Developer'),

(4,  4,  '2026-08-19', 'Selected', 91.50, 'DataSphere Selection Panel',
 'Selected for Data Analyst'),

(5,  5,  '2026-08-19', 'Selected', 93.00, 'DataSphere Selection Panel',
 'Selected for Junior Data Scientist'),

(6,  7,  '2026-08-20', 'Selected', 88.00, 'InnovaSoft Selection Panel',
 'Selected for Full Stack Developer'),

(7,  8,  '2026-09-17', 'Selected', 91.50, 'CloudMatrix Selection Panel',
 'Selected for Cloud Engineer'),

(8,  9,  '2026-09-17', 'Selected', 93.50, 'CloudMatrix Selection Panel',
 'Selected for DevOps Engineer'),

(9,  10, '2026-09-18', 'Selected', 88.50, 'FinEdge Selection Panel',
 'Selected for Software Developer'),

(10, 11, '2026-09-19', 'Selected', 81.00, 'Global Systems Selection Panel',
 'Selected for Graduate Engineer Trainee');


-- =====================================================================
-- 12. OFFERS
-- =====================================================================

INSERT INTO offers
(offer_id, selection_id, offer_date, joining_date,
 annual_ctc, offer_type, offer_status, offer_reference_no)
VALUES
(1, 1, '2026-08-20', '2027-07-01',
 850000.00, 'Full-Time', 'Accepted', 'TN-2026-001'),

(2, 2, '2026-08-20', '2027-07-01',
 850000.00, 'Full-Time', 'Accepted', 'TN-2026-002'),

(3, 3, '2026-08-20', '2027-07-01',
 800000.00, 'Full-Time', 'Accepted', 'TN-2026-003'),

(4, 4, '2026-08-20', '2027-07-01',
 750000.00, 'Full-Time', 'Accepted', 'DS-2026-001'),

(5, 5, '2026-08-20', '2027-07-01',
 900000.00, 'Full-Time', 'Accepted', 'DS-2026-002'),

(6, 6, '2026-08-21', '2027-07-01',
 820000.00, 'Full-Time', 'Accepted', 'IS-2026-001'),

(7, 7, '2026-09-18', '2027-07-01',
 950000.00, 'Full-Time', 'Issued', 'CM-2026-001'),

(8, 8, '2026-09-18', '2027-07-01',
 900000.00, 'Full-Time', 'Issued', 'CM-2026-002'),

(9, 9, '2026-09-19', '2027-07-01',
 780000.00, 'Full-Time', 'Accepted', 'FE-2026-001'),

(10, 10, '2026-09-20', '2027-07-01',
 650000.00, 'Full-Time', 'Issued', 'GS-2026-001');


-- =====================================================================
-- END OF PART 2
-- =====================================================================
-- =====================================================================
-- PART 3: INDEXES
-- =====================================================================

USE college_placement_db;


-- =====================================================================
-- 1. STUDENTS
-- =====================================================================

-- Frequently search students by department
CREATE INDEX idx_students_department
ON students(department_id);

-- Useful for filtering students by CGPA
CREATE INDEX idx_students_cgpa
ON students(cgpa);

-- Useful for placement-status reports
CREATE INDEX idx_students_placement_status
ON students(placement_status);


-- =====================================================================
-- 2. STUDENT_SKILLS
-- =====================================================================

-- Search all skills belonging to a student
CREATE INDEX idx_student_skills_student
ON student_skills(student_id);

-- Search all students having a particular skill
CREATE INDEX idx_student_skills_skill
ON student_skills(skill_id);


-- =====================================================================
-- 3. JOB_ROLES
-- =====================================================================

-- Find all roles offered by a company
CREATE INDEX idx_job_roles_company
ON job_roles(company_id);

-- Useful when finding roles based on minimum CGPA
CREATE INDEX idx_job_roles_min_cgpa
ON job_roles(minimum_cgpa);

-- Search/filter open roles
CREATE INDEX idx_job_roles_status
ON job_roles(role_status);


-- =====================================================================
-- 4. COMPANY_DRIVES
-- =====================================================================

-- Find drives conducted by a particular company
CREATE INDEX idx_company_drives_company
ON company_drives(company_id);

-- Find companies participating in a particular placement drive
CREATE INDEX idx_company_drives_drive
ON company_drives(drive_id);

-- Useful for filtering open/completed drives
CREATE INDEX idx_company_drives_status
ON company_drives(drive_status);


-- =====================================================================
-- 5. APPLICATIONS
-- =====================================================================

-- Find all applications submitted by a student
CREATE INDEX idx_applications_student
ON applications(student_id);

-- Find applications for a particular company drive
CREATE INDEX idx_applications_company_drive
ON applications(company_drive_id);

-- Find applications for a particular job role
CREATE INDEX idx_applications_role
ON applications(role_id);

-- Useful for application-status reports
CREATE INDEX idx_applications_status
ON applications(application_status);

-- Useful for eligibility reports
CREATE INDEX idx_applications_eligibility
ON applications(eligibility_status);


-- =====================================================================
-- 6. INTERVIEW_ROUNDS
-- =====================================================================

-- Find all interview rounds for an application
CREATE INDEX idx_interview_application
ON interview_rounds(application_id);

-- Useful for filtering completed/scheduled interviews
CREATE INDEX idx_interview_status
ON interview_rounds(round_status);

-- Useful for date-based interview searches
CREATE INDEX idx_interview_scheduled_date
ON interview_rounds(scheduled_date);


-- =====================================================================
-- 7. SELECTIONS
-- =====================================================================

-- Search selections by selection status
CREATE INDEX idx_selections_status
ON selections(selection_status);

-- Useful for date-based selection reports
CREATE INDEX idx_selections_date
ON selections(selection_date);


-- =====================================================================
-- 8. OFFERS
-- =====================================================================

-- Search offers by offer status
CREATE INDEX idx_offers_status
ON offers(offer_status);

-- Useful for joining-date based reports
CREATE INDEX idx_offers_joining_date
ON offers(joining_date);

-- Useful for CTC-based analysis
CREATE INDEX idx_offers_ctc
ON offers(annual_ctc);


-- =====================================================================
-- 9. PLACEMENT DRIVES
-- =====================================================================

-- Search drives by academic year
CREATE INDEX idx_placement_drives_academic_year
ON placement_drives(academic_year);

-- Search drives by status
CREATE INDEX idx_placement_drives_status
ON placement_drives(drive_status);

-- Useful for date-based drive searches
CREATE INDEX idx_placement_drives_start_date
ON placement_drives(drive_start_date);


-- =====================================================================
-- END OF PART 3
-- =====================================================================
-- =====================================================================
-- PART 4: VIEWS
-- =====================================================================

USE college_placement_db;


-- =====================================================================
-- VIEW 1: STUDENT PLACEMENT SUMMARY
-- Shows student details along with department information
-- =====================================================================

CREATE OR REPLACE VIEW vw_student_placement_summary AS
SELECT
    s.student_id,
    s.roll_no,
    s.student_name,
    d.department_code,
    d.department_name,
    s.email,
    s.cgpa,
    s.backlogs,
    s.graduation_year,
    s.placement_status
FROM students s
INNER JOIN departments d
    ON s.department_id = d.department_id;


-- =====================================================================
-- VIEW 2: COMPANY JOB ROLE DETAILS
-- Shows companies and the roles offered by them
-- =====================================================================

CREATE OR REPLACE VIEW vw_company_job_roles AS
SELECT
    c.company_id,
    c.company_name,
    c.industry,
    j.role_id,
    j.role_title,
    j.employment_type,
    j.work_location,
    j.minimum_cgpa,
    j.maximum_backlogs,
    j.salary_package,
    j.bond_required,
    j.role_status
FROM companies c
INNER JOIN job_roles j
    ON c.company_id = j.company_id;


-- =====================================================================
-- VIEW 3: PLACEMENT DRIVE PARTICIPATION
-- Shows which companies participated in which placement drives
-- =====================================================================

CREATE OR REPLACE VIEW vw_placement_drive_participation AS
SELECT
    pd.drive_id,
    pd.drive_name,
    pd.academic_year,
    pd.drive_type,
    pd.drive_start_date,
    pd.drive_end_date,
    pd.venue,
    c.company_id,
    c.company_name,
    c.industry,
    cd.company_drive_id,
    cd.minimum_cgpa,
    cd.maximum_backlogs,
    cd.drive_status
FROM placement_drives pd
INNER JOIN company_drives cd
    ON pd.drive_id = cd.drive_id
INNER JOIN companies c
    ON cd.company_id = c.company_id;


-- =====================================================================
-- VIEW 4: APPLICATION TRACKING
-- Shows complete application information
-- =====================================================================

CREATE OR REPLACE VIEW vw_application_tracking AS
SELECT
    a.application_id,
    s.roll_no,
    s.student_name,
    d.department_name,
    c.company_name,
    j.role_title,
    a.application_date,
    a.application_status,
    a.eligibility_status,
    a.resume_submitted,
    a.remarks
FROM applications a
INNER JOIN students s
    ON a.student_id = s.student_id
INNER JOIN departments d
    ON s.department_id = d.department_id
INNER JOIN company_drives cd
    ON a.company_drive_id = cd.company_drive_id
INNER JOIN companies c
    ON cd.company_id = c.company_id
INNER JOIN job_roles j
    ON a.role_id = j.role_id;


-- =====================================================================
-- VIEW 5: INTERVIEW PERFORMANCE
-- Shows interview rounds and student performance
-- =====================================================================

CREATE OR REPLACE VIEW vw_interview_performance AS
SELECT
    ir.round_id,
    a.application_id,
    s.roll_no,
    s.student_name,
    c.company_name,
    j.role_title,
    ir.round_number,
    ir.round_name,
    ir.scheduled_date,
    ir.interview_mode,
    ir.interviewer_name,
    ir.score,
    ir.round_status,
    ir.feedback
FROM interview_rounds ir
INNER JOIN applications a
    ON ir.application_id = a.application_id
INNER JOIN students s
    ON a.student_id = s.student_id
INNER JOIN company_drives cd
    ON a.company_drive_id = cd.company_drive_id
INNER JOIN companies c
    ON cd.company_id = c.company_id
INNER JOIN job_roles j
    ON a.role_id = j.role_id;


-- =====================================================================
-- VIEW 6: SELECTION AND OFFER DETAILS
-- Shows selected students and their offers
-- =====================================================================

CREATE OR REPLACE VIEW vw_selection_offer_details AS
SELECT
    sel.selection_id,
    a.application_id,
    s.roll_no,
    s.student_name,
    d.department_name,
    c.company_name,
    j.role_title,
    sel.selection_date,
    sel.selection_status,
    sel.final_score,
    o.offer_id,
    o.offer_date,
    o.joining_date,
    o.annual_ctc,
    o.offer_type,
    o.offer_status,
    o.offer_reference_no
FROM selections sel
INNER JOIN applications a
    ON sel.application_id = a.application_id
INNER JOIN students s
    ON a.student_id = s.student_id
INNER JOIN departments d
    ON s.department_id = d.department_id
INNER JOIN company_drives cd
    ON a.company_drive_id = cd.company_drive_id
INNER JOIN companies c
    ON cd.company_id = c.company_id
INNER JOIN job_roles j
    ON a.role_id = j.role_id
LEFT JOIN offers o
    ON sel.selection_id = o.selection_id;


-- =====================================================================
-- VIEW 7: DEPARTMENT-WISE PLACEMENT STATISTICS
-- Uses GROUP BY and aggregate functions
-- =====================================================================

CREATE OR REPLACE VIEW vw_department_placement_statistics AS
SELECT
    d.department_id,
    d.department_code,
    d.department_name,
    COUNT(s.student_id) AS total_students,
    SUM(
        CASE
            WHEN s.placement_status = 'Placed' THEN 1
            ELSE 0
        END
    ) AS placed_students,
    SUM(
        CASE
            WHEN s.placement_status = 'Not Placed' THEN 1
            ELSE 0
        END
    ) AS not_placed_students,
    ROUND(AVG(s.cgpa), 2) AS average_cgpa,
    MAX(s.cgpa) AS highest_cgpa,
    MIN(s.cgpa) AS lowest_cgpa
FROM departments d
LEFT JOIN students s
    ON d.department_id = s.department_id
GROUP BY
    d.department_id,
    d.department_code,
    d.department_name;


-- =====================================================================
-- VIEW 8: COMPANY RECRUITMENT STATISTICS
-- Shows applications, selections and offers for each company
-- =====================================================================

CREATE OR REPLACE VIEW vw_company_recruitment_statistics AS
SELECT
    c.company_id,
    c.company_name,
    c.industry,
    COUNT(DISTINCT a.application_id) AS total_applications,
    COUNT(DISTINCT sel.selection_id) AS total_selections,
    COUNT(DISTINCT o.offer_id) AS total_offers,
    ROUND(AVG(sel.final_score), 2) AS average_selection_score,
    MAX(o.annual_ctc) AS highest_ctc,
    MIN(o.annual_ctc) AS lowest_ctc
FROM companies c
LEFT JOIN company_drives cd
    ON c.company_id = cd.company_id
LEFT JOIN applications a
    ON cd.company_drive_id = a.company_drive_id
LEFT JOIN selections sel
    ON a.application_id = sel.application_id
LEFT JOIN offers o
    ON sel.selection_id = o.selection_id
GROUP BY
    c.company_id,
    c.company_name,
    c.industry;


-- =====================================================================
-- VIEW 9: STUDENT SKILL PROFILE
-- Shows each student's skills and proficiency
-- =====================================================================

CREATE OR REPLACE VIEW vw_student_skill_profile AS
SELECT
    s.student_id,
    s.roll_no,
    s.student_name,
    sk.skill_id,
    sk.skill_name,
    sk.skill_category,
    ss.proficiency_level,
    ss.years_of_experience
FROM students s
INNER JOIN student_skills ss
    ON s.student_id = ss.student_id
INNER JOIN skills sk
    ON ss.skill_id = sk.skill_id;


-- =====================================================================
-- VIEW 10: OPEN JOB ROLES
-- Shows currently open job roles and eligibility criteria
-- =====================================================================

CREATE OR REPLACE VIEW vw_open_job_roles AS
SELECT
    c.company_name,
    c.industry,
    j.role_id,
    j.role_title,
    j.employment_type,
    j.work_location,
    j.minimum_cgpa,
    j.maximum_backlogs,
    j.minimum_graduation_year,
    j.salary_package,
    j.bond_required
FROM job_roles j
INNER JOIN companies c
    ON j.company_id = c.company_id
WHERE j.role_status = 'Open';


-- =====================================================================
-- END OF PART 4
-- =====================================================================
-- =====================================================================
-- PART 5: STORED PROCEDURES
-- =====================================================================

USE college_placement_db;


-- =====================================================================
-- PROCEDURE 1: GET STUDENT DETAILS
-- Demonstrates: IN parameter
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_get_student_details;

DELIMITER $$

CREATE PROCEDURE sp_get_student_details(
    IN p_student_id INT
)
BEGIN

    SELECT
        s.student_id,
        s.roll_no,
        s.student_name,
        d.department_name,
        s.email,
        s.cgpa,
        s.backlogs,
        s.placement_status
    FROM students s
    INNER JOIN departments d
        ON s.department_id = d.department_id
    WHERE s.student_id = p_student_id;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 2: GET DEPARTMENT STUDENT COUNT
-- Demonstrates: IN + OUT parameters
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_department_student_count;

DELIMITER $$

CREATE PROCEDURE sp_department_student_count(
    IN p_department_id INT,
    OUT p_student_count INT
)
BEGIN

    SELECT COUNT(*)
    INTO p_student_count
    FROM students
    WHERE department_id = p_department_id;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 3: CALCULATE DEPARTMENT AVERAGE CGPA
-- Demonstrates: IN + OUT parameters
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_department_average_cgpa;

DELIMITER $$

CREATE PROCEDURE sp_department_average_cgpa(
    IN p_department_id INT,
    OUT p_average_cgpa DECIMAL(5,2)
)
BEGIN

    SELECT ROUND(AVG(cgpa), 2)
    INTO p_average_cgpa
    FROM students
    WHERE department_id = p_department_id;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 4: CHECK STUDENT ELIGIBILITY FOR A JOB ROLE
-- Demonstrates: IN + OUT parameters
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_check_student_eligibility;

DELIMITER $$

CREATE PROCEDURE sp_check_student_eligibility(
    IN p_student_id INT,
    IN p_role_id INT,
    OUT p_eligibility VARCHAR(30)
)
BEGIN

    DECLARE v_student_cgpa DECIMAL(4,2);
    DECLARE v_student_backlogs INT;
    DECLARE v_graduation_year YEAR;

    DECLARE v_minimum_cgpa DECIMAL(4,2);
    DECLARE v_maximum_backlogs INT;
    DECLARE v_minimum_graduation_year YEAR;

    SELECT
        cgpa,
        backlogs,
        graduation_year
    INTO
        v_student_cgpa,
        v_student_backlogs,
        v_graduation_year
    FROM students
    WHERE student_id = p_student_id;

    SELECT
        minimum_cgpa,
        maximum_backlogs,
        minimum_graduation_year
    INTO
        v_minimum_cgpa,
        v_maximum_backlogs,
        v_minimum_graduation_year
    FROM job_roles
    WHERE role_id = p_role_id;

    IF v_student_cgpa >= v_minimum_cgpa
       AND v_student_backlogs <= v_maximum_backlogs
       AND v_graduation_year >= v_minimum_graduation_year THEN

        SET p_eligibility = 'Eligible';

    ELSE

        SET p_eligibility = 'Not Eligible';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 5: GET COMPANY RECRUITMENT SUMMARY
-- Demonstrates: IN parameter + JOIN + aggregate functions
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_company_recruitment_summary;

DELIMITER $$

CREATE PROCEDURE sp_company_recruitment_summary(
    IN p_company_id INT
)
BEGIN

    SELECT
        c.company_id,
        c.company_name,

        COUNT(DISTINCT a.application_id)
            AS total_applications,

        COUNT(DISTINCT sel.selection_id)
            AS total_selections,

        COUNT(DISTINCT o.offer_id)
            AS total_offers,

        ROUND(AVG(sel.final_score), 2)
            AS average_selection_score,

        MAX(o.annual_ctc)
            AS highest_ctc,

        MIN(o.annual_ctc)
            AS lowest_ctc

    FROM companies c

    LEFT JOIN company_drives cd
        ON c.company_id = cd.company_id

    LEFT JOIN applications a
        ON cd.company_drive_id = a.company_drive_id

    LEFT JOIN selections sel
        ON a.application_id = sel.application_id

    LEFT JOIN offers o
        ON sel.selection_id = o.selection_id

    WHERE c.company_id = p_company_id

    GROUP BY
        c.company_id,
        c.company_name;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 6: GET STUDENTS ABOVE A CGPA
-- Demonstrates: IN parameter + filtering
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_students_above_cgpa;

DELIMITER $$

CREATE PROCEDURE sp_students_above_cgpa(
    IN p_min_cgpa DECIMAL(4,2)
)
BEGIN

    SELECT
        student_id,
        roll_no,
        student_name,
        cgpa,
        backlogs,
        placement_status
    FROM students
    WHERE cgpa >= p_min_cgpa
    ORDER BY cgpa DESC;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 7: UPDATE STUDENT PLACEMENT STATUS
-- Demonstrates: INOUT parameter
--
-- p_status receives the requested status.
-- The procedure updates the student's status and returns
-- the final status through the same INOUT parameter.
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_update_placement_status;

DELIMITER $$

CREATE PROCEDURE sp_update_placement_status(
    IN p_student_id INT,
    INOUT p_status VARCHAR(30)
)
BEGIN

    UPDATE students
    SET placement_status = p_status
    WHERE student_id = p_student_id;

    SELECT placement_status
    INTO p_status
    FROM students
    WHERE student_id = p_student_id;

END $$

DELIMITER ;


-- =====================================================================
-- PROCEDURE 8: GET STUDENT SKILL PROFILE
-- Demonstrates: IN parameter + multiple JOINs
-- =====================================================================

DROP PROCEDURE IF EXISTS sp_student_skill_profile;

DELIMITER $$

CREATE PROCEDURE sp_student_skill_profile(
    IN p_student_id INT
)
BEGIN

    SELECT
        s.student_id,
        s.student_name,
        sk.skill_name,
        sk.skill_category,
        ss.proficiency_level,
        ss.years_of_experience
    FROM students s
    INNER JOIN student_skills ss
        ON s.student_id = ss.student_id
    INNER JOIN skills sk
        ON ss.skill_id = sk.skill_id
    WHERE s.student_id = p_student_id
    ORDER BY sk.skill_name;

END $$

DELIMITER ;


-- =====================================================================
-- END OF PART 5
-- =====================================================================
-- =====================================================================
-- PART 6: TRIGGERS
-- =====================================================================

USE college_placement_db;


-- =====================================================================
-- TRIGGER 1: VALIDATE STUDENT CGPA
-- Prevents invalid CGPA before inserting a student
-- =====================================================================

DROP TRIGGER IF EXISTS trg_student_before_insert;

DELIMITER $$

CREATE TRIGGER trg_student_before_insert
BEFORE INSERT ON students
FOR EACH ROW
BEGIN

    IF NEW.cgpa < 0 OR NEW.cgpa > 10 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CGPA must be between 0 and 10';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 2: VALIDATE STUDENT CGPA BEFORE UPDATE
-- Prevents invalid CGPA when student details are updated
-- =====================================================================

DROP TRIGGER IF EXISTS trg_student_before_update;

DELIMITER $$

CREATE TRIGGER trg_student_before_update
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN

    IF NEW.cgpa < 0 OR NEW.cgpa > 10 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CGPA must be between 0 and 10';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 3: VALIDATE INTERVIEW SCORE
-- Prevents interview score outside 0-100
-- =====================================================================

DROP TRIGGER IF EXISTS trg_interview_before_insert;

DELIMITER $$

CREATE TRIGGER trg_interview_before_insert
BEFORE INSERT ON interview_rounds
FOR EACH ROW
BEGIN

    IF NEW.score IS NOT NULL
       AND (NEW.score < 0 OR NEW.score > 100) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview score must be between 0 and 100';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 4: VALIDATE INTERVIEW SCORE BEFORE UPDATE
-- =====================================================================

DROP TRIGGER IF EXISTS trg_interview_before_update;

DELIMITER $$

CREATE TRIGGER trg_interview_before_update
BEFORE UPDATE ON interview_rounds
FOR EACH ROW
BEGIN

    IF NEW.score IS NOT NULL
       AND (NEW.score < 0 OR NEW.score > 100) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Interview score must be between 0 and 100';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 5: AUTOMATICALLY UPDATE STUDENT STATUS AFTER SELECTION
-- If a student is selected, their placement status becomes 'Placed'
-- =====================================================================

DROP TRIGGER IF EXISTS trg_selection_after_insert;

DELIMITER $$

CREATE TRIGGER trg_selection_after_insert
AFTER INSERT ON selections
FOR EACH ROW
BEGIN

    IF NEW.selection_status = 'Selected' THEN

        UPDATE students s
        INNER JOIN applications a
            ON s.student_id = a.student_id
        SET s.placement_status = 'Placed'
        WHERE a.application_id = NEW.application_id;

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 6: AUTOMATICALLY UPDATE STUDENT STATUS AFTER SELECTION UPDATE
-- =====================================================================

DROP TRIGGER IF EXISTS trg_selection_after_update;

DELIMITER $$

CREATE TRIGGER trg_selection_after_update
AFTER UPDATE ON selections
FOR EACH ROW
BEGIN

    IF NEW.selection_status = 'Selected' THEN

        UPDATE students s
        INNER JOIN applications a
            ON s.student_id = a.student_id
        SET s.placement_status = 'Placed'
        WHERE a.application_id = NEW.application_id;

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 7: VALIDATE OFFER CTC
-- Prevents negative annual CTC
-- =====================================================================

DROP TRIGGER IF EXISTS trg_offer_before_insert;

DELIMITER $$

CREATE TRIGGER trg_offer_before_insert
BEFORE INSERT ON offers
FOR EACH ROW
BEGIN

    IF NEW.annual_ctc IS NOT NULL
       AND NEW.annual_ctc < 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Annual CTC cannot be negative';

    END IF;

END $$

DELIMITER ;


-- =====================================================================
-- TRIGGER 8: VALIDATE OFFER JOINING DATE
-- Joining date cannot be before offer date
-- =====================================================================

DROP TRIGGER IF EXISTS trg_offer_date_validation;

DELIMITER $$

CREATE TRIGGER trg_offer_date_validation
BEFORE INSERT ON offers
FOR EACH ROW
BEGIN

    IF NEW.joining_date IS NOT NULL
       AND NEW.joining_date < NEW.offer_date THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Joining date cannot be earlier than offer date';

    END IF;

END $$

DELIMITER ;
-- =====================================================================
-- END OF PART 6
-- =====================================================================