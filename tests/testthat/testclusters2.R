skip_old_windows <- function() {
#	testthat::skip_if_not(R.Version()$arch != "i386", "largeVis does not run on 32-bit Windows.")
}
context("optics")

set.seed(1974)
data(iris)
dat <- as.matrix(iris[, 1:4])
dat <- scale(dat)
dupes <- which(duplicated(dat))
dat <- dat[-dupes, ]
dat <- t(dat)
K <- 20
neighbors <- randomProjectionTreeSearch(dat, K = K,  threads = 2, verbose = FALSE)
edges <- buildEdgeMatrix(data = dat,
                          neighbors = neighbors,
                          verbose = FALSE)
test_that("optics doesn't crash on iris with neighbors and data", {
	skip_old_windows()
  expect_silent(largeVis:::optics(neighbors = neighbors, data = dat, eps = 10, minPts = 10, verbose = FALSE))
})

test_that("optics doesn't crash on iris with edges", {
	skip_old_windows()
  expect_silent(largeVis:::optics(edges = edges, eps = 10, minPts = 10, verbose = FALSE))
})

test_that("optics doesn't crash on iris with edges and data", {
	skip_old_windows()
  expect_silent(largeVis:::optics(edges = edges, data = dat, eps = 10, minPts = 10, verbose = FALSE))
})

context("LOF")

test_that(paste("LOF is consistent", 20), {
	skip_old_windows()
	load(system.file("extdata/truelof20.Rda", package = "largeVis"))
	ourlof <- largeVis:::lof(edges)
	expect_lt(sum(truelof20 - ourlof)^2 / ncol(dat), 0.4)
})

test_that("LOF is consistent 10", {
	skip_old_windows()
	edges <- buildEdgeMatrix(data = dat,
													 neighbors = neighbors[1:10,],
													 verbose = FALSE)
	load(system.file("extdata/truelof10.Rda", package = "largeVis"))
	ourlof <- largeVis:::lof(edges)
	expect_lt(sum(truelof10 - ourlof)^2 / ncol(dat), 0.4)
})

context("hdbscan")

test_that("hdbscan finds 3 clusters and outliers in spiral", {
	skip_old_windows()
	load(system.file("extdata/spiral.Rda", package = "largeVis"))
	clustering <- hdbscan(spiral, K = 3, minPts = 20, threads = 1)
	expect_equal(length(unique(clustering$clusters)), 4)
})

set.seed(1974)
data(iris)
dat <- as.matrix(iris[, 1:4])
dat <- scale(dat)
dupes <- which(duplicated(dat))
dat <- dat[-dupes, ]
dat <- t(dat)
K <- 20
neighbors <- randomProjectionTreeSearch(dat, K = K,  threads = 2, verbose = FALSE)
edges <- buildEdgeMatrix(data = dat, neighbors = neighbors, verbose = FALSE)

test_that("hdbscan doesn't crash with neighbors", {
	skip_old_windows()
	expect_silent(hdbscan(edges, minPts = 10, neighbors = neighbors, K = 3, threads = 2, verbose = FALSE))
})

test_that("hdbscan is correct", {
	skip_old_windows()
  clustering <- hdbscan(edges, minPts = 10, K = 3,  threads = 2, verbose = FALSE)
  expect_equal(length(unique(clustering$clusters)), 3)
})

test_that("hdbscan is less correct with neighbors", {
	skip_old_windows()
  clustering <- hdbscan(edges, neighbors = neighbors, minPts = 10, K = 3,  threads = 2, verbose = FALSE)
  expect_equal(length(unique(clustering$clusters)), 2)
})

test_that("hdbscan doesn't crash on glass edges", {
	skip_old_windows()
	load(system.file("extdata/glassEdges.Rda", package = "largeVis"))
	clustering <- hdbscan(edges, threads = 2, verbose = FALSE)
	expect_equal(length(unique(clustering$clusters)), 3)
})

test_that("hdbscan doesn't crash on big bad edges", {
	skip("skipping big bad edges test because the data is too big for cran")
	load(system.file("extdata/kddneighbors.Rda", package = "largeVis"))
	load(system.file("extdata/kddedges.Rda", package = "largeVis"))
	expect_silent(clusters <- hdbscan(edges, neighbors = neighbors, threads = 2, verbose = FALSE))
})

test_that("hdbscan doesn't crash on big bad edges", {
	skip_old_windows()
	skip_on_cran()
	skip("skipping long test")
	load(system.file("extdata/badedges.Rda", package = "largeVis"))
	expect_silent(clustering <- hdbscan(badedges, threads = 2, verbose = FALSE))
})