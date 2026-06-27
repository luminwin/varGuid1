\docType{data}
\name{cobra2d}
\alias{cobra2d}
\title{Data from the cobra2 Simulation}
\description{
Data with non-linear and interaction relationship with 500 observations and 15 variables.
}
\usage{
data(cobra2d)
}
\references{
Liu, S. and Lu, M. (2026). \emph{Variance-Guided Regression for Heteroscedastic
Data with a Grouping-Based Extension for Nonlinear Prediction}.
\emph{Statistics in Medicine}. 45(13-14):e70632. \doi{10.1002/sim.70632}
}
\author{
Sibei Liu and Min Lu
}
\examples{

# library(copula)
# cobra2 = function(n = 500, d = 15, sd = .1, corrv = 0) {
#   set.seed(1)
#   d <- max(10, d)
#   X <- matrix(runif(n * d, -1, 1), ncol = d)
#   paramlist <- lapply(1:d, function(j) {list(min=-1,max=1)})
#   myCop <- normalCopula(param=rep(corrv,dim(combn(d,2))[2]), dim = d, dispstr = "un")
#   myMvd <-  mvdc(copula=myCop, margins=rep("unif",d),paramMargins=paramlist)
#   X[, 1:d] <- rMvdc(n, myMvd)
#   dta <- data.frame(list(x = X, y = X[,1]*X[,2] + X[,3]^2 - X[,4]*X[,7] + X[,8]*X[,10] - X[,6]^2
#                          + rnorm(n, sd = sd)))
#   colnames(dta)[1:d] <- paste("x", 1:d, sep = "")
#   f <- "x1 * x2 + x3 ^ 2 - x4 * x7 + x8 * x10 - x6 ^ 2"
#   fs <- "I(x1 * x2) + I(x3 ^ 2) + I(-x4 * x7) + I(x8 * x10) - I(x6 ^ 2)"
#   list(f = f, fs = fs, dta = dta)
# }

data(cobra2d)
}
