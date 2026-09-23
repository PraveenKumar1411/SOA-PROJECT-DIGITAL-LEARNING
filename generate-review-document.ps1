Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$outFile = Join-Path $PSScriptRoot 'AcademiaX_Project_Review.docx'
if (Test-Path $outFile) { Remove-Item -LiteralPath $outFile -Force }

function XmlEncode([string]$text) {
    [System.Security.SecurityElement]::Escape($text)
}

$body = New-Object System.Text.StringBuilder
[void]$body.Append('<w:body>')
function Add-Paragraph([string]$text, [string]$style = 'Normal') {
    $encoded = XmlEncode $text
    $styleXml = if ($style -eq 'Normal') { '' } else { '<w:pPr><w:pStyle w:val="' + $style + '"/></w:pPr>' }
    [void]$body.Append('<w:p>' + $styleXml + '<w:r><w:t xml:space="preserve">' + $encoded + '</w:t></w:r></w:p>')
}
function Add-Bullet([string]$text) {
    $encoded = XmlEncode $text
    [void]$body.Append('<w:p><w:pPr><w:pStyle w:val="ListParagraph"/><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr></w:pPr><w:r><w:t xml:space="preserve">' + $encoded + '</w:t></w:r></w:p>')
}

Add-Paragraph 'AcademiaX' 'Title'
Add-Paragraph 'Microservices-Based Academic Management Platform' 'Subtitle'
Add-Paragraph 'Project Review and Demonstration Document' 'Subtitle'
Add-Paragraph ''
Add-Paragraph '1. Executive Summary' 'Heading1'
Add-Paragraph 'AcademiaX is a service-oriented academic management platform built with Java, Spring Boot, Spring Cloud, PostgreSQL, and Maven. It separates authentication, users, courses, enrollments, payments, service discovery, and API routing into independent Spring Boot services. This design keeps business responsibilities clear, enables independent deployment, and demonstrates core microservices patterns.'
Add-Paragraph 'The local deployment has been configured for PostgreSQL database skill2 at localhost:5432. Hibernate uses ddl-auto=update, so the application creates or updates its database tables when the services start.'

Add-Paragraph '2. Problem Statement and Objective' 'Heading1'
Add-Paragraph 'Educational institutions need reliable handling of users, courses, enrollments, and tuition-related payments. A single monolithic application becomes difficult to change as these responsibilities grow. AcademiaX addresses this by dividing the application into focused services that communicate through REST and service discovery.'
Add-Bullet 'Manage user profiles for students, instructors, and administrators.'
Add-Bullet 'Create and maintain course information, including instructor and capacity.'
Add-Bullet 'Create enrollments while validating course availability and capacity.'
Add-Bullet 'Initiate a pending payment automatically after a successful enrollment.'
Add-Bullet 'Protect gateway-routed APIs using JWT authentication.'

Add-Paragraph '3. Technology Stack' 'Heading1'
Add-Bullet 'Java 25 and Spring Boot 4.1.1: application framework and executable WAR deployment.'
Add-Bullet 'Spring Cloud 2025.1.3 and Netflix Eureka: service registration and discovery.'
Add-Bullet 'Spring Cloud Gateway MVC: one entry point for client requests and load-balanced forwarding.'
Add-Bullet 'Spring Data JPA and Hibernate: object-relational mapping and repository access.'
Add-Bullet 'PostgreSQL: persistent storage, configured locally as database skill2.'
Add-Bullet 'OpenFeign: declarative service-to-service calls from Enrollment Service.'
Add-Bullet 'Spring Security, BCrypt, and JJWT: password hashing and JSON Web Token security.'
Add-Bullet 'Maven: build and package management.'

