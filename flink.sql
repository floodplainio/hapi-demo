CREATE TABLE Immunization (
    id STRING,
    status STRING,
    vaccineCode ROW < coding ARRAY < ROW < `SYSTEM` STRING,
    code STRING,
    display STRING >>,
    text STRING >,
    patient ROW < reference STRING >,
    encounter ROW < reference STRING >,
    occurrenceDateTime STRING,
    primarySource boolean
)
WITH (
    'connector' = 'kafka',
    'topic' = 'FHIRCDC-Immunization',
    'format' = 'debezium-json',
    'scan.startup.mode' = 'earliest-offset',
    'properties.bootstrap.servers' = 'redpanda:29092',
    'properties.group.id' = 'fhir_analytics'
);

CREATE TABLE Patient (
    id STRING,
    meta ROW < versionId STRING, lastUpdated STRING >,
    text ROW < status STRING,div STRING >,
    status STRING,
    name ARRAY < ROW < `use` STRING, family STRING, given ARRAY < STRING > > >,
    identifier ARRAY < ROW < type ROW < coding ARRAY < ROW < `system` STRING, code STRING, display STRING > >, text STRING >,`system` STRING,`value` STRING > >,
    gender STRING,
    birthDate STRING,
    parsedBirthDate AS TO_DATE(birthDate)
)
WITH (
    'connector' = 'kafka',
    'topic' = 'FHIRCDC-Patient',
    'format' = 'debezium-json',
    'scan.startup.mode' = 'earliest-offset',
    'properties.bootstrap.servers' = 'redpanda:29092',
    'properties.group.id' = 'fhir_analytics'
);

CREATE TABLE imm (
    payload STRING
)
WITH (
    'connector' = 'kafka',
    'topic' = 'FHIRCDC-Immunization',
    'format' = 'raw',
    'scan.startup.mode' = 'earliest-offset',
    'properties.bootstrap.servers' = 'redpanda:29092',
    'properties.group.id' = 'fhir_analytics'
);


CREATE VIEW PatientView AS
SELECT
    id,
    name[1].family as lastName,
    name[1].given[1] as firstName,
    text.status as textStatus,
    text.div as textDiv,
    gender,
    parsedBirthDate as birthDate
FROM
    Patient


SELECT
    Ids. `value` AS syntheaid,
    id,
    name[1].family AS name,
    `value`
FROM
    patient
    CROSS JOIN UNNEST(identifier) AS Ids (type,
        `system`,
        `value`)
WHERE
    `system` = 'https://github.com/synthetichealth/synthea'
    AND Ids. `value` = '41166989-975d-4d17-b9de-17f94cb3eec1' 
    
    
-- CREATE VIEW patientview AS
--     SELECT
--         Ids. `value` AS syntheaid,
--         id,
--         name[1].family AS name
--     FROM
--         patient
--     CROSS JOIN UNNEST(identifier) AS Ids (type,
--         `system`,
--         `value`)
-- WHERE
--     `system` = 'https://github.com/synthetichealth/synthea'

SELECT
    *
FROM
    patient,
    Immunization
WHERE
    concat('urn:uuid:', patient.id) = Immunization.patient.reference;



CREATE TABLE Observation (
    id STRING,
    status STRING,
    category ARRAY<ROW<coding ARRAY<ROW<`SYSTEM` STRING, code STRING, display STRING>>>>,
    code ROW<coding ARRAY<ROW<`SYSTEM` STRING, code STRING, display STRING>>, text STRING>,
    subject ROW<reference STRING>,
    encounter ROW<reference STRING>,
    effectiveDateTime STRING,
--    parsedEffectiveDateTime AS TO_TIMESTAMP(effectiveDateTime,'yyyy-MM-dd HH:mm:ssZZZ'),
    issued STRING,
--    parsedIssued AS TO_TIMESTAMP(issued,'yyyy-MM-dd HH:mm:ss.SSSZZZ'),
    valueQuantity ROW<`value` DOUBLE,unit STRING,`system` STRING, code STRING>
) WITH (
    'connector' = 'kafka',
    'topic' = 'FHIRCDC-Observation',
    'format' = 'debezium-json',
    'scan.startup.mode' = 'earliest-offset',
    'properties.bootstrap.servers' = 'redpanda:29092',
    'properties.group.id' = 'fhir_analytics'
);

-- 2019-02-24T06:12:06-05:00
-- 2013-12-29T21:19:43.522-05:00
-- 2019-02-24T06:12:06.826-05:00
-- yyyy-MM-ddTHH:mm:ss.SSSZ

SELECT DATE_FORMAT(CURRENT_TIMESTAMP(),'yyyy-MM-dd HH:mm:ss.SSSZZZ')

CREATE VIEW Height as
SELECT id,o.subject.reference as subject, o.effectiveDateTime, o.issued, o.valueQuantity.`value` as height,o.valueQuantity.unit 
    FROM Observation o CROSS JOIN UNNEST(o.code.coding) AS observation_coding(`system`,code,display) 
    WHERE observation_coding.code = '8302-2';


CREATE CATALOG analytics WITH (
    'type'='jdbc',
    'property-version'='1',
    'base-url'='jdbc:postgresql://analytics-postgres:5432/',
    'default-database'='analytics',
    'username'='postgres',
    'password'='mysecretpassword'
);

INSERT INTO analytics.analytics.patient SELECT * from PatientView;
INSERT INTO analytics.analytics.height SELECT * from Height;

SELECT p.lastName,p.firstName,h.height 
FROM Height h,PatientView p 
WHERE h.subject = CONCAT('urn:uuid:',p.id);

select * from height h, patient p, where p.id = h.subject

SELECT p.*, max(h.height) FROM patient p, height h 
	WHERE concat('urn:uuid:', p.id) = h.subject 
	GROUP BY p.id
