library(dplyr)
library(ggplot2)
library(tm)
library(SnowballC)
library(caret)


reviews <- read.csv("C:\\Users\\adity\\Documents\\MachineLearning\\reviews.csv", header=TRUE, sep=",",
                    stringsAsFactors = FALSE, encoding = "Latin1")

## See the distribution
reviews %>% ggplot(aes(Score)) + geom_histogram(binwidth = .5, col='black')

revSummary <- reviews %>% select(Summary, Score)
# Group 1 & 2 to Unhappy, 4 & 5 to Happy, 3 to Neutral
revSummary <- revSummary %>% mutate('Score' = ifelse(revSummary$Score==1 | revSummary$Score ==2, "Unhappy", 
                                     ifelse(revSummary$Score== 4 | revSummary$Score == 4, "Happy", 
                                            "Neutral")))



# Let's drop Neutral and check that we get two classes and their distribution
revSummary <- revSummary %>% filter(Score != 'Neutral')

## Stratified sampling (for memory usage management)
## revSummary <- sample_frac(revSummary, 0.50, replace = FALSE)

## See the distribution
revSummary %>% ggplot(aes(Score)) + geom_histogram(col='black', stat='count')

# Wordcloud of Happy and Unhappy

revHappy <- revSummary %>% filter(Score == 'Happy')
wordcloud(revHappy$Summary, max.words=100, scale = c(5,1), colors=brewer.pal(8, "Dark2"))
revUnhappy <- revSummary %>% filter(Score == 'Unhappy')
wordcloud(revUnhappy$Summary, max.words=100, scale = c(5,1), colors=brewer.pal(9, "Set1"))

# Change Score to factor
revSummary$Score <- factor(revSummary$Score)

# Do the usual text cleanup: remove punctuations, change to lowercase, remove stop words and stem
# revCorpus <- Corpus(VectorSource(revSummary$Summary))

doc_ids <- c(1)

df <- data.frame(doc_id = doc_ids, text = revSummary$Summary, stringsAsFactors = FALSE)

revCorpus <- Corpus(DataframeSource(df))
revCorpus <- tm_map(revCorpus, removePunctuation)
revCorpus <- tm_map(revCorpus, trimws)
revCorpus  <- tm_map(revCorpus , removeWords, stopwords("english"))
revCorpus <- tm_map(revCorpus, tolower)
revCorpus <- tm_map(revCorpus, stemDocument, language = "english")
revCorpus  <- tm_map(revCorpus , removeWords, c("not", "what", "good",
                                                "this", "very", "didnt",
                                                "will", "doesnt", "the", "ever",
                                                "just", "dont", "can", "get", "bit"))

# Create the Wordcloud
library(wordcloud)
wordcloud(revCorpus,min.freq = 2,scale=c(5,1),colors=brewer.pal(8, "Dark2"),  random.color= TRUE, random.order = FALSE, max.words = 100)


## Let's create a model with Naive Bayes
# Create Document Term Matrix from the corpus

revdtm <- DocumentTermMatrix(revCorpus)
revdtm <- removeSparseTerms(revdtm, sparse = .99)
revdtm

set.seed(123456789)
## Split the dtm into 80% training set, 20% test set
test_index <- createDataPartition(y = revSummary$Score, times = 1, p = 0.2, list = FALSE)
revdtm_train_set <- revdtm[-test_index,]
revdtm_test_set <- revdtm[test_index,]

review_train_labels <- revSummary[-test_index,]$Score
review_test_labels <- revSummary[test_index,]$Score


# Use findFreqTerms() function to get a character vector containing the words
# that appear for at least the specified number of times
rev_freq_words <- findFreqTerms(revdtm_train_set, 5)

# Now filter the DTM to include only terms appearing in the frequent words vector
# We want all rows, but only the columns representing the words in the frequent words vector
revdtm_freq_train <- revdtm_train_set[ , rev_freq_words]
revdtm_freq_test <- revdtm_test_set[ , rev_freq_words]

# Convert counts to Yes/No strings:
convert_counts <- function(x) {
  x <- ifelse(x>0, "Yes", "No")
}

# Use the apply function specifying MARGIN = 2 for columns
# MARGIN = 1 for rows
revdtm_train <- apply(revdtm_freq_train, MARGIN=2, convert_counts)
revdtm_test <- apply(revdtm_freq_test, MARGIN=2, convert_counts)

## Load the e1071 library for Naive Bayes
library(e1071)
set.seed(123456789)
#rev_classifier <- naiveBayes(revdtm_train, review_train_labels, laplace=1)

rev_classifier <- train(revdtm_train, review_train_labels,'nb',
                        trControl=trainControl(method='cv',number=10))
# Predict
rev_test_pred <- predict(rev_classifier, revdtm_test)

# Create the confusion matrix
confusionMatrix(rev_test_pred, review_test_labels)

