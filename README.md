
# Car Rental Management System

A full-stack Java web application for managing car rentals and taxi bookings, with real-time GPS fleet tracking.

## Features

- **Car Rental** — search by brand, view availability, book online
- **Taxi Booking** — immediate and scheduled bookings
- **Live Fleet Map** — real-time GPS tracking on an interactive map
- **User Profiles** — view account info, last rental, last taxi booking, stats
- **Admin Panel** — manage fleet, view bookings, update GPS token
-**PayPal Integration** — online payments

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 17, Jakarta Servlet API |
| Frontend | JSP, Tailwind CSS |
| Database | MySQL |
| Server | Apache Tomcat |
| Maps | Leaflet + OpenStreetMap |

## Demo Accounts

Use these to log in and test the app:

| Role     | Username | Password   |
|----------|----------|------------|
| Customer | `user1`  | `123456`   |
| Customer | `johnd`  | `12485`    |
| Admin    | `admin`  | `admin123` |

## Getting Started

### 1. Prerequisites
- Java JDK 17+
- Apache Tomcat 10+
- MySQL 8+
- NetBeans or any Jakarta EE IDE

### 2. Database Setup

```bash
# Create the database
mysql -u root -e "CREATE DATABASE carrent_db;"

# Import the schema and demo data
mysql -u root carrent_db < database.sql