

removePreffix<-function(x,preffix="http://omop2rdf/mimicIV.owl#"){
  
  if (nrow(x)<=1){
    x$person<-gsub(preffix,"",x$person)
    return(x)
  }
  as.data.frame(apply(x,2,function(y) gsub(preffix,"",y)))
  
}

checkPersonCount<-function(omopTable,sparqlEndpoint,sqlSchema,con){
  print(paste0("checking ",omopTable," for numbers of records per patient"))
  sparqlQuery<-gsub("drug_exposure",omopTable,Q_drg_exp_count)
  sparqlResults<-SPARQL(url = sparqlEndpoint, query = sparqlQuery, format = "csv")$result
  sparqlResults<-removePreffix(sparqlResults)
  sparqlResults$person<-as.character(sparqlResults$person)
  sparqlResults$count<-as.numeric(sparqlResults$count)
  sparqlResults<-sparqlResults[order(sparqlResults$person,decreasing = T),]
  row.names(sparqlResults)<-NULL
  
  
  sqlQuery<-paste0("SELECT person_id as person,COUNT(*) as count FROM ",sqlSchema,".",omopTable," GROUP BY ",omopTable,".person_id")
  sqlResults<-dbGetQuery(con, sqlQuery)
  sqlResults$person<-as.character(sqlResults$person)
  sqlResults$count<-as.numeric(sqlResults$count)
  sqlResults<-sqlResults[order(sqlResults$person,decreasing = T),]
  row.names(sqlResults)<-NULL
  
  print(all.equal(sparqlResults,sqlResults))
}




