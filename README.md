 ____            ____              _    
|  _ \ ___ _ __ | __ )  ___   ___ | | __
| |_) / _ \ '_ \|  _ \ / _ \ / _ \| |/ /
|  _ <  __/ |_) | |_) | (_) | (_) |   < 
|_| \_\___| .__/|____/ \___/ \___/|_|\_\
          |_|                           

Comprehensive iOS Fitness Tracking Application

===============================================

Table of Contents
-----------------
1. Installation and Setup
2. RESTful API Endpoints
3. Project Outline
4. Database Models
5. Normal Forms
6. SQL Queries

1. Installation and Setup
-------------------------

### Clone the Repository
```bash
git clone https://github.com/AaronM26/RepBook.git
cd RepBook
Backend Setup
bashCopycd ~/backend
npm install
# Replace OpenAI API Key in configuration
node repbook.js
Server Setup

Start Postgres server

Frontend Setup

Open RepBook.xcodeproj in Xcode
Replace Server IP with your Postgres server IP
Run the project in a simulator (iOS 17.2.0)


RESTful API Endpoints


+-------------------------------------+--------+--------------------------------+
| Endpoint                            | Method | Description                    |
+-------------------------------------+--------+--------------------------------+
| /api/signup                         | POST   | User Signup                    |
| /api/login                          | POST   | User Login                     |
| /api/checkUsername/:username        | GET    | Check Username Availability    |
| /api/exercises                      | POST   | Add Exercises to Workout       |
| /api/updateUserInfo/:memberId       | POST   | Update User Information        |
| /api/userDataAndMetrics/:memberId   | GET    | Fetch User Data and Metrics    |
| /api/setGymMembership               | POST   | Set Gym Membership             |
| /api/workouts/:memberId             | GET    | Get Workouts                   |
| /api/membersMetrics/:memberId       | GET    | Get Member's Metrics           |
| /api/createWorkout/:memberId        | POST   | Create Workout                 |
| /api/exercises                      | GET    | Fetch Exercises                |
+-------------------------------------+--------+--------------------------------+

Project Outline


Goal: Develop an application for users to create and store workouts,
comprising sets of exercises, and maintain user preferences to enable
LLM API-generated personalized workouts.
Key Features:

Member information storage
Administrative staff management
Exercise cataloging
Workout tracking
Physical metrics monitoring
Personal records tracking
Nutrition plan management
Achievements and goals tracking
Gym membership management
Personalized workout planning


Database Models


Refer to the following files for visual representations:

ER_model.png
DB_Schema.png


Normal Forms


The database adheres to the First (1NF), Second (2NF), and Third (3NF) Normal Forms,
ensuring data integrity and minimizing redundancy.

SQL Queries


The application utilizes various SQL queries for operations such as:

Account data insertion
Metrics data insertion
User authentication
Username availability checks
Workout management
User information updates
Gym membership handling
