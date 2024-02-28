Dataset used for conversion was a subset of the MIMIC-IV database that was converted to OMOP CDM v5.4 https://physionet.org/content/mimic-iv-demo-omop/0.9/

The conversion was performed using the R2RML, an implementation of which can be found here https://github.com/chrdebru/r2rml

R language was used to parse the output data and format the .ttl file produced by R2RML

Protege is also required in order to proper format the resulting .ttl file

1. Create an sql/postgresql/mysql database and insert the mimic-iv-demo-omop data

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
