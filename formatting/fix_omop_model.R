

#Open the r2rml file with protege and "save as" TURTLE format file named output_protege.ttl

orTTL<-readLines('output_protege.ttl')



# this is your local path of for the r2rml installation, change it accordingly since it is used to create URIs
localPath<-"file:///home/user/r2rml/example"

# add your desired namespace
namespace<-"http://omop2rdf/mimicIV.owl"




namespace_sh<-paste0(namespace,"#")
namespace_sl<-paste0(namespace,"/")


orTTL<-gsub(localPath,"http://localhost:2020",orTTL)





classes<-c("care_site","cdm_source","concept","concept_relationship","condition_era","condition_occurrence","death",
           "device_exposure","dose_era","drug_era","drug_exposure","fact_relationship","location","measurement","observation",
           "observation_period","person","procedure_occurrence","specimen","visit_detail","visit_occurrence","vocabulary")


classes<-paste0("http://localhost:2020/",classes)


for (cl in classes){
  orTTL<-gsub(paste0(cl,"/"),"http://localhost:2020/",orTTL)
  orTTL<-gsub(paste0(cl,"#"),"http://localhost:2020/",orTTL)
}



#change the ontology namespace to that of http://omop2rdf/mimicIV.owl, you can use http://omop2rdf/yourDataSource.owl 
orTTL<-gsub("http://localhost:2020/",namespace_sh,orTTL)




#---------------------------------------------------------------------------#



stopIndex<-which(grepl('#    Datatypes',orTTL))


ids<-which(grepl('_id',orTTL[1:stopIndex]))


for (i in ids){
  orTTL[(i+1)]<-gsub("AnnotationProperty","ObjectProperty",orTTL[(i+1)])
}




classes<-c("care_site","cdm_source","concept","concept_relationship","condition_era","condition_occurrence","death",
           "device_exposure","dose_era","drug_era","drug_exposure","fact_relationship","location","measurement","observation",
           "observation_period","person","procedure_occurrence","specimen","visit_detail","visit_occurrence","vocabulary")



orTTL<-gsub(paste0("<",namespace_sh,"preceding_visit_occurrence> rdf:type owl:AnnotationProperty ."),
            paste0("<",namespace_sh,"preceding_visit_occurrence> rdf:type owl:ObjectProperty ."),orTTL)


#-------------------------harmonize the uris-----------------------#
startIndex<-which(grepl('#    Classes',orTTL))
stopIndex<-which(grepl('#    Individuals',orTTL))





for (i in startIndex:stopIndex){
  for (cl in classes)
    orTTL[i]<-gsub(paste0(namespace_sl,cl),paste0(namespace_sh,cl),orTTL[i])
}


for (cl in classes){
  orTTL<-gsub(paste0(namespace_sl,cl,"#"),namespace_sh,orTTL)
  
}

#-------------------------end harmonize the uris-----------------------#





writeLines(orTTL,'output_updated.ttl')

#save the file and use protege to open it and "save as" TURTLE format file with the same name













