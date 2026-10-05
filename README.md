Bank Enrollment Data Warehouse

Overview

This project is a simple ETL and data warehouse project using SQL Server.

The project takes raw banking activity data, loads it into a staging database, performs basic data cleaning, and then loads the cleaned data into a data warehouse.

Process

Raw Data
   ↓
Staging Database
   ↓
Data Cleaning
   ↓
Data Quality Checks
   ↓
Data Warehouse

Databases

Two databases were created:

stg_bank_enroll – staging and data preparation

dwh_bank_enroll – final data warehouse

Data Model

The warehouse uses a simple star schema with:

Dimensions

Customer

Account

Channel

Location

Date

Event

Interaction

Transaction

Fact

Enrollment

Key ETL Activities

Loaded the raw activity extract into staging

Created dimension and fact tables

Cleaned selected data fields

Performed basic data quality checks

Loaded the cleaned dimensions into the data warehouse

Mapped staging records to the correct DWH surrogate keys

Loaded the DWH fact table

Added checks to reduce duplicate fact records

Tools

SQL Server

SQL Server Management Studio (SSMS)

SSIS

Purpose

This project was created as a practical exercise to improve my understanding of SQL, ETL processes, SSIS, dimensional modelling and data warehousing.
