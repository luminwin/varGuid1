library(cvxclustr) # convex clustering
library(randomForestSRC)
#####################
# convex clustering
#####################

covx <- function(x, Knn = 9, phi = 0.46,
                 gamma = c(seq(0,8.56, length.out=5))){ # Knn if wants Knn kernel
  x <- as.data.frame(x)
  nums <- unlist(lapply(x, is.numeric))
  X <- t(scale(as.matrix(x[,nums])))
  n <- ncol(X)
  ## Pick some weights and a sequence of regularization parameters.
  w <- cvxclustr::kernel_weights(X,phi)
  if (!is.null(Knn)){
    k <- Knn
    w <- cvxclustr::knn_weights(w,k,n) }
  ## Perform clustering

  list(sol = cvxclustr::cvxclust(X,w,gamma,nu = 1/nrow(x)), w = w, x = x[,nums], x.all = x, gamma = gamma, Knn = Knn )
}

#####################################################
# fake random effect from cluster object
######################################################
fakez <- function(obj){      ### extract clusters from a convex object
  sol <- obj$sol
  w <- obj$w
  n <- length(sol$U[[1]][1,])
  lapply(1:sol$nGamma,function(i){
    A <- cvxclustr::create_adjacency(sol$V[[i]],w,n)
    cvxclustr::find_clusters(A)
  })
}

