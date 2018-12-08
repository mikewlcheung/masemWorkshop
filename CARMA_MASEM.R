## ------------------------------------------------------------------------
## Required packages for this workshop
lib2install <- c("metaSEM", "semPlot", "readxl")

## Install them automatically if they are not available on your computer
for (i in lib2install) {
  if (!(i %in% rownames(installed.packages()))) install.packages(i)
}

## ------------------------------------------------------------------------
## Load the library for MASEM
library(metaSEM)

## Load the library to read XLSX file
library(readxl)

## Read the first sheet in the Excel file
my.xlsx <- read_excel("Becker94.xlsx")
my.xlsx

## Split the data by rows
my.R2 <- split(my.xlsx[, 2:4], seq(nrow(my.xlsx)))
head(my.R2)

## Convert the row correlations into correlation matrices
my.R2 <- lapply(my.R2, function(x) vec2symMat(unlist(x), diag=FALSE))
head(my.R2)

## Add the labels
var.names <- c("SAT_Math", "Spatial", "SAT_Verbal")
my.R2 <- lapply( my.R2, function(x) { dimnames(x) <- list(var.names, var.names); x} )

## Add the study name
names(my.R2) <- my.xlsx$Study
head(my.R2)

## ------------------------------------------------------------------------
## Regression model
model <- "SAT_Math ~ Spatial + SAT_Verbal
          ## Correlation between Spatial and Verbal
          Spatial ~~ SAT_Verbal
          ## Fix the variances of the independent variables at 1.0
          Spatial ~~ 1*Spatial
          SAT_Verbal ~~ 1*SAT_Verbal"

## Plot the model
plot(model, color="yellow")

## Convert the lavaan syntax into a RAM model as the metaSEM only knows the RAM model
RAM <- lavaan2RAM(model, obs.variables=c("SAT_Math", "Spatial", "SAT_Verbal"))
RAM

## ------------------------------------------------------------------------
## method="FEM": fixed-effects TSSEM
fixed1 <- tssem1(Becker94$data, Becker94$n, method="FEM")

## summary of the findings
summary(fixed1)

## ------------------------------------------------------------------------
## method="REM": Random-effects model
random1 <- tssem1(Becker94$data, Becker94$n, method="REM", RE.type="Diag")
summary(random1)

## Extract the fixed-effects estimates
(est_fixed <- coef(random1, select="fixed"))

## Convert the estimated vector to a symmetrical matrix
## where the diagonals are fixed at 1 (for a correlation matrix)
vec2symMat(est_fixed, diag=FALSE)

## ------------------------------------------------------------------------
random2 <- tssem2(random1, Amatrix=RAM$A, Smatrix=RAM$S, Fmatrix=RAM$F)
summary(random2)

## S matrix
mxEval(Smatrix, random2$mx.fit)

## R2
mxEval(1-Smatrix, random2$mx.fit)[1,1]

## ------------------------------------------------------------------------
plot(random2, color="green")