Add-Paragraph '4. Architecture' 'Heading1'
Add-Paragraph 'Client -> API Gateway (8080) -> Eureka-discovered services. The gateway forwards /auth, /users, /courses, /enrollments, and /payments requests to the matching service. All services register with Eureka Server (8761). The Enrollment Service calls Course Service and Payment Service through OpenFeign. Data services persist entities in PostgreSQL skill2.'
Add-Paragraph 'Service and port map:' 'Heading2'
Add-Bullet 'Eureka Server — port 8761 — registry for service discovery.'
Add-Bullet 'API Gateway — port 8080 — public API entry point and JWT filter.'
Add-Bullet 'Auth Service — port 8081 — registration, login, BCrypt password storage, JWT creation.'
Add-Bullet 'User Service — port 8082 — CRUD for user profiles.'
Add-Bullet 'Course Service — port 8083 — CRUD for courses and course capacity.'
Add-Bullet 'Enrollment Service — port 8084 — enrollment workflow, course validation, payment initiation.'
Add-Bullet 'Payment Service — port 8085 — CRUD for payment records.'

Add-Paragraph '5. Database Configuration' 'Heading1'
Add-Paragraph 'All data services use PostgreSQL on localhost:5432 with database name skill2. The default local username is postgres and the password is root. The configuration also supports DB_HOST, DB_PORT, DB_NAME, DB_USERNAME, and DB_PASSWORD environment variables, which allows deployment-specific values without changing source code.'
Add-Paragraph 'The key JPA setting is spring.jpa.hibernate.ddl-auto=update. For a local review demonstration, this creates or synchronizes tables automatically. For a production deployment, a controlled migration tool such as Flyway or Liquibase is recommended.'

Add-Paragraph '6. Main Domain Data' 'Heading1'
Add-Bullet 'AuthUser: id, username, encrypted password, role.'
Add-Bullet 'User: id, name, email, phone, role, department, studentId, instructorId.'
Add-Bullet 'Course: id, title, instructor, capacity.'
Add-Bullet 'Enrollment: id, studentId, courseId, status.'
Add-Bullet 'Payment: id, enrollmentId, amount, paymentStatus.'

Add-Paragraph '7. Core Enrollment Workflow' 'Heading1'
Add-Paragraph 'Step 1: A client sends POST /enrollments through the API Gateway with studentId, courseId, and status.'
Add-Paragraph 'Step 2: Enrollment Service calls Course Service through the Feign client to verify that the course exists.'
Add-Paragraph 'Step 3: Enrollment Service counts existing enrollments for that course and rejects the request when the configured course capacity has been reached.'
Add-Paragraph 'Step 4: The enrollment record is stored in PostgreSQL.'
Add-Paragraph 'Step 5: Enrollment Service calls Payment Service and creates a payment with default tuition amount 500.00 and status PENDING.'
Add-Paragraph 'Step 6: The enrollment response is returned to the client. If payment creation is unavailable, the enrollment remains stored and the service logs a notice; this is a simple resilience behavior for the current version.'

Add-Paragraph '8. Security Design' 'Heading1'
Add-Paragraph 'Auth Service exposes /auth/register and /auth/login. A registered password is encoded using BCrypt before persistence. On register or successful login, Auth Service returns a JWT containing the username and role. API Gateway allows public authentication and health endpoints, but requires Authorization: Bearer <token> for protected business APIs. The gateway validates the JWT and places the authenticated user and role into the Spring Security context.'
Add-Paragraph 'Review note: the JWT secret is currently present in code for local development. It should be moved to an environment variable or secret manager before production deployment.'

Add-Paragraph '9. API Reference for Demonstration' 'Heading1'
Add-Bullet 'POST /auth/register — body: username, password, role. Returns JWT, username, and role.'
Add-Bullet 'POST /auth/login — body: username and password. Returns JWT for subsequent requests.'
Add-Bullet 'POST, GET, GET /{id}, PUT /{id}, DELETE /{id} for /users.'
Add-Bullet 'POST, GET, GET /{id}, PUT /{id}, DELETE /{id} for /courses.'
Add-Bullet 'POST, GET, GET /{id}, PUT /{id}, DELETE /{id} for /enrollments.'
Add-Bullet 'POST, GET, GET /{id}, PUT /{id}, DELETE /{id} for /payments.'
Add-Bullet 'GET /gateway/status — confirms the API Gateway is available.'
Add-Bullet 'GET /actuator/health — Spring Boot health endpoint for operational checking.'

