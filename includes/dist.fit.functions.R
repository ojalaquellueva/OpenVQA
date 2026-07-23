########## UNDER CONSTRUCTION! ###########

####################################################
# Distribution fitting functions
####################################################

# Requires main functions file, at least until I move all distribution-related
# functions here
require_once "functions.R"

# Force strictly local scope for functions
strict <- function(f, pos=2) eval(substitute(f), as.environment(pos))

# Dummy function used to detect if already loaded. Do not delete!
dist.fit.functions.loaded <- function() {}

boot.overlap.tnorm <- function(test.tail=NULL, f, b, xs=NULL, 
	right=NULL, left=NULL,
	q.tr.logit.inverse=TRUE,
	boot.reps=NULL, seed=NULL, set.seed=F, ...) {
	
	########## UNDER CONSTRUCTION! ###########

	###################################################
	# Fit truncated-normal distribution to each of two vectors ("focal" &
	# "Benchmark") using function fitdistr(), then calculate overlap 
	# between the two distributions and bootstrapped 95% CLs.
	# Includes correction for one-tailed comparisions.
	# 
	# Parameters:
	# 		1. f					focal vector
	# 		2. b				benchmark vector
	#		3. xs					Vector of x values for generating predicted probabilities
	#									[Default=0 -> highest value of f, b, plus 10]
	#		4. boot.reps		Number of bootstap replicates [Default=1000]
	#		5. seed				Randomization seed for fixed results [Default=no seed]
	#		6. Standard optional arguments specific to fitdistr():
	#			(a) nbin: no additional arguments needed
	# 			(b) beta: shape1 & shape2 (starting parameters ), lowlim (lower limit)
	#			(c) gamma: shape & rate (starting parameters ), lowlim (lower limit)
	#
	# Returns list object:
	#		1. Observed ol
	#		2. Lower and upper 95% CLs for observed ol
	#		3. Saved x values (xs)
	#		4. pdf.f: Fitted focal pdf 
	#		5. pdf.b: Fitted benchmark pdf
	#		6. Bootrapped prob density function values for pdf.f
	#		7. Bootrapped prob density function values for pdf.b
	#		8. Bootstrapped ol values
	#
	#  Optional arguments (...):
	# 		left: left limit. Typical values: -Inf, 0
	# 		right: right limit; typical value: Inf
	#
	# Requires custom functions:
	#		1. q.overlap()
	#		2. q.inverse.logit()
	#		3. 
	###################################################
	
	# Set default values for optional parameters & check for errors
	# Set default values for optional parameters & check for errors
	if (is.null(test.tail)) test.tail <- "both"
	if (is.null(xs)) xs <- seq(0,1, length.out= 100)
	if (is.null(boot.reps)) 	boot.reps <- 1000
	if (is.null(perm.reps)) 	perm.reps <- 10000
	if ( (set.seed==T) && !(is.null(seed)) ) set.seed(seed)
	if ( is.null(right) )	right <- Inf
	if ( is.null(left) )		left <- 0
	
	# Compose fitdistr optional arguments
	opt.args <- ""
	if ( !distn=='tnorm' ) {
		stop( paste0( "ERROR: wrong function for distribution '", dist, "'!"))
	} else {
		densfun <- "tnorm"

		# Predicted pdf parameters
		predfun <- "tnorm"
		predpar1 <- "mean"
		predpar2 <- "sd"	

		# Upper and lower bounds, rate, shape
		opt.args <- paste0(", ",
			"lower = c(", lowlim, ", ",  lowlim, "), ",
			"upper = c(", uplim, ", ",  uplim, "), ",
			"start=list(shape=", shape, ", rate=", rate, ")" 
		)
		# Alternate args if fails: lower bounds, rate, shape, but no upper bounds
		opt.args.no.ub <- paste0(", ",
			"lower = c(", lowlim, ", ",  lowlim, "), ",
			"start=list(shape=", shape, ", rate=", rate, ")" 
		)
	}
	
	# Construct the final commands
	fit.f <- paste0("fitdistr(f, densfun='", densfun, "'", opt.args, ")")
	fit.b <- paste0("fitdistr(b, densfun='", densfun, "'", opt.args, ")")
	
	pdf <- paste0(predfun, "(xs, ", predpar1, "= mod$estimate[1], ", predpar2, "= mod$estimate[2])")

	fit.boot <- paste0("fitdistr(boot.samp, densfun='", densfun, "'", opt.args, ")")
	
	# Get benchmark mean for one-tail overlap
	b.mean <- mean(b, na.rm=T)

	# ################################
	# # Transformations
	# ################################
	
	# if (distn=='gamma') {
		# # Set zeros to very small value > 1 to avoid crash
		# f[ f==0 ] <- 0.0000001
		# b[b==0 ] <- 0.0000001
	# }
	
	##############################
	# Fit actual pdfs & calculate overlap
	##############################
	
	################
	# Focal pdf
	################

	# Note use of eval(parse(...)) to force evaluation of string as command
	mod <- tryCatch( eval(parse(text=fit.f)),
					error = function(cond) { return("FAIL") },
					warning = function(cond) {return("FAIL") }
				)
	if ( mod[1]=='FAIL' && distn=='NBin' )	{
		# Fix for special case of NBin only
		# Adds explicit lower bound to avoid negative value errors
		
		if ( min(unique(f))>=1 ) {
			fit.f <- paste0("fitdistr(f, densfun='", densfun, "'", opt.args.nbin.lb1, ")")
		} else {	
			fit.f <- paste0("fitdistr(f, densfun='", densfun, "'", opt.args.nbin.lb0, ")")
		}
		
		# Try again
		mod <- tryCatch( eval(parse(text= fit.f)),
			error = function(cond) { return("FAIL") },
			warning = function(cond) { return("FAIL") }
		)
	}	else if ( mod[1]=='FAIL' && distn=='gamma' )	{
		# Fix for gamma: remove upper bounds
		fit.f <- paste0("fitdistr(f, densfun='", densfun, "'", opt.args.no.ub, ")")
		
		cat("f failed (tnorm): Using opt.args.no.ub\n")
		
		# Try again
		mod <- tryCatch( eval(parse(text= fit.f)),
			error = function(cond) { return("FAIL") },
			warning = function(cond) { return("FAIL") }
		)
		
		mod.str <- unlist(mod, use.names = FALSE)
		print( paste("f mod (take 2):\n", mod.str, "\n", sep=""))
		cat( "f (take 2):\n")
		print(f)
		cat( "b:\n")
		print(b)
	}	

	if ( mod[1]=='FAIL' ) return( list( 'FAIL' ) )
	pdf.f <- eval(parse(text= pdf))
	pdf.f[pdf.f==Inf] <- NA
		
	################
	# Benchmark pdf
	################

	mod <- tryCatch( eval(parse(text= fit.b)),
					error = function(cond) { return("FAIL") },
					warning = function(cond) { return("FAIL") }
				)

	if ( mod[1]=='FAIL' && distn=='NBin' )	{
		
		if ( min(unique(b))>=1 ) {
			fit.b <- paste0("fitdistr(b, densfun='", densfun, "'", opt.args.nbin.lb1, ")")
		} else {	
			fit.b <- paste0("fitdistr(b, densfun='", densfun, "'", opt.args.nbin.lb0, ")")			
		}
			
		# Try again
		mod <- tryCatch( eval(parse(text= fit.b)),
			error = function(cond) { return("FAIL") },
			warning = function(cond) { return("FAIL") }
		)
	}	else if ( mod[1]=='FAIL' && distn=='gamma' )	{
		fit.b <- paste0("fitdistr(b, densfun='", densfun, "'", opt.args.no.ub, ")")
		
		cat("b failed (gamma): Using opt.args.no.ub\n")
		
		
		# Try again
		mod <- tryCatch( eval(parse(text= fit.b)),
			error = function(cond) { return("FAIL") },
			warning = function(cond) { return("FAIL") }
		)
	}	

	if ( mod[1]=='FAIL' ) return( list( 'FAIL' ) )
	pdf.b <- eval(parse(text= pdf))
	pdf.b[pdf.b==Inf] <- NA

	################
	# Overlap
	################
	
	ol <- q.overlap(pdf.f=pdf.f, pdf.b=pdf.b, xs=xs, b.mean=b.mean, test.tail=test.tail)
	q <- ol
	
	# Transform indicator quality if required (see global params file
	q.raw <- q		# Save original value, even if don't change
	if ( q.tr.logit.inverse==TRUE ) {
		q <- q.inverse.logit(q, logit.inverse.beta)
	}
	
	##############################
	# Fit bootstrap pdfs & calculate overlaps
	##############################
	
	################
	# Focal bootstrapped
	# pdfs
	################

	boot.pdf.f <- sapply(1: boot.reps, function(i) {
		boot.samp <- sample(f, length(f), replace =T )
		mod <- tryCatch( eval(parse(text= fit.boot)),
					error = function(cond) { return("FAIL") },
					warning = function(cond) { return("FAIL") }
				)
		# Fix for special case of NBin only
		# Adds explicit lower bound to avoid negative value errors
		if ( mod[1]=='FAIL' && distn=='NBin' ) {	
			
			if ( min(unique(f) )>=1 ) {
				fit.boot <- paste0("fitdistr(boot.samp, densfun='", 
					densfun, "'", opt.args.nbin.lb1, ")")
			} else {	
				fit.boot <- paste0("fitdistr(boot.samp, densfun='", 
					densfun, "'", opt.args.nbin.lb0, ")")
			}
			
			# Try again
			mod <- tryCatch( eval(parse(text= fit.boot)),
				error = function(cond) { return("FAIL") },
				warning = function(cond) { return("FAIL") }
			)
		}
			
		if ( mod[1]=='FAIL'  ) {
			rep(NA,  length(xs))
		} else {
			eval( parse( text= pdf ) )
		}
	} )
	boot.pdf.f[boot.pdf.f ==Inf] <- NA
	
	################
	# Benchmark 
	# bootstrapped pdfs
	################

	boot.pdf.b <- sapply(1: boot.reps, function(i) {
		boot.samp <- sample(b, length(b), replace =T )
		mod <- tryCatch( eval(parse(text= fit.boot)),
					error = function(cond) { return("FAIL") },
					warning = function(cond) { return("FAIL") }
				)
		# Fix for special case of NBin only
		# Adds explicit lower bound to avoid negative value errors
		if ( mod[1]=='FAIL' && distn=='NBin' ) {	
			
			if ( min(unique(b))>=1 ) {
				fit.boot <- paste0("fitdistr(boot.samp, densfun='", 
					densfun, "'", opt.args.nbin.lb1, ")")
			} else {	
				fit.boot <- paste0("fitdistr(boot.samp, densfun='", 
					densfun, "'", opt.args.nbin.lb0, ")")
			}
			
			# Try again
			mod <- tryCatch( eval(parse(text= fit.boot)),
				error = function(cond) { return("FAIL") },
				warning = function(cond) { return("FAIL") }
			)
		}	
		if ( mod[1]=='FAIL'  ) {
			# Length of failed vector must match length of successful
			# vector, which is xs +1 (pdf mean plus the x values, see below)
			rep(NA,  length(xs) + 1)
		} else {
			# Get expected values (mean of x) for pdf
			if (distn=="NBin") {
				curr.b.mean <- mod$estimate[[2]]		
			} else if (distn=="gamma") {
				curr.b.mean <- mod$estimate[[1]] / mod$estimate[[2]]	
			} else {
				stop(paste0("ERROR in function boot.overlap.diff: Not supported for distribution ", distn))
			}
			curr.boot.pdf <- eval( parse( text= pdf ) )
			curr.boot.pdf[curr.boot.pdf==Inf]<-NA
			# append b.mean to front of bootstrap vector
			curr.boot.pdf <- as.vector( c(curr.b.mean, curr.boot.pdf)	)	
			curr.boot.pdf
		}		
	} )
	boot.pdf.b[boot.pdf.b==Inf] <- NA
	
	################
	# Overlap of 
	# bootstrapped pdfs
	################

	# Create vector of bootstrapped overlap values
	boot.ol <- rep(NA, boot.reps)
	for (i in 1: boot.reps) {
		curr.pdf.f <- boot.pdf.f[ , i]
		curr.b.mean <- boot.pdf.b[ , i][1]											# first element=mean
		curr.pdf.b <- boot.pdf.b[ , i ][ 2-length(boot.pdf.b[ , i]) ]	# remaining elements=the pdf
		boot.ol[i] <- q.overlap(pdf.f=curr.pdf.f, pdf.b=curr.pdf.b, xs=xs, b.mean=curr.b.mean, test.tail= test.tail)
	}
	boot.q <- boot.ol
	
	# Transform bootstrapped quality (overlap) if requested
	if ( q.tr.logit.inverse==TRUE ) {
		boot.q <- q.inverse.logit(boot.q, logit.inverse.beta)
	}
	
	##############################
	# Estimate 95% CLs of actual overlap
	# based on bootstrap deviations
	##############################
	
	# Get 95% CLs of the overlaps of the bootstrapped distributions 
	# using empirical bootstrap method. Uses bootstrap deviations from
	# bootstrap mean, and adds/subtracts these from observed value
	boot.q.mean <- mean(boot.q, na.rm=T)
	boot.q.dev <- boot.q - boot.q.mean			# Deviations from bootstrap mean
	q.dev <- q + boot.q.dev
	q.sd <- sd(q.dev)											# Bootstrap SD
	q.cls <- quantile(q.dev, c(0.025, 0.975), na.rm=T)
	q.cls
	q.lcl <- q.cls[[1]]
	q.ucl <- q.cls[[2]]
	
	##############################
	# Assemble list of all objects & return
	##############################

	ol.list <- list(ol, q.raw, q, q.cls, q.lcl, q.ucl, q.sd,
		xs, pdf.f, pdf.b, boot.pdf.f, boot.pdf.b, boot.q)
	names(ol.list) <- c('ol', 'q.raw', 'q', 'q.cls', 'q.lcl', 'q.ucl', 'q.sd',
		'xs', 'pdf.f', 'pdf.b', 'boot.pdf.f', 'boot.pdf.b', 'boot.q')
	
	return(ol.list)
	
}

