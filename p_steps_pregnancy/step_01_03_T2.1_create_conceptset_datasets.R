
# APPLY THE FUNCTION CreateConceptSetDatasets TO CREATE ONE DATASET PER CONCEPT SET CONTAINING ONLY RECORDS WITH A CODE OF INTEREST

# input: EVENTS, MEDICINES, SURVEY_OBSERVATIONS, MEDICAL_OBSERVATIONS
# output: concept set datasets, one per concept set, named after the concept set itself


print('RETRIEVE FROM CDM RECORDS CORRESPONDING TO CONCEPT SETS')


CreateConceptSetDatasets(concept_set_names = c(concept_set_pregnancy),
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar= ConcePTION_CDM_datevar,
                         EAVtables=ConcePTION_CDM_EAV_tables,
                         EAVattributes= ConcePTION_CDM_EAV_attributes_this_datasource,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id=person_id,date=date),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_pregnancy,
                         concept_set_codes_excl = concept_set_codes_pregnancy_excl,
                         discard_from_environment = F,
                         dirinput = dirinput,
                         diroutput = dirtemp,
                         extension = c("csv")#,
                         #vocabularies_with_dot_wildcard=c("READ")
                         )


### Creating visit occurrence id if missing
for (concept in concept_set_pregnancy) {
  if( nrow(get(concept)) > 0){
    assign("concept_temp", get(concept))
    
    if(concept_set_domains[[concept]]=="Diagnosis"){
      concept_temp <- concept_temp[is.na(visit_occurrence_id), visit_occurrence_id := paste0(origin_of_event, "_", concept, "_dummy_visit_occ_id_", seq_along(.I))]
    }
    
    if(concept_set_domains[[concept]]=="Medicines"){
      concept_temp <- concept_temp[is.na(visit_occurrence_id), visit_occurrence_id := paste0(origin_of_drug_record, "_", concept,"_dummy_visit_occ_id_", seq_along(.I))]
    }
    
    if(concept_set_domains[[concept]]=="Procedures"){
      concept_temp <- concept_temp[is.na(visit_occurrence_id), visit_occurrence_id := paste0(origin_of_procedure, "_", concept, "_dummy_visit_occ_id_", seq_along(.I))]
    }
    assign(concept, concept_temp)
    save(list=concept, file=paste0(dirtemp, concept,".RData"))
  }
}


## Selected meaning if necessary
if (this_datasources_with_specific_algorithms){
  
  for (concept in concept_set_pregnancy) {
    if( nrow(get(concept)) > 0 & concept_set_domains[[concept]]=="Diagnosis"){
      
      assign("concept_temp", get(concept))
      concept_temp <- concept_temp[eval(parse(text = select)),]
      assign(concept, concept_temp)
      save(list=concept, file=paste0(dirtemp, concept,".RData"))
    }
  } 
}
################################################################################
###########################       Description        ###########################
################################################################################
if(HTML_files_creation){
  for (concept in concept_set_pregnancy) {
    
    if( nrow(get(concept)) > 0){
      
      if(concept_set_domains[[concept]]=="Diagnosis"){
        cat(paste0("Describing ", concept,  " \n"))
        DescribeThisDataset(Dataset = get(concept),
                            Individual=T,
                            ColumnN=NULL,
                            HeadOfDataset=FALSE,
                            StructureOfDataset=FALSE,
                            NameOutputFile=concept,
                            Cols=list("codvar", "event_record_vocabulary", "meaning_of_event", "origin_of_event"),
                            ColsFormat=list("categorical", "categorical", "categorical", "categorical"),
                            DateFormat_ymd=FALSE,
                            DetailInformation=TRUE,
                            PathOutputFolder= dirdescribe01_concepts)
      }
      
      if(concept_set_domains[[concept]]=="Medicines"){
        cat(paste0("Describing ", concept,  " \n"))
        DescribeThisDataset(Dataset = get(concept),
                            Individual=T,
                            ColumnN=NULL,
                            HeadOfDataset=FALSE,
                            StructureOfDataset=FALSE,
                            NameOutputFile=concept,
                            Cols=list("codvar", "meaning_of_drug_record", "origin_of_drug_record"),
                            ColsFormat=list("categorical", "categorical", "categorical"),
                            DateFormat_ymd=FALSE,
                            DetailInformation=TRUE,
                            PathOutputFolder= dirdescribe01_concepts)
      }
      
      if(concept_set_domains[[concept]]=="Procedures"){    
        cat(paste0("Describing ", concept,  " \n"))
        DescribeThisDataset(Dataset = get(concept),
                            Individual=T,
                            ColumnN=NULL,
                            HeadOfDataset=FALSE,
                            StructureOfDataset=FALSE,
                            NameOutputFile=concept,
                            Cols=list("codvar", "meaning_of_procedure", "origin_of_procedure", "procedure_code_vocabulary"),
                            ColsFormat=list("categorical", "categorical", "categorical", "categorical"),
                            DateFormat_ymd=FALSE,
                            DetailInformation=TRUE,
                            PathOutputFolder= dirdescribe01_concepts)
      }
    }
  }
}




rm(list = concept_set_pregnancy)
