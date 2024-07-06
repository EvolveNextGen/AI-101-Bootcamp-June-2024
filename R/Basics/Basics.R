a = table(iris)
head(a)

dim(iris)

names(iris)

str(iris)

attributes(iris)
iris[1:5,]
head(iris)
tail(iris)

summary(iris)
quantile(iris$Sepal.Length)


hist(iris$Sepal.Length)

pie(table(iris$Species))

cor(iris[,1:4])

boxplot(Sepal.Length ~ Species, data=iris, xlab="Species", ylab="Sepal.Length")

library(ggplot2)
qplot(Sepal.Length, Sepal.Width, data=iris, facets=Species ~.)