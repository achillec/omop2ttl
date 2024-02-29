This project aims to provide pipeline to support the conversion of OMOP-CDM data to a simple RDF format. 

The conversion is performed using the R2RML markup language, using R2RML-F (https://github.com/chrdebru/r2rml)

R language was used to parse the output data and format the .ttl file produced by R2RML

Protege is also required in order to proper format the resulting .ttl file

Detailed steps to reproduce the conversion of an example dataset (requires about one hour):

1. Create a database schema (for example, you can call it "my-mimic-iv-omop-cdm" and set it under the "postgresql" database). 
Note: You need a PostgreSQL server instance installed before creating your database (https://www.postgresql.org/download/). 

2. Insert the mimic-iv-demo-omop data in this database: (a) You should first download a zip file from https://physionet.org/content/mimic-iv-demo-omop and unzip it. (b) import the CSV files that you will find in the OMOP data folder (e.g., mimic-iv-demo-data-in-the-omop-common-data-model-0.9\1_omop_data_csv). The dataset used as an example for conversion is a subset of the MIMIC-IV database that was converted to OMOP CDM v5.4 https://physionet.org/content/mimic-iv-demo-omop/0.9/. (Kallfelz, M., Tsvetkova, A., Pollard, T., Kwong, M., Lipori, G., Huser, V., Osborn, J., Hao, S., & Williams, A. (2021). MIMIC-IV demo data in the OMOP Common Data Model (version 0.9). PhysioNet. https://doi.org/10.13026/p1f5-7x35). 

Note 1: the import process can be done via any postgreSQL database client (e.g. dBeaver).
Note 2: the import process might be hindered by syntactic issues (e.g. sometimes the database would expect integer but the provided data might me incompatible). You can skip these specific records. This propably should not be a problem.

3. Install R2RML-F using the instructions found in their repository (https://github.com/chrdebru/r2rml). Note: If you use precompiled R2RML-F binaries, you will also need a config.properties file. You can find a sample config.properties file in https://github.com/chrdebru/r2rml/blob/master/example/config.properties

4. Define your local installation parameters in the properties of the config.properties file (e.g. connectionURL = jdbc:postgresql://localhost:5432/postgres and mappingFile = omop-r2rml-mapping.ttl).
Note 1: you can find the omop-r2rml-mapping.ttl in the github directory (folder "mapping")
Note 2: make sure that all the parameters in the config.properties file are correct (e.g., check your password) 

5. Execute the conversion using the following command
```
$ java -jar r2rml.jar config.properties
```

7. Use protege to simple open and save the file as in .ttl format

8. Execute the R script, changing the parameters if needed

9. Once again, use protege to simple open and save the file as in .ttl format
