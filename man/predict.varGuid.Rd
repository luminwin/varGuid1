\name{predict.varGuid}
\alias{predict.varGuid}
\alias{predict}
\title{Variance-Guided Prediction with Artificial Grouping Effects}
\description{
Makes predictions for new data using the Section 3 artificial-grouping model
returned by \code{ymodv()} and the Section 2 fitted object returned by
\code{lmv()}.
}
\usage{
\method{predict}{varGuid}(mod, lmvo, newdata, redDim = FALSE)
}
\arguments{
  \item{mod}{Object returned by \code{ymodv()}.}
  \item{lmvo}{Object returned by \code{lmv()}.}
  \item{newdata}{A data frame or matrix of new predictor values.}
  \item{redDim}{Logical; set to \code{TRUE} if only variables with nonzero
  coefficients from \code{lmv()} were used for artificial grouping effects.}
}
\value{
A data frame with prediction columns:
\item{VarGuidOriginal}{Predicted outcome from the \code{lmv()} object without
adding artificial grouping effects.}
\item{VarGuid}{Predicted outcome with artificial grouping effects.}
\item{OLS}{Predicted outcome from the baseline OLS model when
\code{lasso = FALSE}.}
\item{Lasso}{Predicted outcome from the baseline lasso model when
\code{lasso = TRUE}.}
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
test <- dat[tid, ]
yid <- which(colnames(dat) == "y")

o <- lmv(X = train[, -yid], Y = train[, yid], lasso = FALSE)
y.obj <- ymodv(obj = o)
pred <- predict.varGuid(mod = y.obj, lmvo = o, newdata = test[, -yid])
sqrt(colMeans((matrix(replicate(ncol(pred), test[, yid]), ncol = ncol(pred)) - pred)^2,
              na.rm = TRUE))
}
}
