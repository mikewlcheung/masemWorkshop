## ------------------------------------------------------------------------
## Required packages for this workshop
lib2install <- c("metaSEM", "semPlot", "readxl")

## Install them automatically if they are not available on your computer
for (i in lib2install) {
  if (!(i %in% rownames(installed.packages()))) install.packages(i)
}

## ------------------------------------------------------------------------
## Load the library to read XLSX file
library(readxl)

## Read the study characteristics
study <- read_xlsx("Digman97.xlsx", sheet="Info")

head(study)
 
## Create an empty list to store the correlation matrices
Digman97.data <- list()
  
## Read 1 to 14 correlation matrices
for (i in 1:14) {
  
  ## Read each sheet and convert it into a matrix
  mat <- as.matrix(read_xlsx("Digman97.xlsx", sheet=paste0("Study ", i)))
  
  ## Add the row names
  rownames(mat) <- colnames(mat)
  
  ## Save it into a list
  Digman97.data[[i]] <- mat
}

## Add the names of the studies
names(Digman97.data) <- study$Study

## Show the first few studies
head(Digman97.data)

## Extract the sample sizes
Digman97.n <- study$n
Digman97.n

## Extract the cluster
Digman97.cluster <- study$Cluster
Digman97.cluster

## ------------------------------------------------------------------------
model <- "## Factor loadings
          ## Alpha is measured by A, C, and ES
          Alpha =~ A + C + ES
          ## Beta is measured by E and I
          Beta =~ E + I
          ## Factor correlation between Alpha and Beta
          Alpha ~~ Beta"

## Display the model
plot(model, color="yellow")

## Convert the lavaan syntax into a RAM model as the metaSEM only knows the RAM model
## It is important to ensure that the variables are arranged in A, C, ES, E, and I.
RAM <- lavaan2RAM(model, obs.variables=c("A","C","ES","E","I"),
                  A.notation="on", S.notation="with")
RAM

## ------------------------------------------------------------------------
## method="FEM": fixed-effects TSSEM
fixed1 <- tssem1(Digman97.data, Digman97.n, method="FEM")

## summary of the findings
summary(fixed1)

## extract coefficients
coef(fixed1)

## ------------------------------------------------------------------------
fixed2 <- tssem2(fixed1, Amatrix=RAM$A, Smatrix=RAM$S, Fmatrix=RAM$F)
summary(fixed2)

## ---- warning=FALSE------------------------------------------------------
plot(fixed2, color="green")

## ------------------------------------------------------------------------
# Display the original study characteristic
table(Digman97.cluster)     

## Younger participants: "Children" and "Adolescents"
## Older participants: "Mature adults"
sample <- ifelse(Digman97.cluster %in% c("Children", "Adolescents"), 
                 yes="Younger participants", no="Older participants")

table(sample)

## cluster: variable for the analysis with cluster
fixed1.cluster <- tssem1(Digman97.data, Digman97.n, method="FEM", cluster=sample)

summary(fixed1.cluster)

## ------------------------------------------------------------------------
fixed2.cluster <- tssem2(fixed1.cluster, Amatrix=RAM$A, Smatrix=RAM$S, Fmatrix=RAM$F)

summary(fixed2.cluster)

## ---- warning=FALSE------------------------------------------------------
## Setup two plots
layout(t(1:2))
invisible(lapply(fixed2.cluster, plot))

## ------------------------------------------------------------------------
## Setup two plots
layout(t(1:2))

## Plot the first group
plot(fixed2.cluster[[1]])
title("Younger participants")

## Plot the second group
plot(fixed2.cluster[[2]])
title("Older participants")

## ------------------------------------------------------------------------
## method="REM": Random-effects model
random1 <- tssem1(Digman97.data, Digman97.n, method="REM", RE.type="Diag")

summary(random1)

## Extract the fixed-effects estimates
(est_fixed <- coef(random1, select="fixed"))

## Convert the estimated vector to a symmetrical matrix
## where the diagonals are fixed at 1 (for a correlation matrix)
vec2symMat(est_fixed, diag=FALSE)

## ---- warning=FALSE------------------------------------------------------
random2 <- tssem2(random1, Amatrix=RAM$A, Smatrix=RAM$S, Fmatrix=RAM$F)
summary(random2)

## ------------------------------------------------------------------------
## Plot the parameter estimates
plot(random2, color="green")

## ------------------------------------------------------------------------
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

## Convert the equation into RAM 
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

## Plot the model
plot(random2, color="green")

## ------------------------------------------------------------------------
## Sheets including correlation matrices
sheet <- as.character(1:14)

my.R2 <- list()
for (i in sheet) {
  my.R2[[i]] <- readxl::read_excel("Hunter83.xlsx", sheet=i)
}

## Read study names and sample sizes in sheet "0"
my.study <- readxl::read_excel("Hunter83.xlsx", sheet="0")

my.R2 <- lapply(my.R2, function(x) {x <- unlist(x)
                                    x <- matrix(x, ncol=4)
                                    x <- vechs(x)
                                    vec2symMat(x, diag=FALSE)})

var.names <- c("Ability", "Knowledge", "Work sample", "Supervisor")
my.R2 <- lapply(my.R2, function(x) { dimnames(x) <- list(var.names, var.names); x})
names(my.R2) <- my.study$Study
my.R2[1:2]

## ------------------------------------------------------------------------
model <- "## Regression paths
          Job_knowledge ~ A2J*Ability
          Work_sample ~ A2W*Ability + J2W*Job_knowledge
          Supervisor ~ J2S*Job_knowledge + W2S*Work_sample

          ## Fix the variance of Ability at 1
          Ability ~~ 1*Ability

          ## Label the error variances of the dependent variables
          Job_knowledge ~~ Var_e_J*Job_knowledge
          Work_sample ~~ Var_e_W*Work_sample
          Supervisor ~~ Var_e_S*Supervisor"

plot(model, color="yellow", layout="spring")

RAM <- lavaan2RAM(model, obs.variables=c("Ability","Job_knowledge",
                  "Work_sample","Supervisor"))
RAM

## ------------------------------------------------------------------------
## method="REM": Random-effects model
random1 <- tssem1(Hunter83$data, Hunter83$n, method="REM", RE.type="Diag")
summary(random1)

## Occasionally, we may encounter some error messages.
## We may try to remove the error messages by rerunning the model.
random1 <- rerun(random1)
summary(random1)

## Extract the fixed-effects estimates
(est_fixed <- coef(random1, select="fixed"))

## Convert the estimated vector to a symmetrical matrix
## where the diagonals are fixed at 1 (for a correlation matrix)
vec2symMat(est_fixed, diag=FALSE)

## ------------------------------------------------------------------------
random2 <- tssem2(random1, Amatrix=RAM$A, Smatrix=RAM$S, Fmatrix=RAM$F,
                  intervals.type="LB", 
                  mx.algebras=
                  list( ind=mxAlgebra(A2J*J2S+A2J*J2W*W2S+A2W*W2S, name="ind") )  )
summary(random2)

## Display the A matrix
mxEval(Amatrix, random2$mx.fit)

## Display the S matrix
mxEval(Smatrix, random2$mx.fit)

## ---- warning=FALSE------------------------------------------------------
plot(random2, color="yellow", layout="spring")

