# Musical Instruments Product Reviews

The review file was 10,261 rows and 11 coloumns out of which the review text was the main corpus data and summary and over all rating were the additional attributees.
The raw data was downloaded in JSON format and using python it was converted into CSV format and were uploaded into R.

# Preprocessing the file
#pre-processing:
reviews<- corpus(musicalinstrumets$reviewText,
                    docnames=musicalinstrumets$ID,
                    docvar=data.frame(summary=musicalinstrumets$summary,overall= musicalinstrumets$summary))

help(tokenize)
reviews<- toLower(reviews, keepAcronyms = FALSE) 
reviewsclean <- tokenize(reviews, 
                        removeNumbers=TRUE,  
                        removePunct = TRUE,
                        removeSeparators=TRUE,
                        removeTwitter=FALSE,
                        verbose=TRUE)

dfm.reviews<- dfm(reviewsclean,
                 toLower = TRUE, 
                 ignoredFeatures =stopwords("english"), 
                 verbose=TRUE, 
                 stem=TRUE)
head(dfm.reviews)

topfeatures<-topfeatures(dfm.reviews, n=50)
topfeatures
#compute the table of terms:
term.table <- table(unlist(reviewsclean))
term.table <- sort(term.table, decreasing = TRUE)
#read in some stopwords:
stop_words <- stopwords("SMART")
stop_words <- c(stop_words, "can", "one", "will", "get", "just", "want","got", 
                "even", "way", "even", "also","like","make","go")
stop_words <- tolower(stop_words)
#remove terms that are stop words or occur fewer than 5 times:
del <- names(term.table) %in% stop_words | term.table < 5
term.table <- term.table[!del]
term.table <- term.table[names(term.table) != ""]
vocab <- names(term.table)
#now put the documents into the format required by the lda package:
get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(reviewsclean, get.terms)

The image below shows the top features in the corpus after cleaning the corpus, tokenizing the corpus and making a dfm.
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20317236/3018aa6e-ab33-11e6-9ca6-33081dae59c1.png)

The dfm that was generated was as follows
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20318609/e1a8f2d4-ab38-11e6-86eb-abba113b0f6c.png)

Using the R package to fit the model
#Compute some statistics related to the data set:
D <- length(documents)  
W <- length(vocab)  # number of terms in the vocab (5937)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  
N <- sum(doc.length)  # total number of tokens in the data (322238L)
term.frequency <- as.integer(term.table)
#MCMC and model tuning parameters:
K <- 15
G <- 3000
alpha <- 0.02
eta <- 0.02
#Fit the model:
library(lda)
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
#display runtime
t2 - t1  
#takes about 10 minutes to run it on an 8GB laptop

# Visualizing the fit model
We set up a topic model with 15 topics, relatively diffuse priors for the topic-term distributions (η= 0.02) and document-topic distributions (α= 0.02), and we set the collapsed Gibbs sampler to run for 5,000 iterations. We notice that it takes about 10 minuted for the model to run on an 8 GB laptop.

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

reviewdata <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

library(LDAvis)
library(servr)
#Create JSON to feed the visualization
json <- createJSON(phi = reviewdata$phi, 
                   theta = reviewdata$theta, 
                   doc.length = reviewdata$doc.length, 
                   vocab = reviewdata$vocab, 
                   term.frequency = reviewdata$term.frequency)

serVis(json, out.dir = 'Musical_Instument', open.browser = TRUE)

Given below is a screen shot for the the ineractive topic modelling for the amazon reviews for various musical instruments.
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20323150/a17ed622-ab49-11e6-9f5a-b81617e46424.png)

For instance, in the topic modelling, for topic 15 at a relavance metric of 0.5 the top words in the topic are cloth, ploish, cleaning, dry, humidity etc. 
For instance the word cloth also features in topic 1 and 13
cloth has featured approximately 150 times and 100 times in topic 15 itself.

We can also notice in topic 8 that guitar is the 8th most relavent term in the topic and it also features in various other topics. So, we can conclude that topic 8 is broadly dealing with string instruments. Such words work as linkages for these various topics. Also from a quick look into topc 15 we can conclude that deals with cleaning supplies for various instruemnts and hence heavily overlaps with multiple topics. 

Also, topic 6 is somewhat isolated since it deals with products that are used auxilarily for the sound systems, like mics, stands, base etc. So they do not majorly overlap with any other topics.

The below URL link shows the interactive topic modelling for this particular data set.

https://rawgit.com/pavitra11/musical-instruments-product-reviews/master/index.html
