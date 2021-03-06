library(gpuR)
context("gpuMatrix Distance Computations")

if(detectGPUs() >= 1){
    current_context <- set_device_context("gpu")    
}else{
    current_context <- currentContext()
}

# set seed
set.seed(123)

ORDER <- 4

# Base R objects
A <- matrix(rnorm(ORDER^2), nrow=ORDER, ncol=ORDER)
B <- matrix(rnorm(ORDER^2), nrow=ORDER, ncol=ORDER)

# none square matrix
C <- matrix(rnorm(20), nrow = 5, ncol = 4)

# matrix for error check
G <- matrix(rnorm(25), nrow = 5, ncol = 5)

D <- as.matrix(dist(A))
sqD <- D^2

pD <- matrix(0, nrow=nrow(A), ncol=nrow(B))
# Pairwise check
for(i in 1:nrow(A)){
    for(j in 1:nrow(B)){
        pD[i,j] <- sqrt(sum((A[i,] - B[j,])^2))
    }
}

lpD <- matrix(0, nrow=nrow(A), ncol=nrow(C))
# Pairwise check
for(i in 1:nrow(A)){
    for(j in 1:nrow(C)){
        lpD[i,j] <- sqrt(sum((A[i,] - C[j,])^2))
    }
}

rpD <- matrix(0, nrow=nrow(C), ncol=nrow(A))
# Pairwise check
for(i in 1:nrow(C)){
    for(j in 1:nrow(A)){
        rpD[i,j] <- sqrt(sum((C[i,] - A[j,])^2))
    }
}

sqpD <- pD^2
lsqpD <- lpD^2
rsqpD <- rpD^2

test_that("gpuMatrix Single Precision Euclidean Distance",
{
    
    has_gpu_skip()
    
    fgpuX <- gpuMatrix(A, type="float")
    
    E <- dist(fgpuX)
    
    expect_equal(E[], D, tolerance=1e-06, 
                 info="float euclidean distances not equivalent",
                 check.attributes=FALSE)  
})

test_that("gpuMatrix Double Precision Euclidean Distance", 
{
    
    has_gpu_skip()
    has_double_skip()
    
    fgpuX <- gpuMatrix(A, type="double")
    
    E <- dist(fgpuX)
    
    expect_equal(E[], D, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double euclidean distances not equivalent",
                 check.attributes=FALSE) 
})

test_that("gpuMatrix Single Precision Squared Euclidean Distance",
{
    
    has_gpu_skip()
    
    fgpuX <- gpuMatrix(A, type="float")
    
    E <- dist(fgpuX, method = "sqEuclidean")
    
    expect_equal(E[], sqD, tolerance=1e-06, 
                 info="float squared euclidean distances not equivalent",
                 check.attributes=FALSE)  
})

test_that("gpuMatrix Double Precision Squared Euclidean Distance", 
{
    
    has_gpu_skip()
    has_double_skip()
    
    fgpuX <- gpuMatrix(A, type="double")
    
    E <- dist(fgpuX, method = "sqEuclidean")
    
    expect_equal(E[], sqD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double squared euclidean distances not equivalent",
                 check.attributes=FALSE) 
})

test_that("gpuMatrix Single Precision Pairwise Euclidean Distance",
{
    
    has_gpu_skip()
    
    fgpuA <- gpuMatrix(A, type="float")
    fgpuB <- gpuMatrix(B, type="float")
    fgpuC <- gpuMatrix(C, type="float")
    fgpuG <- gpuMatrix(G, type="float")
    
    E <- distance(fgpuA, fgpuB)
    lE <- distance(fgpuA, fgpuC)
    rE <- distance(fgpuC, fgpuA)
    
    expect_equal(E[], pD, tolerance=1e-06, 
                 info="float euclidean pairwise distances not equivalent",
                 check.attributes=FALSE)  
    expect_equal(lE[], lpD, tolerance=1e-06, 
                 info="float euclidean pairwise distances not equivalent",
                 check.attributes=FALSE)  
    expect_equal(rE[], rpD, tolerance=1e-06, 
                 info="float euclidean pairwise distances not equivalent",
                 check.attributes=FALSE)  
    expect_error(distance(fgpuA, fgpuG))
})

