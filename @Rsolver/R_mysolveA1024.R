library('MASS')

R_mysolveA1024 <- function () {

  M0 = read.csv("R_M1024.txt",header=FALSE)
  M = matrix(unlist(M0),ncol=1024)

  B0 = read.csv("R_B.txt",header=FALSE)
  B = matrix(unlist(B0),ncol=1)

  A.init <- t(M) %*% ginv(M %*% t(M)) %*% B
  objfnc <- function (A) sum(((M %*% A - B)^2) * 1)
  
#  res <- optim(A.init, objfnc, method = "L-BFGS-B", lower = 0, upper = Inf, control = list(trace = 2, pgtol = 5e-6))
    res <- optim(A.init, objfnc, method = "L-BFGS-B", lower = 0, upper = Inf, control = list(trace = 2, pgtol = 5e-7))

  write.table(res$par,file="R_A.txt",sep=",",row.names = FALSE,col.names = FALSE)
}