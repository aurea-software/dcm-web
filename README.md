# Dockerized DCM web application
Docker for DCM web application

# Environment Variables
The container should be properly configured with following environment variables.

Key | Value | Description
:-- | :-- | :-- 
JDBC_URL | jdbc:postgresql://192.168.99.100:5432/mccdb | JDBC connection string.
DB_USERNAME | mccuser | Database user name.
DB_PASSWORD | mccuser | Database password.
GENERATE_DATABASE | false | Re-create the db from the JDBC_URL or not.
NIPR_USER | nipruser | NIPR PDB user name.
NIPR_PASSWORD | niprpass | NIPR PDB password.
NIPR_BETA | true | Use pdb-services-beta.nipr.com instead of pdb-services.nipr.com.
