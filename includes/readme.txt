All files in this directory are included by other files using the source() command. They are not run directly.

Files:

fit.dists.R - Fits focal and bm dists, tests fit and plots histograms
functions.fit.dists.R - Functions for fitting distributions and calculating
	quality scores
functions.R - general purpose functions, other than above
params.inc - basic parameters used by all files
test.dists.beta.R - GLM regression model fit using beta-family of distributions
	(including zero-inflated variants). Tests difference between focal and 
	benchmark coefficients and generates boxplots.
test.dists.gamma.R - GLM regression model fit using gamma distribution. Tests
	difference between focal and benchmark coefficients and generates boxplots.
test.dists.pois.R - GLM regression model fit using Poisson-family of 
	distributions (including Negative Binomial and zero-inflated variants). 
	Tests difference between focal and benchmark coefficients and generates
	boxplots.
transformations.R - Transformations of raw data