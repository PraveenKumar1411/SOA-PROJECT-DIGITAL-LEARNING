# AcademiaX local setup

This project is a Spring Boot microservice application. It is configured for a local PostgreSQL database named `skill2` on port `5432`, using user `postgres` and password `root`.

## Prerequisites

- Java 25 JDK (this machine already has it at `C:\Program Files\Java\jdk-25.0.2`)
- PostgreSQL running locally on port 5432
- Database `skill2` created; JPA creates/updates the tables at startup.

If you need to create the database in pgAdmin, run:

```sql
CREATE DATABASE skill2;
```

## Run

From the repository root in PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\run-all.ps1
```

The startup order is Eureka (`8761`), services (`8081`–`8085`), then the gateway (`8080`). The Eureka dashboard is at http://localhost:8761 and the API gateway is at http://localhost:8080.

The launcher runs the packaged WAR files in each service's `target` directory. If a WAR is missing after cloning the repository, open the service in your IDE and run Maven `package` once (or use a working Maven installation).

To use a different PostgreSQL user, host, port, database, or password without changing tracked files, set `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, or `DB_NAME` in the PowerShell session before starting.
