# NUST Campus Health App — Project Scope & Status

## 1. Project Overview

**App Name:** NUST Campus Health App  
**Platform:** Flutter (Web, Android, iOS)  
**Backend:** Firebase (Firestore, Firebase Auth)  
**Repository:** [github.com/chiodzamunashe-prog/nust_campus_health_app](https://github.com/chiodzamunashe-prog/nust_campus_health_app)

The NUST Campus Health App is a mobile & web application for the National University of Science and Technology (NUST) that provides students and staff with convenient access to campus health services. The app connects students with healthcare professionals — including psychiatrists, general practitioners, and other specialists — through appointment management, health records, and real-time communication.

---

## 2. Full Project Modules (Scope)

The table below outlines all planned modules. Each module can be developed independently by a team member.

| # | Module | Status | Description |
|---|--------|--------|-------------|
| 1 | **Psychiatrist Dashboard** | 🟡 In Progress | Dashboard for psychiatrists to manage appointments, view patient info, and write session notes |
| 2 | **Student Portal / Home** | ✅ Completed | Student-facing home screen with health tips, announcements, quick actions |
| 3 | **Appointment Booking** | 🔴 Not Started | Students book, reschedule, and cancel appointments with available practitioners |
| 4 | **General Practitioner Dashboard** | 🔴 Not Started | Similar to Psychiatrist Dashboard but for GPs — patient queue, prescriptions |
| 5 | **Health Records** | 🔴 Not Started | Secure storage and retrieval of student medical history / visit records |
| 6 | **Notifications & Reminders** | 🟡 In Progress | Push notifications for upcoming appointments, medication reminders |
| 7 | **Chat / Messaging** | 🔴 Not Started | Real-time messaging between students and healthcare providers |
| 8 | **Admin Panel** | 🔴 Not Started | Admin users manage staff accounts, view analytics, system settings |
| 9 | **Authentication & User Management** | 🟡 In Progress | Login, registration, role-based access (student, psychiatrist, GP, admin) |
| 10 | **Profile Management** | 🟡 In Progress | Users view/edit profile, upload photo, manage privacy settings |

---

## 3. Shared Infrastructure (Already Built)

These are foundational pieces that other modules can build on top of:

*   **Firebase Integration**: `Firebase.initializeApp()` with graceful fallback to mock data.
*   **Auth Service**: Singleton `AuthService` with Firebase Auth + mock fallback (`psy` / `password`).
*   **Login Screen**: Form-based login with redirect support.
*   **Route Guard**: `onGenerateRoute` checks auth before accessing protected routes.
*   **Repository Pattern**: Abstract `DashboardRepository` interface with Firestore + Mock implementations.

---

## 4. Psychiatrist Dashboard — Detailed Status

### ✅ Completed
*   **Dashboard screen**: Appointment list with patient names, times, and status badges.
*   **Accept / Decline**: Pending appointments show buttons that update Firestore/Mock status.
*   **Patient Summary**: Screen showing student details (student ID, age, summary).
*   **Session Notes**: Functional "Add Note" feature that saves per appointment.
*   **Firestore & Mock Repos**: Full database implementations for both local and live modes.
*   **Debug Banner**: Removed via `debugShowCheckedModeBanner: false`.

### 🔴 Remaining Work (ToDo)
1.  **Calendar View**: Visual schedule showing appointments by day/week.
2.  **Filtering & Search**: Filter appointments by status or patient name.
3.  **Patient History**: See all past visits and notes for a patient in one view.
4.  **Edit/Delete Notes**: Ability to modify or remove existing session notes.
5.  **Completion Workflow**: Mark appointments as "Completed" after the session.
6.  **Prescriptions**: Form to generate and save prescriptions.
7.  **Real-time Streams**: Auto-refresh the UI when data changes in Firestore.

---

## 5. How to Add a New Module

1.  **Create a folder** under `lib/` (e.g., `lib/student_portal/`).
2.  **Define models** in a `models.dart` file.
3.  **Create a repository interface** + Firestore + Mock implementations.
4.  **Build screens** using `FutureBuilder` or `StreamBuilder`.
5.  **Register your route** in `main.dart`'s `onGenerateRoute`.
6.  **Add to Drawer**: Add a navigation tile in `main.dart`.
