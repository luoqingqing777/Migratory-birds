##Heatmap
##########################################################conANI##############################
rm(list=ls())
 instrain_info_all <-read.delim("/instrain_info_conANI.txt", header=T)

##
sample139 <-read.delim("/instrain_plot_sample.txt", header=F)
bird<-read.csv("/metadata_all_year.csv",header = T)
annotation<-merge(bird,sample139,by.x="Samples",by.y = "V1",all.y=T)
annotation<-annotation[,c(1,3,16)]
rownames(annotation)<-annotation[,1]
annotation<-annotation[,-1]
annotation$Year<-as.character(annotation$Year)

color<-colorRampPalette(c("#BEEDFF","#E7D3FE","#BD514A"))
mycolor<-color(100)

annotation_colors <- list(
  annotation_row = list(
    selected_annotation_column_name = c("LS" = "#589CD6", "QH" = "#6FAE45", "HY" = "#FFC101", "DYJH" = "#EF7E33", "2020" = "#C7E2E4", "2021" = "#A0AFB7", "2022" = "#F2B9AC", "2023" = "#FCD8BB")
  )
)

pheatmap(
  instrain_info_all, 
  cluster_rows = TRUE, 
  cluster_cols = TRUE, 
  main = "Clustered Heatmap",
  color = mycolor,
 
  annotation_row = annotation,
  annotation_colors = annotation_colors,
  show_colnames = FALSE   # Hide column names
)

