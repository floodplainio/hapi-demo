CREATE TABLE Height (
    id VARCHAR PRIMARY KEY,
    subject VARCHAR,
    effectiveDateTime VARCHAR,
    issued VARCHAR,
    height FLOAT,
    unit VARCHAR
);

CREATE TABLE Patient (
   id VARCHAR PRIMARY KEY,
   lastName VARCHAR,
   firstName VARCHAR,
   textStatus VARCHAR,
   textDiv VARCHAR,
   gender VARCHAR,
   birthDate DATE
 );

 CREATE TABLE VideoCall {
   id VARCHAR PRIMARY KEY,
    status VARCHAR,
    patient_id VARCHAR
    planned_at TIMESTAMP,

 }