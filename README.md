# College Placement Management and Recruitment Database

A MySQL database project for managing college placements, student information, company recruitment, job applications, interviews, selections, and job offers.

## Project Overview

The **College Placement Management and Recruitment Database** organizes placement-related information in one relational database. It helps track students, their skills, company job openings, applications, interview results, and final offers.

The project also includes SQL queries to analyze placement statistics and recruitment activities.

## Project Objectives

- Store student, department, skill, and company details.
- Manage job roles and placement drives.
- Track student applications and interview rounds.
- Record selection results and job offers.
- Maintain data accuracy using keys and constraints.
- Generate useful reports using SQL queries.
- Demonstrate indexes, views, stored procedures, and triggers.

## Technologies Used

- **Database:** MySQL 8.0+
- **Database Tool:** MySQL Workbench
- **Language:** SQL

## Database Tables

The database is named `college_placement_db` and contains 12 tables.

| Table | Purpose |
|---|---|
| `departments` | Stores department information. |
| `students` | Stores student details, CGPA, backlogs, and placement status. |
| `skills` | Stores available skills and categories. |
| `student_skills` | Connects students with their skills and proficiency levels. |
| `companies` | Stores company and contact details. |
| `job_roles` | Stores job openings, eligibility criteria, and salary packages. |
| `placement_drives` | Stores placement drive details and schedules. |
| `company_drives` | Connects companies with placement drives. |
| `applications` | Tracks student applications and eligibility. |
| `interview_rounds` | Stores interview rounds, scores, and feedback. |
| `selections` | Records selection results and final scores. |
| `offers` | Stores offer details, annual CTC, and joining dates. |


## Project Features

### 1. Database and Table Creation
Creates the database and 12 tables with primary keys, foreign keys, unique constraints, and check constraints.

### 2. Sample Data
Adds sample records for students, departments, skills, companies, job roles, placement drives, applications, interviews, selections, and offers.

### 3. Indexes
Creates indexes on frequently searched columns to help improve query performance.

### 4. Views
Creates reusable views for student placement summaries, company job roles, application tracking, interview performance, recruitment statistics, skill profiles, and more.

### 5. Stored Procedures
Includes procedures to retrieve student details, count students by department, calculate average CGPA, check job eligibility, and generate recruitment summaries.

### 6. Triggers
Uses triggers to validate student CGPA, interview scores, offer amounts, and joining dates. Triggers also update student placement status after selection.

### 7. SQL Query Bank
Includes queries demonstrating joins, filtering, grouping, aggregate functions, subqueries, and conditional expressions.

## Final Demonstration Queries

The project includes eight queries for a project demonstration or review.

1. **Overall Database Summary:** Displays counts of students, companies, job roles, applications, selections, and offers.
2. **Department-Wise Placement Analysis:** Shows student counts, placement counts, and CGPA statistics for each department.
3. **Complete Application Tracking:** Displays application details along with student, department, company, and job role information.
4. **Company-Wise Recruitment Analysis:** Summarizes applications, selections, offers, selection scores, and highest CTC for each company.
5. **Highest Package Offered:** Identifies the student, company, job role, and offer details associated with the highest annual CTC.
6. **Student Skill Profile:** Displays student skills, skill categories, proficiency levels, and experience.
7. **Interview Performance Analysis:** Shows average and highest interview scores and the number of interview rounds.
8. **Final Selected Student and Offer Report:** Displays selected students, departments, CGPA, companies, roles, selection scores, and offer details.

## SQL Concepts Demonstrated

- Database and table creation
- Primary keys and foreign keys
- Unique and check constraints
- `INNER JOIN` and `LEFT JOIN`
- `WHERE`, `ORDER BY`, `GROUP BY`, and `HAVING`
- Aggregate functions such as `COUNT()`, `AVG()`, `SUM()`, `MIN()`, and `MAX()`
- Subqueries and `CASE` expressions
- Indexes and views
- Stored procedures with parameters
- Triggers and data validation

## How to Run the Project

### Prerequisites

- MySQL Server 8.0 or later
- MySQL Workbench
- The project SQL files downloaded or saved on your computer

## Project Location

The project files are stored locally in the following folder:

`Desktop/my sql/MySQL_project/`

The folder contains the following SQL files:

```text
MySQL_project/
├── college_placement_management_system.sql
└── sql_1.sql
```

### Steps to Execute the Project

1. Open **MySQL Workbench** on your Windows computer.
2. Connect to your local MySQL Server instance.
3. Select **File → Open SQL Script**.
4. Navigate to the following location:

   `Desktop → my sql → MySQL_project`

5. Open `college_placement_management_system.sql` to execute the main database project script.
6. Execute the SQL statements and check the Action Output panel for errors.
7. Refresh the Schemas panel and verify that `college_placement_db` has been created.
8. Run the final demonstration queries to verify the results.




### Verify the Database

After execution, refresh the **Schemas** panel in MySQL Workbench and confirm that `college_placement_db` is available.

Run:

sql
USE college_placement_db;

SHOW TABLES;


Confirm that the expected tables have been created before running the demonstration queries.

## Repository Structure

The local project folder currently contains the following SQL files:

text
project/
├── college_placement_management_system.sql
└── sql_1.sql



## Author
https://github.com/Vishalakshigottapu
