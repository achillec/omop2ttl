library(curl)
library(SPARQL)
library(DBI)
library(bit64)
library(lubridate)
library(dplyr)
source("qualityControlOmopFunctions.R")
source("sqlConnectionSettings.R")

#set the sparql endpoint
sparqlEndpoint<-"http://localhost:7200/repositories/omop_demo"

#set the ontology namespace
preffix="http://omop2rdf/mimicIV.owl#"


sqlSettings<-sqlConnectionSettings()

#set the postgresql connection
con <- dbConnect(RPostgres::Postgres(), dbname = sqlSettings$dbname, host=sqlSettings$host, 
                 port=sqlSettings$port, user=sqlSettings$user, password=sqlSettings$password)

#set the postgresql omop schema
sqlSchema<-"mimicredux"






tableList<-c("observation_period","visit_occurrence","visit_detail","condition_occurrence","observation","measurement","drug_exposure",
             "device_exposure","procedure_occurrence","specimen","note","death","drug_era","dose_era","condition_era")



for (omopTable in tableList){
  checkPersonCount(omopTable,sparqlEndpoint,sqlSchema,con)
  
}




tableList<-c("observation_period","visit_occurrence","visit_detail","condition_occurrence","observation","drug_exposure",
             "device_exposure","procedure_occurrence","specimen","drug_era","dose_era","condition_era")



abind<-NULL
for (omopTable in tableList){
  abind<-rbind(abind,compareRandomRecords(preffix,con,omopTable,TRUE))
}











