\name{varGuid}
\alias{varGuid}
\title{Variance-Guided Regression Improving Upon OLS and ANOVA}
\description{
The \pkg{varGuid} package implements the global linear mean-variance model from
Liu and Lu (2026) using iteratively reweighted least squares and iteratively
reweighted lasso estimation for general linear-model design matrices, including
ANOVA-style encodings. This GitHub development version also includes the
Section 3 grouping-based nonlinear prediction extension through \code{ymodv()}
and \code{predict.varGuid()}.
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
summary(o$obj.varGuid)
summary(o$obj.OLS)
head(prd(o, train[, -yid], model = "baseline"))
head(prd(o, train[, -yid], model = "varGuid"))

# Iteratively reweighted lasso:
o2 <- lmv(X = train[, -yid], Y = train[, yid], lasso = TRUE)
o2$beta
o2$obj.lasso$beta
head(prd(o2, train[, -yid], model = "baseline"))
head(prd(o2, train[, -yid], model = "varGuid"))

# Section 3 grouping-based nonlinear prediction:
y.obj <- ymodv(obj = o)
pred <- predict.varGuid(mod = y.obj, lmvo = o, newdata = test[, -yid])
sqrt(colMeans((matrix(replicate(ncol(pred), test[, yid]), ncol = ncol(pred)) - pred)^2,
              na.rm = TRUE))
}
}
