##randomForest_analysis
rm(list=ls())
library(randomForest)
library(tidyr)
##read random_forest_genus table 
randomForest_rf<-randomForest(abundance~ .,data=all_correlation,
                              ntree = 200,
                              mtry = round(log(ncol(all_correlation))),
                              proximity = TRUE,
                              importance = TRUE)
imp = data.frame(importance(randomForest_rf))
imp$id=rownames(imp)
library(ggplot2)
library(qqman)
###做新图
test<-all_correlation
test$abundance = factor(test$abundance)
set.seed(430)
Groups.rf = randomForest(abundance ~ ., data=test, ntree=500, importance=TRUE, proximity=TRUE)
data <- round(importance(Groups.rf), 2)
varImpPlot(Groups.rf)



####correlation
rm(list=ls())
##read correlation table 
library(randomForest)
library(tidyr)
randomForest_rf<-randomForest(abundance~ .,data=all_correlation,
                              ntree = 100,
                              mtry = round(log(ncol(all_correlation))),
                              proximity = TRUE,
                              importance = TRUE)
imp = data.frame(importance(randomForest_rf))
imp$id=rownames(imp)

test<-all_correlation
test$abundance = factor(test$abundance)
set.seed(430)
Groups.rf = randomForest(abundance ~ ., data=test, ntree=500, importance=TRUE, proximity=TRUE)
data <- round(importance(Groups.rf), 2)
par(mar=c(5, 5, 2, 2))
pdf("varImpPlot.pdf", width = 8, height = 6)  # Adjust dimensions as needed
varImpPlot(Groups.rf)
dev.off()

#

 line<-all_correlation[,c(1,42)]
plot(line$abundance,line$Picornaviridae)
line$Picornaviridae<-as.numeric(line$Picornaviridae)
cor(line$abundance,line$Picornaviridae,method = "spearman")
cor.test(line$abundance,line$Picornaviridaemethod = "spearman")

linear_fit <- lm(Picornaviridae ~abundance, data = line)
linear_fit
summary(linear_fit)



ggplot(line, aes(x = abundance, y = Picornaviridae)) + 
  geom_point(size=2) +  # Scatter plot
  geom_smooth(method = "lm", se = FALSE, color = "red", formula = y ~ x, 
              linetype = "dashed", lwd = 1) +
  theme_bw() +
  geom_density_2d() +  # Density plot
  labs(title = "Correlation", x = "Catellicoccus Abundance", y = "Hepatovirus-like virus abundance")+geom_density_2d_filled(alpha = 0.4)







