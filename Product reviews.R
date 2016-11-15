library(quanteda)
library(stm)
library(tm)
library(NLP)
library(openNLP)
library(ggplot2)
library(ggdendro)
library(cluster)
library(fpc)  

require(quanteda)

head(musicalinstrumets)
names(musicalinstrumets)
help(corpus)
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

term.table <- table(unlist(reviewsclean))
term.table <- sort(term.table, decreasing = TRUE)

stop_words <- stopwords("SMART")
stop_words <- c(stop_words, "can", "one", "will", "get", "just", "want","got", 
                "even", "way", "even", "also","like","make","go")
stop_words <- tolower(stop_words)

del <- names(term.table) %in% stop_words | term.table < 5
term.table <- term.table[!del]
term.table <- term.table[names(term.table) != ""]
vocab <- names(term.table)

get.terms <- function(x) {
  index <- match(x, vocab)
  index <- index[!is.na(index)]
  rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
}
documents <- lapply(reviewsclean, get.terms)

D <- length(documents)  # number of documents (1)
W <- length(vocab)  # number of terms in the vocab (1741)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [312, 288, 170, 436, 291, ...]
N <- sum(doc.length)  # total number of tokens in the data (56196)
term.frequency <- as.integer(term.table)

K <- 15
G <- 3000
alpha <- 0.02
eta <- 0.02

library(lda)
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
## display runtime
t2 - t1  

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

reviewdata <- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

library(LDAvis)
library(servr)

json <- createJSON(phi = reviewdata$phi, 
                   theta = reviewdata$theta, 
                   doc.length = reviewdata$doc.length, 
                   vocab = reviewdata$vocab, 
                   term.frequency = reviewdata$term.frequency)

serVis(json, out.dir = 'Musical_Instuments', open.browser = TRUE)
