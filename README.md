# musical-instruments-product-reviews

The review file was 10,261 rows and 11 coloumns out of which the review text was the main corpus data and summary and over all rating were the additional attributees.
The raw data was downloaded in JSON format and using python it was converted into CSV format and were uploaded into R.

Preprocessing the file
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20322731/2627034c-ab48-11e6-9a59-3a5358d858dc.png)
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20322774/4898c58c-ab48-11e6-9259-1431185f03cd.png)

The image below shows the top features in the corpus after cleaning the corpus, tokenizing the corpus and making a dfm.
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20317236/3018aa6e-ab33-11e6-9ca6-33081dae59c1.png)

The dfm that was generated was as follows
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20318609/e1a8f2d4-ab38-11e6-86eb-abba113b0f6c.png)

Using the R package to fit the model
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20322952/efd7be3e-ab48-11e6-915d-10bff18ab2ee.png)

Visualizing the fit model
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20323021/2e459326-ab49-11e6-9a89-5ff25863a457.png)

Given below is a screen shot for the the ineractive topic modelling for the amazon reviews for various musical instruments.
![ScreenShot](https://cloud.githubusercontent.com/assets/22182351/20316792/722da244-ab31-11e6-82f6-9a2fff921b3f.png)

For instance, in the topic modelling, for topic 2 at a relavance metric of o.49 the top words in the topic are pedal, distortion, delay, boss, tone, boost, effect, overdrive etc. 
These words feature in other topics like, 1, 9, 8, 15, 3, 5 etc.
Pedal has featured approximately 2,500 times and 2100 times in topic 2 itself.

The below URL link shows the interactive topic modelling for this particular data set.

https://rawgit.com/pavitra11/musical-instruments-product-reviews/master/index.html
