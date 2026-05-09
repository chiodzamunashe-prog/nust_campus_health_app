# Firebase Production Setup Guide

This document outlines the steps taken to transition the NUST Campus Health App to the live Firebase environment.

## 1. Project Configuration
- **Project ID**: `nustdb`
- **Package Name**: `com.thefabone.nustcampushealthapp`
- **Platform**: Android (linked via `google-services.json`)

## 2. Enabled Services
The following services must be active in the Firebase Console:
- **Authentication**: Email/Password provider enabled.
- **Firestore**: Created in production mode.
- **Cloud Messaging**: Configured for push notifications.

## 3. Security Rules
The Firestore security rules have been updated to enforce role-based access control (RBAC):
- **Students**: Can only read/write their own records and book appointments.
- **Staff**: Can access patient records and clinical notes based on their professional role (GP, Psychiatrist, etc.).
- **Admin**: Full access to user management.

## 4. Maintenance
To create new staff accounts:
1. Register the user via the app.
2. Go to the Firestore Console.
3. Locate the user document in the `users` collection.
4. Manually update the `role` field from `student` to `gp`, `psychiatrist`, `pharmacist`, or `admin`.

---
*Last Updated: May 9, 2026*