Add-Paragraph '10. Suggested Review Demo Script' 'Heading1'
Add-Paragraph '1. Open http://localhost:8761 and show that services are registered in Eureka.'
Add-Paragraph '2. Open http://localhost:8080/gateway/status and show the API Gateway status response.'
Add-Paragraph '3. Register a user with POST http://localhost:8080/auth/register. Copy the JWT from the response.'
Add-Paragraph '4. In Postman, add Authorization header: Bearer <JWT>. Create a course with POST http://localhost:8080/courses using title, instructor, and capacity.'
Add-Paragraph '5. Create an enrollment with POST http://localhost:8080/enrollments using studentId, courseId, and status.'
Add-Paragraph '6. Show GET /enrollments and GET /payments. Explain that creating the enrollment triggered the payment service call.'
Add-Paragraph '7. In pgAdmin, refresh skill2 -> Schemas -> public -> Tables and show the generated tables and inserted records.'

Add-Paragraph '11. Verified Local Run Status' 'Heading1'
Add-Paragraph 'During local verification, PostgreSQL was reachable at localhost:5432. Eureka Server returned HTTP 200 at port 8761. API Gateway health reported UP. User Service, Course Service, and Payment Service health endpoints reported PostgreSQL database status UP and showed Eureka-discovered services. This validates the local database connection, Spring Boot execution, service registration, and gateway availability.'

Add-Paragraph '12. Strengths and Future Enhancements' 'Heading1'
Add-Bullet 'Strength: clear separation of responsibilities and independently addressable services.'
Add-Bullet 'Strength: service discovery avoids hard-coded service host and port references.'
Add-Bullet 'Strength: enrollment logic demonstrates orchestration across course and payment services.'
Add-Bullet 'Enhancement: move the JWT secret and database password to environment secrets.'
Add-Bullet 'Enhancement: use database migrations, validation annotations, central configuration, and structured API error responses.'
Add-Bullet 'Enhancement: add circuit breakers/retries for remote calls and compensate payment failures using an event-driven workflow.'
Add-Bullet 'Enhancement: provide integration tests, Docker Compose, and monitoring dashboards for production readiness.'

Add-Paragraph '13. Conclusion' 'Heading1'
Add-Paragraph 'AcademiaX demonstrates a complete microservices workflow for academic administration. It combines independently deployable services, Eureka service discovery, API gateway routing, JWT protection, PostgreSQL persistence, and inter-service communication. The project is locally configured to run against skill2 and provides a practical foundation for further enhancement.'
[void]$body.Append('<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr></w:body>')

$documentXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' + $body + '</w:document>'
$stylesXml = @' 
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults/><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:rPr><w:sz w:val="22"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:sz w:val="44"/><w:color w:val="1F4E79"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:rPr><w:sz w:val="26"/><w:color w:val="5B9BD5"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:rPr><w:b/><w:sz w:val="30"/><w:color w:val="1F4E79"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:rPr><w:b/><w:sz w:val="26"/><w:color w:val="2F75B5"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="ListParagraph"><w:name w:val="List Paragraph"/></w:style></w:styles>
'@
$contentTypes = @' 
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/><Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/></Types>
'@
$rels = @' 
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
'@
$docRels = @' 
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/></Relationships>
'@
$numbering = @' 
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="•"/><w:lvlJc w:val="left"/></w:lvl></w:abstractNum><w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num></w:numbering>
'@

$zip = [System.IO.Compression.ZipFile]::Open($outFile, [System.IO.Compression.ZipArchiveMode]::Create)
function Add-ZipEntry([string]$name, [string]$content) {
    $entry = $zip.CreateEntry($name)
    $writer = New-Object System.IO.StreamWriter($entry.Open(), [System.Text.Encoding]::UTF8)
    $writer.Write($content)
    $writer.Dispose()
}
Add-ZipEntry '[Content_Types].xml' $contentTypes
Add-ZipEntry '_rels/.rels' $rels
Add-ZipEntry 'word/document.xml' $documentXml
Add-ZipEntry 'word/styles.xml' $stylesXml
Add-ZipEntry 'word/numbering.xml' $numbering
Add-ZipEntry 'word/_rels/document.xml.rels' $docRels
$zip.Dispose()
Write-Host "Created $outFile"
