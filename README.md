This project aims to provide pipeline to support the conversion of OMOP-CDM data to a simple RDF format. 

The dataset used as an example for conversion is a subset of the MIMIC-IV database that was converted to OMOP CDM v5.4 https://physionet.org/content/mimic-iv-demo-omop/0.9/. (Kallfelz, M., Tsvetkova, A., Pollard, T., Kwong, M., Lipori, G., Huser, V., Osborn, J., Hao, S., & Williams, A. (2021). MIMIC-IV demo data in the OMOP Common Data Model (version 0.9). PhysioNet. https://doi.org/10.13026/p1f5-7x35). 

The conversion is performed using the R2RML markup language, using R2RML-F (https://github.com/chrdebru/r2rml)

R language was used to parse the output data and format the .ttl file produced by R2RML

Protege is also required in order to proper format the resulting .ttl file

Detailed steps to reproduce the conversion of the example dataset:

1. You need a PostgreSQL server instance installed. Then you should create an sql/postgresql/my-mimic-iv-omop-cdm database and insert the mimic-iv-demo-omop data

2. Install R2RML using the instructions found in the repository

3. Set the /example/config.properties file found in the R2RML installation with your database connection details

4. Place the /mapping/ file in the /R2RML/example directory

5. Execute the conversion using the following command
```
$ java -jar r2rml-fat.jar config.properties
```
6. Use protege to simple open and save the file as in .ttl format

7. Execute the R script, changing the parameters if needed

8. Once again, use protege to simple open and save the file as in .ttl format
