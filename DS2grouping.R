###
rm(list=ls())
### Wu, Yi-Hung @ ICE.CYCU 2024/3
### =======================================================
# Input CSV file: M*N data frame
# M rows where M > G1.no
# N columns
G1.no = 17  # <== the amount of non-class students A:13, B:17
df <- read.csv(choose.files())
# View(df)
G1 <- df[1:G1.no,]
classS <- df[(G1.no+1):dim(df)[1],]
# View(class)

### pairing of G1
pair.no <- ceiling(G1.no / 2)
pairID <- as.vector(t(matrix(rep(1:pair.no,2),pair.no,2)))
newG1 <- cbind(G1,ID=pairID[sample(G1.no)])
# print(newG1)
print(c(G1.no,pair.no))
# View(newG1)
### Deciding the number of clusters for class students

## 1. Silhouette method
if(!require(cluster)) {
  install.pagkages("cluster")
  library(cluster)
}
# 使用k-means進行分群，並計算不同k值下的輪廓係數
best_sil_width <- -Inf
best_k <- 0

for(k in 2:10) {
  km_res <- kmeans(classS, centers=k)
  ss <- silhouette(km_res$cluster, dist(classS))
  sil_width <- mean(ss[, 3])
  if(sil_width > best_sil_width) {
    best_sil_width <- sil_width
    best_k <- k
  }
#  cat("For k=", k, ", silhouette width is ", sil_width, "\n", sep="")
}
# cat("Best k is ", best_k, " with a silhouette width of ", best_sil_width, "\n")

## 2. Elbow method
if(!require(factoextra)){
  install.packages("factoextra")
  library(factoextra)
}
# set.seed(123) # 確保結果可重現

# 使用k-means進行分群，並繪製肘部圖
fviz_nbclust(classS, kmeans, method = "wss") + 
  geom_vline(xintercept = 4, linetype = 2) +
  labs(subtitle = "肘部法則圖")

## 3. Gap Statistic method
if(!require(cluster)) {
  install.pagkages("cluster")
  library(cluster)
}
set.seed(Sys.time())

# 計算Gap Statistic
gap_stat <- clusGap(classS, FUN = kmeans, nstart = 25, K.max = 10, B = 50)

# 找出最佳的分群數量
best_k2 <- maxSE(gap_stat$Tab[, "gap"], gap_stat$Tab[, "SE.sim"], method = "Tibs2001SEmax")

# 可以使用以下代碼來繪製Gap Statistic的結果圖
# plot(gap_stat, main = "Gap Statistic for K-means Clustering")

group.no <- max(best_k, best_k2) # <== the number clusters
print(c(best_k,best_k2))
#=========================

### clustering of class
if (!require(maotai)) {
  install.packages("maotai")
  library(maotai)
}
groupID <- kmeanspp(as.matrix(classS),group.no)
listID <- rep(0,dim(classS)[1])
for(ID in (1:group.no)) {
  # ID = group.no
  idx <- which(groupID==ID)
  if ((length(idx) %% 2) == 1) {
    groupID[ idx[length(idx)/2] ] <- ID + 1
    idx <- idx[-(length(idx)/2)]
  }
  newP.no <- ceiling(length(idx) / 2)
  print(c(length(idx),newP.no))
  pairID <- pair.no + as.vector(t(matrix(rep(1:newP.no,2),newP.no,2)))
  listID[idx] <- pairID[sample(length(idx))]
  pair.no <- pair.no + newP.no
}
newClass <- cbind(classS,ID=listID)
# print(newClass)
# View(newClass)
result <- rbind(newG1,newClass)
result$ID <- ceiling(dim(df)[1]/2) - result$ID + 1
# reverse the numbering
result <- result[,c(1,ncol(result))]
# View(result)
write.csv(result,"output.csv", row.names=FALSE)
#
# shell.exec("output.csv")
### ===============================
### ===============================