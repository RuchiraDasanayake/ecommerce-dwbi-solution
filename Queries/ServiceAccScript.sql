select * from fact_Order
SELECT SYSTEM_USER;
-- Grant SELECT permission on all tables
GRANT SELECT ON SCHEMA::dbo TO [Laxaa\svc_SSAS];

-- Optionally, grant INSERT, UPDATE, DELETE if required for processing data
GRANT INSERT, UPDATE, DELETE ON SCHEMA::dbo TO [Laxaa\svc_SSAS];

-- Grant EXECUTE permissions if needed (e.g., for stored procedures)
GRANT EXECUTE ON SCHEMA::dbo TO [Laxaa\svc_SSAS];

-- Add the service account to db_datareader (if it only needs read access)
EXEC sp_addrolemember 'db_datareader', 'Laxaa\svc_SSAS';

-- Add the service account to db_datawriter (if it needs to write data)
EXEC sp_addrolemember 'db_datawriter', 'Laxaa\svc_SSAS';
-- Grant Process permission on the SSAS database
GRANT PROCESS TO [Laxaa\svc_SSAS];
