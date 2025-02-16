
#######################################################
rm(list=ls())
###
library(tidyr)
library(pheatmap)
library(igraph)
#
instrain_info_all <-read.delim("/instrain_info_popANI.txt", header=T)
# 
sample139_path <- "/instrain_plot_sample.txt"
if (!file.exists(sample139_path)) {
  stop(paste("File", sample139_path, "does not exist."))
}
sample139 <- read.delim(sample139_path, header = F)

bird_path <- "/metadata_all_year.csv"
if (!file.exists(bird_path)) {
  stop(paste("File", bird_path, "does not exist."))
}
bird <- read.csv(bird_path, header = T)

annotation <- merge(bird, sample139, by.x = "Samples", by.y = "V1", all.y = T)
annotation <- annotation[, c(1, 3, 16)]
rownames(annotation) <- annotation[, 1]
annotation <- annotation[, -1]
annotation$Year <- as.character(annotation$Year)


# 
dist_matrix <- as.dist(1 - instrain_info_all)

# 
hc <- hclust(dist_matrix, method = "ward.D2")

# 
threshold <- 1 - 0.999
cutree_result <- cutree(hc, h = threshold)

# 
adj_matrix <- ifelse(instrain_info_all > 0.999, 1, 0)
diag(adj_matrix) <- 0  

# 
keep_nodes <- which(rowSums(adj_matrix) >= 2)
adj_matrix <- adj_matrix[keep_nodes, keep_nodes]

# 
g <- graph.adjacency(adj_matrix, mode = "undirected")

# 
cluster_sizes <- table(cutree_result[keep_nodes])
valid_clusters <- names(cluster_sizes)[cluster_sizes >= 2]
valid_indices <- which(cutree_result[keep_nodes] %in% valid_clusters)
keep_nodes <- keep_nodes[valid_indices]
adj_matrix <- adj_matrix[valid_indices, valid_indices]
g <- graph.adjacency(adj_matrix, mode = "undirected")

# 
cutree_result_filtered <- cutree_result[keep_nodes]
V(g)$color <- rainbow(length(unique(cutree_result_filtered)))[cutree_result_filtered]

# 
layout <- layout_with_fr(g)

# 
plot(g, vertex.label = NA, vertex.size = 15, layout = layout, main = "Network Graph of Samples with popANI > 0.999")
