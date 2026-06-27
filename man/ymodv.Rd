\name{ymodv}
\alias{ymodv}
\title{Create Artificial Grouping Effects for Nonlinear Prediction}
\description{
Implements the Section 3 convex-clustering step for creating artificial grouping
effects from the fitted object returned by \code{lmv()}. The convex clustering
algorithm is imported from the \pkg{cvxclustr} package.
}
\usage{
ymodv(obj, nu = c(seq(0, 9, length.out = 5)))
}
\arguments{
  \item{obj}{Object returned by \code{lmv()}.}
  \item{nu}{Parameter controlling the number of artificial groups. This is the
  same role as the \code{gamma} argument in \code{cvxclustr::cvxclust()}.}
}
\value{
A list with the following components:
\item{clust}{A list in which \code{sol} contains the output from
\code{cvxclustr::cvxclust()}, along with other parameters used for clustering.}
\item{data}{A data frame from the clustering algorithm, where \code{z} contains
the grouping factor.}
\item{center}{Centers of the artificial groups.}
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
y.obj <- ymodv(obj = o)
}
}