cent <- function(dat,cluster)  ### calculate centers from clusters of training data
{ x <- data.frame(matrix(NA,length(unique(cluster)),length(dat[1,])))
colnames(x) <- colnames(dat)
for (i in sort(unique(cluster)))
{ if (length(which(cluster==i))==1){x[i,] <- dat[which(cluster==i),]}
  else {x[i,] <- colMeans(dat[which(cluster==i),])}}
x
}
clusters <- function(x, centers) { ### calculate clusters for test data according to cluster centers of training data
  # compute squared euclidean distance from each sample to each cluster center
  tmp <- sapply(seq_len(nrow(x)),
                function(i) apply(centers, 1,
                                  function(v) sum((x[i, ]-v)^2)))
  max.col(-t(tmp))  # find index of min distance
}
#####################################################
# optimize random effect # in mixed linear model
######################################################
chooseq <- function(obj,y.obj,x.new,y.new)
{ rdef.all<-fakez(obj)
dat.train <- lapply(1:length(rdef.all),function(i){
  dat.train <- as.data.frame(scale(as.matrix(obj$x)))
  dat.train$y <- y.obj
  dat.train$z <- as.factor(as.character(rdef.all[[i]]$cluster))
  dat.train
})
q=lapply(1:length(dat.train),function(i){length(levels(dat.train[[i]]$z))})
dat.test=as.data.frame(x.new)
nums <- unlist(lapply(dat.test, is.numeric))
dat.test[,nums] <- scale(x.new[,nums])
mlm <- lapply(1:length(dat.train),function(i){
  tryCatch({
    if (length(rdef.all[[i]]$size)>(length(y.obj)-ncol(x.new)-1)) {
      return(NA)} else {
        mod.rlm <- stats::lm(stats::as.formula(paste("y~",paste(colnames(dat.test[,nums]),collapse = "+"))),
                      dat.train[[i]])
        center <- cent(dat = obj$x,cluster = rdef.all[[i]]$cluster)

        dat.test$z <- as.factor(as.character(clusters(x.new[,nums],center)))

        yhat.rlm <- stats::predict(mod.rlm,as.matrix(dat.test))
        sqrt(mean((y.new-yhat.rlm)^2))
      }}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}
)
list(rmse = unlist(mlm),q = unlist(q), gamma = obj$gamma)
}
#####################################################
# decide final model after optimizing gamma and phi
######################################################
fnmod <- function(dat.x,dat.y,Knn = 10, gamma = c(seq(0,8.56, length.out=5)), phi = 0.45)
{  data <- as.data.frame(dat.x)
nums <- unlist(lapply(data, is.numeric))
obj <- covx(x = as.matrix(dat.x[,nums]),Knn = Knn,
            gamma = gamma,phi = phi)
w <- obj$w
n <- dim(obj$sol$U[[1]])[2]
A <- cvxclustr::create_adjacency(obj$sol$V[[1]],w,n)
rdef.all <- cvxclustr::find_clusters(A)
data$z <- as.factor(as.character(rdef.all$cluster))
data$y <- dat.y
if (dim(dat.x)[2] == 1) dat.x <- cbind(dat.x,dat.x)
center <- cent(dat = dat.x,cluster = rdef.all$cluster)
list( clust = obj,
      data = data,
      center = center)
}
#####################################################
# prediction using final model
######################################################
predict.varGuid <- predict <- function(mod,lmvo,newdata, redDim = FALSE){
  newdata <- as.matrix(newdata)
  dat.test <- as.data.frame(newdata)
  nums <- unlist(lapply(dat.test, is.numeric))
  if (dim(newdata)[2] == 1) {
    newdata <- data.frame(X = as.vector(newdata))
    nums <- c(1,1)
  }
  if (length(mod$center) == 0) { dat.test$z <- NA
  mod$data$z <- lmvo$obj.varGuid$model$Y
  } else {
  dat.test$z <- as.character(clusters(newdata[,nums],mod$center))
  }

  if (length(lmvo$obj.OLS)==0){
    lmvo$obj.OLS <- lmvo$obj.lasso
    yhat0 <- yhat <- yhat2 <- glmnet::predict.glmnet(lmvo$obj.varGuid,as.matrix(newdata))
    yhat0b <- glmnet::predict.glmnet( lmvo$obj.OLS,as.matrix(newdata))
  } else {
    yhat0 <- yhat <- yhat2 <- stats::predict(lmvo$obj.varGuid,as.data.frame(newdata))
    yhat0b <- stats::predict( lmvo$obj.OLS,as.data.frame(newdata))
  }
   if (redDim == TRUE) {
    datrf <- data.frame(Y = c(lmvo$obj.varGuid$residuals),
                              subset(lmvo$obj.varGuid$model, select = -c(1,ncol(lmvo$obj.varGuid$model))) )
   } else {
      datrf <- data.frame(Y = c(lmvo$obj.varGuid$residuals),
                          lmvo$X )
   }
    rfo <- randomForestSRC::rfsrc(Y~., data= datrf)
    mod$data$y <- rfo$predicted.oob
    ycenter <- stats::aggregate(y~z,data = mod$data,mean)
   #yhat <- yhat0 + ycenter$y[match(dat.test$z,ycenter$z)]
    resd <- abs(lmvo$obj.varGuid$residuals)-sqrt(abs(lmvo$res$fitted.values))
    mod$data$y[which(resd<0)] <- 0
    ycenter <- stats::aggregate(y~z,data = mod$data,mean)
    testrf <- randomForestSRC::predict.rfsrc(rfo,as.data.frame(newdata))
    yhat2 <- c(yhat0) + c(testrf$predicted)

returnd <- data.frame(VarGuidOriginal = c(yhat0),
                  #  VarGuid1 = c(yhat),
                     VarGuid = c(yhat2))
if (length(lmvo$obj.OLS)==0){
  returnd$Lasso <- c(yhat0b)
} else {
  returnd$OLS <- c(yhat0b)
}

returnd
}

ymodv <- function(obj, nu = c(seq(0,9, length.out=5))){
  dat <- obj$obj.varGuid$model


  if (ncol(dat) == 3){
    dat <- cbind( obj$obj.varGuid$model[,1],
                 obj$X[,order(stats::cor(dat[,2],obj$X),decreasing = TRUE)[1:min(ncol(obj$X),5)]],
                  obj$obj.varGuid$model[,ncol(obj$obj.varGuid$model)])
    dat <- as.data.frame(dat)
  }

  colnames(dat)[1] <- "Y"
  colnames(dat)[ncol(dat)] <- "weights"

  mod <- fnmod( dat.x=subset(dat, select = -c(Y,weights)),
               dat.y=dat$Y,
               Knn = 10,
               gamma = nu, phi = 0.45)
  mod
}

