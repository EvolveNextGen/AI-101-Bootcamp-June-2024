install.packages("data.table", repos = "https://cran.r-project.org")

library(data.table)

data = fread("tweets_about_sprint.csv", 
             strip.white=T, sep=",", header=T, na.strings=c(""," ", "NA","nan", "NaN", "nannan"))
data$tweet_id <- seq.int(nrow(data))
head(data, n=5)

#Before working on our actual Twitter data, let’s install and load “tidytext” and “dplyr” and perform a simple task with them:

install.packages("tidytext", repos = "https://cran.r-project.org")
install.packages("dplyr", repos = "https://cran.r-project.org")

library(dplyr)

library(tidytext)

# This means that in data frame data, tokenize column "tweet" by each word (standard tokenization).
#The function unnest_tokens above splits each row such that there is one token (word) in each row of the new data frame;
#Also notice:Other columns, such as the line number each word came from, are retained.Punctuation has been stripped.
#By default, unnest_tokens() converts the tokens to lowercase, which makes them easier to compare or combine with other datasets. (Use the to_lower = FALSE argument to avoid automatic lowercasing).


tidy_text <- data %>%
  unnest_tokens(word, tweet)
tidy_text[1:20]

#Now we can remove stop-words from our data. We can do this using anti_join function:

data(stop_words)
tidy_text <- tidy_text %>%
  anti_join(stop_words)

#We can also use dplyr’s count() to find the most common words in all the books as a whole.

tidy_text %>%
  count(word, sort = TRUE) 


#Because we’ve been using tidy tools, our word counts are stored in a tidy data frame. This allows us to pipe this directly to the ggplot2 package, for example to create a visualization of the most common words:

library(ggplot2)

tidy_text %>%
  count(word, sort = TRUE) %>%
  filter(n > 1000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  xlab(NULL) +
  coord_flip()

install.packages("textdata")

get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")

nrcjoy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")

tidy_text %>%
  inner_join(nrcjoy) %>%
  count(word, sort = TRUE)


sentiment <- tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE)

head(sentiment)

#To obtain the sentiment scores for each tweet for the entire data, we can use another package called “syuzhet”. In this package, we still have nrc, AFINN, and bing. But also we have another lexicon called “syuzhet” which is a custom sentiment dictionary developed in the Nebraska Literary Lab. Also, since there are 50k tweets, we can use package “parallel” to perform the sentiment analysis faster. We will talk about parallel in detail during the coming weeks. Here is the example:

install.packages("parallel", repos = "https://cran.r-project.org")

install.packages("syuzhet")
library("syuzhet")

library("parallel")
tweets = head(data, n= 1000)
(no_cores <- detectCores() - 1) # Calculate the number of cores in your machine

cl <- makeCluster(no_cores) # Initiate the cluster
clusterEvalQ(cl, library("syuzhet")) # Load library "syuzhet" on the cluster

clusterEvalQ(cl, library("plyr")) # Load library "plyr" on the cluster

tweets$syuzhet = parLapply(cl, tweets$tweet, function(x) get_sentiment(toString(x), method="syuzhet")) # Use syuzhet lexicon for sentiment analysis
tweets$syuzhet <- as.numeric(unlist(tweets$syuzhet)) # Convert the sentiment scores to numeric
tweets$bing = parLapply(cl, tweets$tweet, function(x) get_sentiment(toString(x), method="bing")) # Use bing lexicon for sentiment analysis
tweets$bing <- as.numeric(unlist(tweets$bing))
tweets$nrc = parLapply(cl, tweets$tweet, function(x) get_sentiment(toString(x), method="nrc"))
tweets$nrc <- as.numeric(unlist(tweets$nrc))
tweets$afinn = parLapply(cl, tweets$tweet, function(x) get_sentiment(toString(x), method="afinn"))
tweets$afinn <- as.numeric(unlist(tweets$afinn))
tweets$mean_sentiment <- rowMeans(subset(tweets, select = c(syuzhet, bing, nrc, afinn)), na.rm = TRUE) # Take the average of all four methods as the final sentiment score
tweets <- tweets[order(tweets$mean_sentiment),] # Order teh data based on lowest average sentiment to the highest
tweets$x <- rescale_x_2(tweets$mean_sentiment)$x # Re-scale the sentiment scores to range from 0 to 1. 
stopCluster(cl) # Shutdown the cluster
head(tweets)

install.packages("wordcloud")
library(wordcloud)

tidy_text %>%
  anti_join(stop_words) %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))

install.packages("reshape2", repos = "https://cran.r-project.org")

library(reshape2)

tidy_text %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 100)
