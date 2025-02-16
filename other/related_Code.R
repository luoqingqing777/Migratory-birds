
###############################metaphlan
rm(list=ls())
library(ComplexHeatmap)
library(openxlsx)
#read metaphlan_picture table 
cols<-c('#6BB8Fa','#EC889a','#FBC52a','#95ECD7')
pal<-colorRampPalette(cols)

metaphlan_picture$Sort3=gsub("control","Environment control",metaphlan_picture$Sort3)
metaphlan_picture$Sort3=gsub("other_birds","Other birds",metaphlan_picture$Sort3)
metaphlan_picture$Sort3=gsub("BHG","Black-headed gull",metaphlan_picture$Sort3)
metaphlan_picture$bacterium=gsub("UNCLASSIFIED","Unclassified",metaphlan_picture$bacterium)
#metaphlan_picture$bacterium=gsub("GGB32247_SGB82226","Others",metaphlan_picture$bacterium)
metaphlan_picture$bacterium=gsub("Candidatus_Arthromitus_sp_SFB_turkey","Candidatus_Arthromitus",metaphlan_picture$bacterium)
colnames(metaphlan_picture)[3] <- "Relative_abundance"

metaphlan_picture$Sample<-factor(metaphlan_picture$Sample,levels=unique(metaphlan_picture[metaphlan_picture$bacterium=="Catellicoccus_marimammalium",]$Sample[order(-metaphlan_picture[metaphlan_picture$bacterium == "Catellicoccus_marimammalium", ]$Relative_abundance)]),ordered = T)

ggplot(metaphlan_picture,aes(Sample,Relative_abundance,fill=bacterium))+
  geom_bar(position="stack",stat="identity")+
  theme_bw()+
  theme(axis.ticks.length.y.left =unit(0.5,'cm'),axis.ticks.x=element_blank())+
  theme(axis.title.x=element_text(vjust=1,size=15),axis.title.y=element_text(vjust=1,size=15),
        axis.text.x=element_text(size=0,angle = 90,vjust=0,hjust = 1),
        axis.text.y=element_text(size=15,vjust=0,hjust = 1),
        legend.text =element_text(size=10),panel.background = NULL,
        strip.text.x = element_text(size = 12),
        strip.background = element_rect(fill="#e9ecef"))+
  facet_wrap(~Sort3,nrow =1,scales = "free_x")+
  guides(fill=guide_legend(title=NULL))+
  ggforce::facet_row(vars(Sort3), scales = 'free', space = 'free')+
  scale_fill_manual(values = pal(9))+labs(title="Relative Abundance")+theme(plot.title=element_text(size=20,hjust=0.5))#标题大小

##svg 1800*700
##PDF 10*15


###############################VFDB
#read VF table
rm(list=ls())
number_count<-aggregate(VF$VFcategory,list(VF$VFcategory),length)
number_count<-number_count[order(number_count$x,decreasing = T),]
library(RColorBrewer)
colors <- brewer.pal(12, "Set3")
pie(number_count$x, labels = c("Immune modulation", "Nutritional/Metabolic factor", "Adherence", "Effector delivery system", "Regulation", "Stress survival", "Exotoxin", "Motility", "Biofilm", "Others", "Antimicrobial activity/Competitive advantage", "Invasion", "Post-translational modification"), col = colors)

#read Virulence_mapping
rownames(Virulence)<-Virulence[, 1]
Virulence<-Virulence[, -1, drop = FALSE]
n0 <- apply(Virulence == 0, 1, sum)

Virulence1<-log(Virulence+1)
color <- colorRampPalette(c("#52B8CE", "#FFFFFF", "#F6D774"))
mycolor<-color(100)

pheatmap::pheatmap(Virulence1,cluster_rows = T,cluster_cols = T,col=mycolor,treeheight_row=0,treeheight_col=0)
#3*9


####################Ariba
#read card table
gene_info<-aggregate(Exist~Matchgene,data=card,FUN="sum")

card_bird<-merge(sort_bird,card,by.x="Samples",by.y="name",all.x = T)
card_bird$Sort3<-NULL
card_bird_info<-aggregate(Exist~Matchgene,data=card_bird,FUN="sum")
card_bird_info$Exist<-card_bird_info$Exist/44*100

card_env<-merge(sort_env,card,by.x="Samples",by.y="name",all.x = T)
card_env$Sort3<-NULL
card_env_info<-aggregate(Exist~Matchgene,data=card_env,FUN="sum")
card_env_info$Exist<-card_env_info$Exist/19*100

merge_gene<-merge(card_bird_info,card_env_info,by.x="Matchgene",by.y="Matchgene",all = T)
names(merge_gene)<-c("Matchgene","Bird_exist","Env_exist")
merge_gene<-arrange(merge_gene,Bird_exist)%>% mutate(Matchgene=factor(Matchgene, levels=Matchgene))

merge_bird<-merge_gene[,c(1,2)]
merge_env<-merge_gene[,c(1,3)]
######
merge_env <- merge_env[order(merge_env$Env_exist, decreasing = T), ]
merge_env <- merge_env[c(1:7),]
merge_bird1 <- merge_bird[order(merge_bird$Bird_exist, decreasing = T), ]
merge_bird1 <- merge_bird1[c(1:10),]
merge_bird2<-merge_bird[which(merge_bird$Matchgene%in%merge_env$Matchgene),]
merge_bird<-rbind(merge_bird1,merge_bird2)

merge_b_env<-merge(merge_bird,merge_env,by.x="Matchgene",by.y="Matchgene",all=T)
merge_b_env[is.na(merge_b_env)] <-  0
merge_b_env<-reshape2::melt(merge_b_env, id.vars = "Matchgene", measure.vars =c(2,3),variable.name = 'Sample',value.name = 'abundance')#进行宽变长的操作

merge_b_env <- merge_b_env[order(merge_b_env$Sample, decreasing = F), ]
merge_b_env$Sample<-factor(merge_b_env$Sample,ordered = T,levels=c( "Env_exist","Bird_exist"))

ggplot(data=merge_b_env,aes(x=Matchgene,y=abundance,fill=Sample))+
  geom_bar(stat="identity", color="#e9ecef",alpha=0.9,position=position_dodge2(preserve = 'single'))+##
  ggtitle("") +theme_classic()+coord_flip()


