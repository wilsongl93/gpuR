library(gpuR)
context("Matrix classes")

set.seed(123)
A <- matrix(seq.int(10000), 100)
D <- matrix(rnorm(100), 10)
# B <- sample(seq.int(10000), 100, replace = TRUE)


test_that("gpuMatrix class contains correct information", {
    B <- as.numeric(rnorm(10))
    gpuA <- gpuMatrix(A)
    
    expect_is(gpuA, "igpuMatrix")
    expect_true(typeof(gpuA) == "integer")
    expect_equivalent(gpuA[,], A)
    
    gpuD <- gpuMatrix(D)
    expect_is(gpuD, "dgpuMatrix")
    expect_true(typeof(gpuD) == "double")
    expect_equivalent(gpuD[,], D)
    
    gpuF <- gpuMatrix(D, type="float")
    expect_is(gpuF, "fgpuMatrix")
    expect_true(typeof(gpuF) == "float")
    expect_equal(gpuF[,], D, tolerance = 1e-07)
    
    # can't convert a vector to a gpuMatrix
    expect_error(gpuMatrix(B))
})