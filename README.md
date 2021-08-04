# ImageClassifier

## Usage

### Training
First train the model. Requires a folder containing only images (-F) and a manually curated classification (-C)

`perl ImageClassifier/Classy.pl -T Train -F Trainer -C ImageClassifier/classification.csv`

### Prediction

After model Training, the classification of images in a folder 

`
perl ImageClassifier/Classy.pl -T Classify -F All Images
`

## Usage

Requires the R library [randomForest](https://cran.r-project.org/web/packages/randomForest/index.html) from CRAN. For the image analysis, [ImageJ](https://imagej.nih.gov/ij/) is needed.
