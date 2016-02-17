# Dockerized DCM web application (Enterprise Release)
Docker image for DCM web application (Enterprise Release)

# Environment Variables
The container should be properly configured with following environment variables.

Key | Value | Description
:-- | :-- | :-- 
JDBC_URL | jdbc:postgresql://192.168.99.100:5432/mccdb | JDBC connection string.
DB_USERNAME | mccuser | Database user name.
DB_PASSWORD | mccuser | Database password.
GENERATE_DATABASE | false | Re-create the db specified in the JDBC_URL or not.
NIPR_USER | nipripmserver | NIPR PDB user name.
NIPR_PASSWORD | e982DHN6QRB8CPGV | NIPR PDB password.
NIPR_BETA | true | Use pdb-services-beta.nipr.com instead of pdb-services.nipr.com.

## Example
```
docker run -d --name dcm -p 8080:8080 -e JDBC_URL=jdbc:postgresql://192.168.99.100:5432/mccdb -e DB_USERNAME=mccuser -e DB_PASSWORD=mccuser -e NIPR_USER=nipripmserver -e NIPR_PASSWORD=e982DHN6QRB8CPGV -e NIPR_BETA=true -e GENERATE_DATABASE=false -v /Users/alexey/Documents/aurea/webapps/dcm:/var/lib/tomcat7/webapps aurea/dcm-web
```
