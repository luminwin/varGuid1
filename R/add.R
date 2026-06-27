# Predict from fitted stage-1 varGuid models
#
# This CRAN release focuses on the global linear mean-variance model fitted by
# lmv(). The nonlinear grouping-based prediction extension described in Section 3
# of the companion paper is available in the development version on GitHub.

prd <- function(object, newdata, model = c("varGuid", "baseline"), ...) {
  model <- match.arg(model)

  if (!is.list(object) || is.null(object$obj.varGuid)) {
    stop("'object' must be the output of lmv().", call. = FALSE)
  }

  newx <- as.matrix(newdata)

  if (length(object$obj.OLS) > 0) {
    fit <- if (identical(model, "varGuid")) object$obj.varGuid else object$obj.OLS
    return(stats::predict(fit, newdata = as.data.frame(newx), ...))
  }

  if (length(object$obj.lasso) > 0) {
    fit <- if (identical(model, "varGuid")) object$obj.varGuid else object$obj.lasso
    return(drop(glmnet::predict.glmnet(fit, newx = newx, ...)))
  }

  stop("No fitted baseline or varGuid model was found in 'object'.", call. = FALSE)
}
