\name{lmv}
\alias{lmv}
\title{Fit Variance-Guided Linear Mean-Variance Models}
\description{
Fits the stage-1 variance-guided linear model for heteroscedastic data using
iteratively reweighted least squares (IRLS) when \code{lasso = FALSE} or an
iteratively reweighted lasso procedure when \code{lasso = TRUE}. For
\code{lasso = FALSE}, the returned object also includes weighted least squares
and heteroscedasticity-consistent inference summaries based on the final fit.
}
\usage{
lmv(X, Y, M = 10, step = 1, tol = exp(-10), lasso = FALSE)
}
\arguments{
  \item{X}{Input matrix with observations in rows and predictors in columns.}
  \item{Y}{Numeric response vector.}
  \item{M}{Maximum number of iterations.}
  \item{step}{Scale parameter for the data weights.}
  \item{tol}{Tolerance parameter for convergence.}
  \item{lasso}{Logical; if \code{TRUE}, uses the iteratively reweighted lasso
  algorithm. Otherwise, IRLS is used.}
}
\value{
A list with the following components:
\item{beta}{Coefficient estimates from the final variance-guided fit.}
\item{obj.OLS}{Unweighted baseline \code{lm} fit used to initialize IRLS when
\code{lasso = FALSE}.}
\item{obj.lasso}{Unweighted baseline \code{glmnet} fit used to initialize the
iteratively reweighted lasso when \code{lasso = TRUE}.}
\item{obj.varGuid}{Final fitted model from either \code{lm} or \code{glmnet},
depending on \code{lasso}.}
\item{res}{Object returned by the variance-model update in the last iteration.}
\item{obj.varGuid.coef}{For \code{lasso = FALSE}, a list of weighted least
squares and heteroscedasticity-consistent coefficient summaries computed from
the final fit.}
\item{X}{The input design matrix \code{X}.}
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
\donttest{
data(cobra2d, package = "varGuid")
dat <- cobra2d
set.seed(1)
tid <- sample(seq_len(nrow(dat)), 200)
train <- dat[-tid, ]
yid <- which(colnames(dat) == "y")

o <- lmv(X = train[, -yid], Y = train[, yid], lasso = FALSE)
summary(o$obj.varGuid)
summary(o$obj.OLS)
head(prd(o, train[, -yid], model = "baseline"))
head(prd(o, train[, -yid], model = "varGuid"))

o2 <- lmv(X = train[, -yid], Y = train[, yid], lasso = TRUE)
o2$beta
o2$obj.lasso$beta
head(prd(o2, train[, -yid], model = "baseline"))
head(prd(o2, train[, -yid], model = "varGuid"))
}
}
