install.packages("RIA")

library(RIA)

folder <- "E:/Spring_2022/REP/Slice_Data/Test" #Location of folder containing individual folders per patient which contain nifti files for the image and mask
out <- "E:/Spring_2022/REP/Slice_Data/Test/csv" #Location of folder where the results will be dumped

patients <- list.dirs(folder, recursive = FALSE, full.names = FALSE) #Name of patient folders
patients_full <- list.dirs(folder, recursive = FALSE, full.names = TRUE) #Name of patient folders with full file path name


library(foreach); library(doParallel) #Load required packages
doParallel::registerDoParallel(4)

data_out_paral <- foreach (i = 1:length(patients), .combine="rbind", .inorder=FALSE,
                           .packages=c('RIA'), .errorhandling = c("pass"), .verbose=FALSE) %dopar% {
                             
                             files <- list.files(patients_full[i]) #Names of the files in the current patient folder
                             image <- grep("_t1ce", files, ignore.case = T, value = T) #Full name of the image file
                             masks <- grep("_seg", files, ignore.case = T, value = T) #Full name of the mask files
                             
                             #RUN RIA
                             IMAGE <- RIA::load_dicom(filename = paste0(patients_full[i], "/", image),
                                                     mask_filename = paste0(patients_full[i], "/", masks), switch_z = FALSE) #Load image and mask files
                             IMAGE <- RIA::radiomics_all(IMAGE,  equal_prob = "both", bins_in= c(4, 8, 16)) #Calculate radiomic features
                             RIA::save_RIA(IMAGE, save_to = out, save_name = patients[i], group_name = patients[i]) #Export results into csv
                           }