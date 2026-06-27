\name{prd}
\alias{prd}
\title{Predict from Fitted Stage-1 varGuid Models}
\description{
A lightweight prediction helper for objects returned by \code{lmv()}. For
ordinary weighted least squares fits it dispatches to \code{stats::predict()}.
For iteratively reweighted lasso fits it dispatches to
\code{glmnet::predict.glmnet()} and returns a numeric vector.
}
\usage{
prd(object, newdata, model = c("varGuid", "baseline"), ...)
}
\arguments{
  \item{object}{An object returned by \code{lmv()}.}
  \item{newdata}{A matrix or data frame of predictors for prediction.}
  \item{model}{Which fitted model to use. \code{"varGuid"} uses the final
  variance-guided fit. \code{"baseline"} uses the initial OLS fit when
  \code{lasso = FALSE} or the initial lasso fit when \code{lasso = TRUE}.}
  \item{...}{Additional arguments passed to \code{stats::predict()} or
  \code{glmnet::predict.glmnet()}.}
}
\value{
A numeric vector of predictions.
}
\details{
This CRAN release covers the global linear mean-variance model from Section 2 of
Liu and Lu (2026). For the grouping-based nonlinear prediction extension from
Section 3 of the paper, please use the development version available at
\code{devtools::install_github("luminwin/varGuid")}.
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
head(prd(o, train[, -yid], model = "baseline"))
head(prd(o, train[, -yid], model = "varGuid"))

o2 <- lmv(X = train[, -yid], Y = train[, yid], lasso = TRUE)
head(prd(o2, train[, -yid], model = "baseline"))
head(prd(o2, train[, -yid], model = "varGuid"))
}
}
