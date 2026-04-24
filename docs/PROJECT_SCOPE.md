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
| 1 | **Psychiatrist Dashboard** | ✅ Completed | Dashboard for psychiatrists to manage appointments, view patient info, write/edit session notes, and issue prescriptions |
| 2 | **Student Portal / Home** | ✅ Completed | Student-facing home screen with health tips, announcements, and quick actions |
| 3 | **Appointment Booking** | ✅ Completed | Students book, track, and manage their own medical sessions via interactive calendar |
| 4 | **General Practitioner Dashboard** | ✅ Completed | Similar to Psychiatrist Dashboard but for GPs — patient queue, structured consultation forms, and medical certificates |
| 5 | **Health Records** | ✅ Completed | Integrated with summary views and session history |
| 6 | **Notifications & Reminders** | ✅ Completed | Push notifications and appointment reminders fully implemented |
| 7 | **Chat / Messaging** | 🔄 In Progress | Real-time messaging between students and healthcare providers |
| 8 | **Admin Panel** | ✅ Completed | Admin users manage staff accounts, roles, and view analytics |
| 9 | **Authentication & User Management** | ✅ Completed | Role-based login (student, admin, psy) with branded NUST theme |
| 10 | **Profile Management** | ✅ Completed | Basic profile viewing implemented |

---

## 2.5 Project Progress Summary

**Overall Completion: 90% (9 of 10 modules complete)**

| Category | Status | Progress |
|----------|--------|----------|
| Core Modules Completed | 9/10 | 90% ✅ |
| Psychiatrist Dashboard | 7/7 Features | 100% ✅ |
| GP Dashboard | 5/5 Features | 100% ✅ |
| Frontend/UI | Complete | 98% ✅ |
| Backend Integration | Firestore + Mock | 100% ✅ |
| Authentication | Role-based Auth | 100% ✅ |
| **Remaining Modules** | **1 of 10** | **10% 🔄** |
| - Chat / Messaging | Data Layer Done | 30% |

**Last Updated**: April 24, 2026  
**Latest Commit**: GP Dashboard Completed (Stats Banner, Structured Notes, Medical Certificates)

---

These are foundational pieces that other modules can build on top of:

*   **Firebase Integration**: `Firebase.initializeApp()` with graceful fallback to mock data.
*   **Auth Service**: Singleton `AuthService` with Firebase Auth + mock fallback (`psy` / `password`).
*   **Login Screen**: Form-based login with redirect support.
*   **Route Guard**: `onGenerateRoute` checks auth before accessing protected routes.
*   **Repository Pattern**: Abstract `DashboardRepository` interface with Firestore + Mock implementations.

---

## 4. Psychiatrist Dashboard — Detailed Status (100% Complete ✅)

### ✅ All Features Completed
*   **Dashboard screen**: Appointment list with patient names, times, and status badges.
*   **Accept / Decline**: Pending appointments show buttons that update Firestore/Mock status.
*   **Patient Summary**: Screen showing student details (student ID, age, summary).
*   **Session Notes**: Functional "Add Note" feature that saves per appointment.
*   **Firestore & Mock Repos**: Full database implementations for both local and live modes.
*   **Debug Banner**: Removed via `debugShowCheckedModeBanner: false`.
*   ✅ **Calendar View**: Visual schedule showing appointments by day/week using TableCalendar.
*   ✅ **Filtering & Search**: Filter appointments by status or patient name with chips and search textfield.
*   ✅ **Patient History**: See all past visits and notes for a patient in one view via ExpansionTiles.
*   ✅ **Edit/Delete Notes**: Ability to modify or remove existing session notes with PopupMenu.
*   ✅ **Completion Workflow**: Mark appointments as "Completed" with AppBar button.
*   ✅ **Prescriptions**: Full form to generate and save prescriptions (integrated with pharmacy dashboard).
*   ✅ **Real-time Streams**: Auto-refresh the UI when data changes in Firestore (StreamBuilder).

### 📋 Implementation Details
*   **Location**: `lib/psychiatrist_dashboard/`
*   **Files**: 
    - `dashboard_screen.dart` - Main dashboard with calendar, search, filter, list view
    - `patient_summary_screen.dart` - Patient details, notes, history, lab results
    - `models.dart` - Data models (Patient, Appointment, Note, Vitals)
    - `repository.dart` - Abstract repository interface
    - `firestore_repository.dart` - Firestore implementation
    - `mock_repository.dart` - Mock data implementation
*   **Database**: Firestore + Mock fallback
*   **Features**: Real-time updates, search, filtering, CRUD operations

---

## 5. How to Add a New Module

1.  **Create a folder** under `lib/` (e.g., `lib/student_portal/`).
2.  **Define models** in a `models.dart` file.
3.  **Create a repository interface** + Firestore + Mock implementations.
4.  **Build screens** using `FutureBuilder` or `StreamBuilder`.
5.  **Register your route** in `main.dart`'s `onGenerateRoute`.
6.  **Add to Drawer**: Add a navigation tile in `main.dart`.

---

## 6. Next Steps & Recommendations

### 🔴 High Priority (Next Phase)
1. **Chat / Messaging Module** (Currently in progress)
   - Real-time messaging between students & providers
   - Notification integration
   - Message persistence in Firestore

### 🟡 Medium Priority
3. Complete remaining push notification features
4. Performance optimization and testing
5. UI/UX polish and accessibility

### 🟢 Low Priority (Future)
4. Analytics dashboard enhancements
5. Mobile-specific optimizations
6. Offline support
7. Additional healthcare provider types

---

## 7. Team & Contributors

| Name | Email | Contributions |
|------|-------|----------------|
| chiodzamunashe-prog | chiodzamunashe@gmail.com | Core app development, Psychiatrist Dashboard |
| Blessings Mazenge | n02423594t@students.nust.ac.zw | Notifications & Reminders |
| Adam Rufaro Dzitiro | dzitiroadam4@gmail.com | Profile & Privacy |

---

## 8. Testing & Deployment

### Local Testing
- **Mock Mode**: Works without Firebase for development
- **Firestore Mode**: Connect to Firebase for production testing
- **Test Accounts**: 
  - Psychiatrist: `psy` / `password`
  - Admin: `admin` / `password`
  - Student: Any email

### Platforms Supported
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows Desktop
- ✅ macOS Desktop
- ✅ Linux Desktop