compareRandomRecords<-function(preffix,con,omopTable,skip_source_value=F){
  tempQuery<-paste0("SELECT * FROM mimicredux.",omopTable," ORDER BY random() LIMIT 1;")
  

  # omopTable<-"visit_occurrence"
  # tempQuery<-"SELECT * FROM mimicredux.visit_occurrence WHERE visit_occurrence_id=7589633510896069998;"
  sqlResults<-dbGetQuery(con, tempQuery)
  
  sqlResults<-sqlResults[,!is.na(sqlResults[1,])]
  table_id<-paste0(omopTable,"_id")
  table_id_v<-as.character.integer64(unlist(sqlResults[table_id]))
  
  print(paste0("checking ",table_id_v," from ",omopTable))
  #list all drug_exposure
  Q_drug_exposure<-
    paste0("
  prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
  prefix xml: <http://www.w3.org/XML/1998/namespace> 
  prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
  prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  PREFIX omp: <http://omop2rdf/mimicIV.owl#>
  
  
  select * where { 
      ?person_id rdf:type omp:person.
      ?",omopTable,"_id omp:person_id ?person_id;
      	rdf:type/rdfs:subClassOf* omp:",omopTable,";
       FILTER (?",omopTable,"_id=<",preffix,table_id_v,">)")
  
  n=0
  for (i in colnames(sqlResults)){
    if ((i!="person_id")&&(i!=paste0(omopTable,"_id"))){
      n<-n+1
      if (n==1)
        Q_drug_exposure<-paste(Q_drug_exposure,paste0("      ?",omopTable,"_id omp:",i," ?",i,";"),sep="\n")
      else
        Q_drug_exposure<-paste(Q_drug_exposure,paste0("      omp:",i," ?",i,";"),sep="\n")
    }
    
  }
  Q_drug_exposure<-paste(Q_drug_exposure,"}",sep="\n")
  
  sparqlResults<-SPARQL(url = sparqlEndpoint, query = Q_drug_exposure, format = "csv")$result

  for (cln in colnames(sparqlResults)){
    #remove the preffix from the uris
    sparqlResults[cln]<-gsub(preffix,"",sparqlResults[cln])
    #remove the 'T' from the rdf date fields
    if (length(grep("date",cln))>0)
      sparqlResults[cln]<-gsub("T"," ",sparqlResults[cln])
  }
 

  
  
  
  #set all columns as character
  sqlResults<-sqlResults %>%
    mutate_all(as.character)
  
  
  #remove 00:00:00 from datetime to be consistent with R timestamp implementation
  sparqlResults<-fixDatetime_0(sparqlResults)
  
  
  #change the order so that table_id is 1st and person 2nd
  sqlResults<-sqlResults[,c(2,1,3:ncol(sqlResults))]
  
  
  #check skip_source_value flag
  #if TRUE skip fields related to source_value
  
  if ((skip_source_value)&&length(grep("source_value",colnames(sqlResults)))){
    
    sqlResults<-sqlResults[,-grep("source_value",colnames(sqlResults))]
    sparqlResults<-sparqlResults[,-grep("source_value",colnames(sparqlResults))]
  }
  
  testResult<-all.equal(sparqlResults,sqlResults)
  print(testResult)
  
  if (!is.logical(testResult)){
    #get column name
    clname<-substr(testResult,(unlist(gregexpr('“', testResult))+1),(unlist(gregexpr('”', testResult))-1))

    return(data.frame(table=omopTable,id=table_id_v,result=testResult,column=clname,
                      valueSQL=unlist(sqlResults[clname]),valueSPARQL=unlist(sparqlResults[clname])))
  }
  else
    return(data.frame(table=omopTable,id=table_id_v,result=testResult,column=NA,valueSQL=NA,valueSPARQL=NA))
  
}


#list all drug_exposure
Q_drug_exposure<-
  "
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xml: <http://www.w3.org/XML/1998/namespace> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX omp: <http://omop2rdf/mimicIV.owl#>


select * where { 
    ?person rdf:type omp:person.
    ?drug_exposure omp:person_id ?person;
    	rdf:type/rdfs:subClassOf* omp:drug_exposure;
	  	omp:drug_concept_id ?drug_concept_id;
    	omp:drug_exposure_end_date ?drug_exposure_end_date;
    	omp:drug_exposure_end_datetime ?drug_exposure_end_datetime;     
     	omp:drug_exposure_start_date ?drug_exposure_start_date;
    	omp:drug_exposure_start_datetime ?drug_exposure_start_datetime;
      omp:drug_source_concept_id ?drug_source_concept_id;     
    	omp:drug_source_value ?drug_source_value;
	  	omp:drug_type_concept_id ?drug_type_concept_id;
  		omp:visit_occurrence_id ?visit_occurrence_id;
    	omp:quantity ?quantity;
     	omp:route_concept_id ?route_concept_id;
      omp:route_source_value ?route_source_value;
      omp:dose_unit_source_value ?dose_unit_source_value;
      omp:drug_type_concept_id ?drug_type_concept_id;
} Limit 200
"


#list all conditions
Q_condition_occurrence<-"
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xml: <http://www.w3.org/XML/1998/namespace> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX omp: <http://omop2rdf/mimicIV.owl#>


select * where { 
    ?person rdf:type omp:person.
    ?condition_occurrence omp:person_id ?person;
    	rdf:type/rdfs:subClassOf* omp:condition_occurrence;
     	omp:condition_concept_id ?condition_concept_id;   
     	omp:condition_start_date ?condition_start_date;
    	omp:condition_start_datetime ?condition_start_datetime;
     	omp:condition_end_date ?condition_end_date;
    	omp:condition_end_datetime ?condition_end_datetime;  
        omp:condition_type_concept_id ?condition_type_concept_id; 
        omp:visit_occurrence_id ?visit_occurrence_id;     
        omp:condition_source_value ?condition_source_value; 
        omp:condition_source_concept_id ?condition_source_concept_id;   
} Limit 200
"


#list all conditions
Q_measurement<-"
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xml: <http://www.w3.org/XML/1998/namespace> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX omp: <http://omop2rdf/mimicIV.owl#>


select * where { 
    ?person rdf:type omp:person.
    ?measurement omp:person_id ?person;
    	rdf:type/rdfs:subClassOf* omp:measurement;
     	omp:measurement_concept_id ?measurement_concept_id;   
     	omp:measurement_date ?measurement_date;
    	omp:measurement_datetime ?measurement_datetime;
        omp:measurement_type_concept_id ?measurement_type_concept_id; 
        omp:value_as_number ?value_as_number;     
        omp:value_as_concept_id ?value_as_concept_id; 
        omp:unit_concept_id ?unit_concept_id;
        omp:visit_occurrence_id ?visit_occurrence_id;
        omp:measurement_source_value ?measurement_source_value;     
     	omp:measurement_source_concept_id ?measurement_source_concept_id;
     	omp:unit_source_value ?unit_source_value	
} Limit 200
"




#list all conditions
Q_visit_occurrence<-"
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xml: <http://www.w3.org/XML/1998/namespace> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX omp: <http://omop2rdf/mimicIV.owl#>


select * where { 
    ?person rdf:type omp:person.
    ?visit_occurrence omp:person_id ?person;
    	rdf:type/rdfs:subClassOf* omp:visit_occurrence;
        omp:visit_concept_id ?visit_concept_id;
        omp:visit_start_date ?visit_start_date;   
        omp:visit_start_datetime ?visit_start_datetime;     
        omp:visit_end_date ?visit_end_date;   
        omp:visit_end_datetime ?visit_end_datetime;
        omp:visit_type_concept_id ?visit_type_concept_id;
        omp:visit_source_value ?visit_source_value;
        omp:visit_source_concept_id ?visit_source_concept_id;
        omp:admitting_source_concept_id ?admitting_source_concept_id;       
        omp:admitting_source_value ?admitting_source_value;
        omp:discharge_to_concept_id ?discharge_to_concept_id;          
        omp:discharge_to_source_value ?discharge_to_source_value;       
        omp:preceding_visit_occurrence_id ?preceding_visit_occurrence_id;         
} Limit 200
"



Q_drg_exp_count<-"
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
prefix xml: <http://www.w3.org/XML/1998/namespace> 
prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX omp: <http://omop2rdf/mimicIV.owl#>

SELECT ?person (count(distinct ?drug_exposure) as ?count)
WHERE {
  ?person rdf:type omp:person.
  ?drug_exposure omp:person_id ?person;
    rdf:type/rdfs:subClassOf* omp:drug_exposure;
}
Group by ?person
"


# #create sparql count queries
# Q_cnd_occ_count<-gsub("drug_exposure","condition_occurrence",Q_drg_exp_count)
# Q_prc_occ_count<-gsub("drug_exposure","procedure_occurrence",Q_drg_exp_count)
# Q_obs_per_count<-gsub("drug_exposure","observation_period",Q_drg_exp_count)
# Q_dvc_exp_count<-gsub("drug_exposure","device_exposure",Q_drg_exp_count)
# Q_measure_count<-gsub("drug_exposure","measurement",Q_drg_exp_count)
# Q_observa_count<-gsub("drug_exposure","observation",Q_drg_exp_count)
# Q_death___count<-gsub("drug_exposure","death",Q_drg_exp_count)
# 
# 
# 
# 
# #------------------------------# 
# # execute the sparql count queries
# drg_exp_count<-SPARQL(url = sparqlEndpoint, query = Q_drg_exp_count, format = "csv")$result
# prc_occ_count<-SPARQL(url = sparqlEndpoint, query = Q_prc_occ_count, format = "csv")$result
# cnd_occ_count<-SPARQL(url = sparqlEndpoint, query = Q_cnd_occ_count, format = "csv")$result
# obs_per_count<-SPARQL(url = sparqlEndpoint, query = Q_obs_per_count, format = "csv")$result
# dvc_exp_count<-SPARQL(url = sparqlEndpoint, query = Q_dvc_exp_count, format = "csv")$result
# measure_count<-SPARQL(url = sparqlEndpoint, query = Q_measure_count, format = "csv")$result
# observa_count<-SPARQL(url = sparqlEndpoint, query = Q_observa_count, format = "csv")$result
# death___count<-SPARQL(url = sparqlEndpoint, query = Q_death___count, format = "csv")$result
# 
# # remove the namespace so that only the IDs remain
# drg_exp_count<-removePreffix(drg_exp_count)
# prc_occ_count<-removePreffix(prc_occ_count)
# cnd_occ_count<-removePreffix(cnd_occ_count)
# obs_per_count<-removePreffix(obs_per_count)
# measure_count<-removePreffix(measure_count)
# observa_count<-removePreffix(observa_count)
# death___count<-removePreffix(death___count)



# all_drug_exposure<-SPARQL(url = sparqlEndpoint, query = Q_drug_exposure, format = "csv")$result
# all_condition_occurrence<-SPARQL(url = sparqlEndpoint, query = Q_condition_occurrence, format = "csv")$result
# all_measurement<-SPARQL(url = sparqlEndpoint, query = Q_measurement, format = "csv")$result
# 
# 
# all_drug_exposure<-removePreffix(all_drug_exposure)
# all_condition_occurrence<-removePreffix(all_condition_occurrence)
# all_measurement<-removePreffix(all_measurement)







# tableName<-"drug_exposure"
# 
# 
# a<-dbGetQuery(con,paste0("SELECT * FROM mimicredux.",tableName," LIMIT 100"))
# 
# 
# ll<-c()
# for (coln in colnames(a))
#   ll<-c(ll,paste0("OPTIONAL {?",tableName," omp:",coln," ?",coln,"}"))

fixDatetime_0<-function(x){
  for (cn in colnames(x)){
    if (grepl("datetime",cn)){
      x[cn]<-gsub(" 00:00:00","",x[cn])
      
    }
  }
  return(x)
}






