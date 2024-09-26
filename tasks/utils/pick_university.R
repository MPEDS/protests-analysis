pick_university <- function(uni){
  if(any(uni$uni_name_source == "publication")){
    return(uni$university_name[uni$uni_name_source == "publication"][1])
  } else if(any(uni$uni_name_source == "other univ where protest occurs")){
    return(uni$university_name[uni$uni_name_source == "other univ where protest occurs"][1])
  } else {
    return(uni$university_name[1])
  }
}
