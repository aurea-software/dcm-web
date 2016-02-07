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

## Example
```
docker run -d --name dcm -p 8080:8080 -e JDBC_URL=jdbc:postgresql://192.168.99.100:5432/mccdb -e DB_USERNAME=mccuser -e DB_PASSWORD=mccuser -e NIPR_USER=niprchee -e NIPR_PASSWORD=chee12345 -e NIPR_BETA=true -e GENERATE_DATABASE=false -v /Users/alexey/Documents/aurea/webapps/dcm:/var/lib/tomcat7/webapps aurea/dcm-web
```
