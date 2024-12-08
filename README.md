# RepBook – A Full-Stack iOS Fitness Tracking Application

RepBook is a comprehensive fitness tracking platform designed as a full-stack solution, integrating a native iOS front-end with a Node.js/Express backend and a PostgreSQL database. Users can track workouts, manage personal fitness metrics, and interact with an AI-based assistant for personalized exercise routines. The iOS front-end, built with SwiftUI, ensures a seamless and intuitive user experience, while the backend API securely handles data operations and authentication.

---

**Key Screens:**

**Personal Dashboard**  
![Personal Dashboard](https://github.com/user-attachments/assets/5ba9fb6a-a443-4630-a410-58f050833e32)

**Workout Builder**  
![Workout Builder](https://github.com/user-attachments/assets/fd344156-c0f8-4005-a561-59f4ff8404c2)

**AI-Assistant**  
![AI-Assistant](https://github.com/user-attachments/assets/0aa57b5b-f10f-408f-888f-5286a79993cd)

---

## Overview

- **Frontend (iOS)**: SwiftUI-based interface for user authentication, workout creation, metrics tracking, and integrated exercise search.
- **Backend (Node.js/Express)**: RESTful API providing account management, workout logging, exercise storage, and metrics retrieval.
- **Database (PostgreSQL)**: Central data repository for user accounts, metrics, workouts, and exercises.

---

## Table of Contents

1. [Installation and Setup](#installation-and-setup)  
2. [Environment Variables](#environment-variables)  
3. [Server Configuration](#server-configuration)  
4. [iOS Frontend Setup](#ios-frontend-setup)  
5. [RESTful API Endpoints](#restful-api-endpoints)  
6. [Example Code Snippets](#example-code-snippets)  
7. [Authentication Flow](#authentication-flow)  
8. [Development Notes](#development-notes)

---

## Installation and Setup

```bash
git clone https://github.com/AaronM26/RepBook.git
cd RepBook

```Backend Setup
cd backend
npm install

```Create a .env file as described in the Environment Variables section.
Replace any OpenAI or other API keys as needed.
Start the backend server:
node repbook.js

Database Setup (PostgreSQL)
	•	Ensure PostgreSQL is installed and running.
	•	Set up the database with the configured credentials. Default values can be found in repbook.js.
	•	Ensure tables (members, members_metrics, workouts, exercises, etc.) are created.

Server Configuration

The Node.js server runs on port 3000 by default. It uses express, body-parser, bcrypt, pg, and crypto. CORS is allowed by default. All incoming requests are logged with method, URL, headers, and body.

Authentication is handled via a custom authenticate middleware. Requests to protected endpoints must include memberId (in URL param) and Auth-Key (as a request header).


RESTful API Endpoints

Endpoint	Method	Description
/api/signup	POST	Register a new user
/api/login	POST	Authenticate and get auth_key
/api/checkUsername/:username	GET	Check if username is available
/api/exercises	GET	Fetch exercises (paginated)
/api/exercises	POST	Add exercises to create workout
/api/exercises/search	GET	Search exercises by criteria
/api/createWorkout/:memberId	POST	Create a new workout
/api/updateUserInfo/:memberId	POST	Update user personal info
/api/userDataAndMetrics/:memberId	GET	Fetch user data and metrics
/api/setGymMembership	POST	Set/update gym membership info
/api/workouts/:memberId	GET	Fetch workouts for a member
/api/membersMetrics/:memberId	GET	Fetch member’s metrics
/api/loggedWorkouts	POST	Log a completed workout
/workouts/:workoutId	PUT	Rename a workout
/workouts/:workoutId	DELETE	Delete a workout

Authentication Flow
	1.	User Signup: Client sends POST request with user details to /api/signup. Backend responds with member_id and auth_key.
	2.	User Login: Client sends credentials to /api/login, receives auth_key and member_id.
	3.	Protected Routes: Subsequent requests include memberId in the URL and Auth-Key header. Backend validates before allowing access.
