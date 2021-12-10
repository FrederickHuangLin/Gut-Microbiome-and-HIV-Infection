library(tidyverse) 
library(readr)

#=========================================================================================================
# Meta data
#=========================================================================================================
df_meta = read_tsv("data/meta_data.tsv")
rownames(df_meta) = df_meta$sampleid

#=========================================================================================================
# Cytokine data
#=========================================================================================================
df_cytokine = read_csv("data/cytokine_data.csv")
df_cytokine = df_cytokine %>% 
  dplyr::select(sampleid, il6, cd163, ip10, crp, lbp, cd14)

#=========================================================================================================
# SCFA data
#=========================================================================================================
df_scfa = read_csv("data/scfa_data.csv")
df_scfa = df_scfa %>% 
  dplyr::select(sampleid, acetate, propionate, butyrate, valerate)

#=========================================================================================================
# CD4/CD8/viral load data
#=========================================================================================================
df_cd48_vload = read_csv("data/cd48_vload_data.csv")
df_cd48_vload = df_cd48_vload %>%
  dplyr::select(sampleid, leu2n, leu2p, leu3n, leu3p, leu4n, leu4p, vload)

#=========================================================================================================
# Merged data
#=========================================================================================================
df_merge = df_meta %>% 
  left_join(df_cytokine, by = c("sampleid")) %>%
  left_join(df_scfa, by = c("sampleid")) %>%
  left_join(df_cd48_vload, by = c("sampleid"))

#=========================================================================================================
# Data cleaning
#=========================================================================================================
# For both NCs and SCs, treat viral load of 40 or 300 as NA
# For SCs at visit 1, switch visit 1 to visit 2 if the viral loads are not either 40 or 300
df_merge$vload[which(df_merge$status == "nc" & df_merge$vload %in% c(40, 300))] = NA
df_merge$vload[which(df_merge$status == "sc" & df_merge$vload %in% c(40, 300))] = NA
vload_err = df_merge %>% 
  filter(status == "sc", visit == "v1", !is.na(vload))
df_exclude = df_merge %>% 
  filter(subjid %in% vload_err$subjid, visit == "v2")
df_merge = df_merge %>% 
  anti_join(df_exclude)
df_merge[which(df_merge$subjid %in% c(vload_err$subjid)), "visit"] = "v2"

write_csv(df_merge, "data/df_merge.csv")







