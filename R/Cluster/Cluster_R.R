install.packages("cluster", repos = "https://cran.r-project.org")
install.packages("clustertend", repos = "https://cran.r-project.org")


getwd()

# setwd("C:/Noble/Evolve/Training/R Studio")

data <- read.csv("dow_jones_data.csv")
head(data)

colnames(data)

if (TRUE){
  df <- scale(data[-1]) # Standardize the data
} else{
  df <- data[-1] 
}

head(df)

k.means.fit <- kmeans(df, 3) # Perform k-means clustering with 3 clusters
attributes(k.means.fit) # Check the attributes that k-means generates

k.means.fit$centers # The locations of the centroids

k.means.fit$cluster # The cluster to which each observation belongs
k.means.fit$size # Check the size of each cluster

withinssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}
withinssplot(df, nc=10)

k.means.fit <- kmeans(df, 3)


# To create the clusters in 2-dimensional space:
library(cluster)
clusplot(df, k.means.fit$cluster, main='2D representation of the Cluster solution', color=TRUE, shade=TRUE, labels=2, lines=0)
data$kmeans <- k.means.fit$cluster


#Hierarchial

d <- dist(df, method = "euclidean") # Euclidean distance matrix.
H.single <- hclust(d, method="single")
plot(H.single) # display dendogram

H.complete <- hclust(d, method="complete")
plot(H.complete)

H.average <- hclust(d, method="average")
plot(H.average)

H.ward <- hclust(d, method="ward.D2")
plot(H.ward)

par(mfrow=c(2,2))
plot(H.single)
plot(H.complete)
plot(H.average)
plot(H.ward)


par(mfrow=c(1,1))

groups <- cutree(H.ward, k=3) # cut tree into 3 clusters

plot(H.ward)
rect.hclust(H.ward, k=3, border="red") 

clusplot(df, groups, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)


data$hclust <- groups