test_that("gpuMatrix Double Precision Pairwise Euclidean Distance", 
{
    
    has_gpu_skip()
    has_double_skip()
    
    fgpuA <- gpuMatrix(A, type="double")
    fgpuB <- gpuMatrix(B, type="double")
    fgpuC <- gpuMatrix(C, type="double")
    
    E <- distance(fgpuA, fgpuB)
    lE <- distance(fgpuA, fgpuC)
    rE <- distance(fgpuC, fgpuA)
    
    expect_equal(E[], pD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(lE[], lpD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(rE[], rpD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
})

test_that("gpuMatrix Single Precision Pairwise Squared Euclidean Distance",
{
    
    has_gpu_skip()
    
    fgpuA <- gpuMatrix(A, type="float")
    fgpuB <- gpuMatrix(B, type="float")
    fgpuC <- gpuMatrix(C, type="float")
    fgpuG <- gpuMatrix(G, type="float")
    
    E <- distance(fgpuA, fgpuB, method = "sqEuclidean")
    lE <- distance(fgpuA, fgpuC, method = "sqEuclidean")
    rE <- distance(fgpuC, fgpuA, method = "sqEuclidean")
    
    expect_equal(E[], sqpD, tolerance=1e-06, 
                 info="float squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(lE[], lsqpD, tolerance=1e-06, 
                 info="float squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(rE[], rsqpD, tolerance=1e-06, 
                 info="float squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE)  
    expect_error(distance(fgpuA, fgpuG))
})

test_that("gpuMatrix Double Precision Pairwise Squared Euclidean Distance", 
{
    
    has_gpu_skip()
    has_double_skip()
    
    fgpuA <- gpuMatrix(A, type="double")
    fgpuB <- gpuMatrix(B, type="double")
    fgpuC <- gpuMatrix(C, type="double")
    
    E <- distance(fgpuA, fgpuB, method = "sqEuclidean")
    lE <- distance(fgpuA, fgpuC, method = "sqEuclidean")
    rE <- distance(fgpuC, fgpuA, method = "sqEuclidean")
    
    expect_equal(E[], sqpD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(lE[], lsqpD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
    expect_equal(rE[], rsqpD, tolerance=.Machine$double.eps ^ 0.5, 
                 info="double squared euclidean pairwise distances not equivalent",
                 check.attributes=FALSE) 
})


test_that("gpuMatrix Integer Precision Euclidean Distance", 
          {
              
              has_gpu_skip()
              
              fgpuX <- gpuMatrix(A, type="integer")
              
              expect_error(dist(fgpuX), "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              
              # E <- dist(fgpuX)
              # 
              # expect_equal(E[], D, 
              #              info="integer euclidean distances not equivalent",
              #              check.attributes=FALSE) 
          })


test_that("gpuMatrix Integer Precision Squared Euclidean Distance", 
          {
              
              has_gpu_skip()
              
              fgpuX <- gpuMatrix(A, type="integer")
              
              expect_error(dist(fgpuX, method = "sqEuclidean"), "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              
              # E <- dist(fgpuX, method = "sqEuclidean")
              # 
              # expect_equal(E[], sqD, 
              #              info="integer squared euclidean distances not equivalent",
              #              check.attributes=FALSE) 
          })


test_that("gpuMatrix Integer Precision Pairwise Euclidean Distance", 
          {
              
              has_gpu_skip()
              
              fgpuA <- gpuMatrix(A, type="integer")
              fgpuB <- gpuMatrix(B, type="integer")
              fgpuC <- gpuMatrix(C, type="integer")
              
              
              expect_error(distance(fgpuA, fgpuB), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              expect_error(distance(fgpuA, fgpuC), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              expect_error(distance(fgpuC, fgpuA), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              
              # E <- distance(fgpuA, fgpuB)
              # lE <- distance(fgpuA, fgpuC)
              # rE <- distance(fgpuC, fgpuA)
              # 
              # expect_equal(E[], pD,
              #              info="integer euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
              # expect_equal(lE[], lpD,
              #              info="integer euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
              # expect_equal(rE[], rpD,
              #              info="integer euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
          })


test_that("gpuMatrix Integer Precision Pairwise Squared Euclidean Distance", 
          {
              
              has_gpu_skip()
              
              fgpuA <- gpuMatrix(A, type="integer")
              fgpuB <- gpuMatrix(B, type="integer")
              fgpuC <- gpuMatrix(C, type="integer")
              
              expect_error(distance(fgpuA, fgpuB, method = "sqEuclidean"), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              expect_error(distance(fgpuA, fgpuC, method = "sqEuclidean"), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              expect_error(distance(fgpuC, fgpuA, method = "sqEuclidean"), 
                           "integer method not currently implemented",
                           info = "dist shouldn't accept integer types")
              
              # E <- distance(fgpuA, fgpuB, method = "sqEuclidean")
              # lE <- distance(fgpuA, fgpuC, method = "sqEuclidean")
              # rE <- distance(fgpuC, fgpuA, method = "sqEuclidean")
              # 
              # expect_equal(E[], sqpD, 
              #              info="integer squared euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
              # expect_equal(lE[], lsqpD, 
              #              info="integer squared euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
              # expect_equal(rE[], rsqpD,
              #              info="integer squared euclidean pairwise distances not equivalent",
              #              check.attributes=FALSE) 
          })


setContext(current_context)
