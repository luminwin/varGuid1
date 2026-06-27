library(lmtest)
library(sandwich)
library(glmnet)


beta_est=function(X, Y, w, step = 1, lasso = FALSE){
  if (lasso == FALSE) {
  o <- stats::lm(Y~.,data = data.frame(X,Y=Y), weights = exp(-step*w))
  } else {
    nfolds <- 10
    if (nrow(X)/10<=8){
      nfolds <- 3
    }
    cv_model <- glmnet::cv.glmnet(X, Y, alpha = 1,
                          nfolds = nfolds,
                          weights = exp(-step*w))

    #find optimal lambda value that minimizes test MSE
    best_lambda <- cv_model$lambda.min
    o <- glmnet::glmnet(X, Y, alpha = 1, lambda = best_lambda, weights = exp(-step*w))

    o$fitted.values <- glmnet::predict.glmnet(o, newx = X)

    o$residuals <- Y - o$fitted.values

    o$model <- data.frame(Y = Y, X[, which(as.vector(o$beta) != 0)], w = w)
    colnames(o$model)[ncol(o$model)] <- "(weights)"
  }
  beta <- stats::coef(o)

  return(list(beta = beta, obj = o))
}
w_est=function(X,beta_obj, lasso = FALSE){
  if (lasso == FALSE) {
  o <- stats::lm(Y~.,data = data.frame(X = X^2,Y = (beta_obj$residuals)^2))
  r <- o$fitted.values
  } else {
    nfolds <- 10
    if (nrow(X)/10<=8){
      nfolds <- 3
    }
    cv_model <- glmnet::cv.glmnet(X^2, (beta_obj$residuals)^2,
                          nfolds = nfolds,
                          alpha = 1)

    #find optimal lambda value that minimizes test MSE
    best_lambda <- cv_model$lambda.min
    o <- glmnet::glmnet(X^2, (beta_obj$residuals)^2, alpha = 1, lambda = best_lambda)
    r <- o$fitted.values <- glmnet::predict.glmnet(o, newx = X^2)
  }

  m <- max(r)[1]
  # gamma <- coef(o)
  return(list(w = r/m, res = o))
}
##### check if the above result is correct
lmv <- function(X, Y, M =  10, step = 1, tol = exp(-10), lasso = FALSE){
  X <- Xo <- as.matrix(X)
n <- length(Y)
diff1 <- step

o1 <- o <- beta_est(X, Y, w = rep(1,nrow(X)), lasso = lasso)
beta <- o1$beta
obj.OLS <- o1$obj


for (i in 1:M) {


  old_beta <- beta

  res <- w_est(X,beta_obj = o$obj, lasso = lasso)
  w <- res$w
  o <- beta_est(X, Y,w, step = step, lasso = lasso)
  if (diff1 > tol) {
    beta <- o$beta
    obj.varGuid <- o$obj


  } else {
    step <- 0.1*step
    next
  }
  diff1=sum((beta-old_beta)^2, na.rm = TRUE)

}

obj.coef <- obj.lasso <- list()

if (lasso == FALSE) {
obj.coef$WLS <- summary(obj.varGuid)
obj.coef$HC3 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC3"))
obj.coef$HC <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC"))
obj.coef$HC0 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC0"))
obj.coef$HC1 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC1"))
obj.coef$HC2 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC2"))
obj.coef$HC4 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC4"))
obj.coef$HC4m <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC4m"))
obj.coef$HC5 <- lmtest::coeftest(obj.varGuid, vcov = sandwich::vcovHC(obj.varGuid, "HC5"))
}  else {
  obj.lasso <- obj.OLS
  obj.OLS <- list()
  if (obj.varGuid$df <= 1) { o$obj.varGuid <- obj.lasso}
}

list(beta=beta, obj.OLS = obj.OLS, obj.lasso = obj.lasso,
     obj.varGuid = obj.varGuid, res = res$res, obj.varGuid.coef = obj.coef,
     X = Xo)
}


