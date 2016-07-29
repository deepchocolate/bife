#' @title
#' Binary Choice Models with Fixed Effects
#' 
#' @description
#' \code{bife} is used to fit fixed effects binary choice models (logit and probit) based on an unconditional likelihood approach.
#' It is tailored for the fast estimation of binary choice models with potentially many individual fixed effects.
#' The large dummy variable trap is avoided by a special iteratively reweighted least squares demeaning algorithm (Stammann, Heiss, and McFadden, 2016).
#' The incidental parameter bias occuring in panels with shorter time horizons can be reduced by analytic or jackknife 
#' bias-correction (Newey and Hahn, 2004). If no bias-correction is applied, the estimated coefficients will be identical 
#' to the ones obtained by glm. However, \code{bife} will compute faster than glm, if the model exhibits many fixed effects.
#' 
#' \strong{Remark:} The term fixed effect is used in econometrician`s sense of having a time-constant dummy for each individual. 
#' All other parameters in the model are referred to as structural parameters.
#' 
#' @param 
#' formula an object of class \code{"formula"} (or one that can be coerced to that class): a symbolic description of the model to be fitted.
#' \code{formula} must be of type \eqn{y ~ x | id} where the \code{id} refers to an individual identifier.
#'
#' @param 
#' data an optional data frame, list or environment (or object coercible by \code{as.data.frame} to a data frame) containing the variables in the model.
#' 
#' @param 
#' beta.start an optional vector of starting values used for the structural parameters in the demeaning algorithm. Default is zero for 
#' all structural parameters.
#' 
#' @param 
#' model the description of the error distribution and link function to be used in the model. For \code{bife} this has to be a character string
#' naming the model function. The value should be any of \code{"logit"} or \code{"probit"}. Default is \code{"logit"}.
#' 
#' @param 
#' bias.corr an optional string that specifies the type of the bias-correction: no bias-correction, analytical, jackknife. The value should 
#' be any of \code{"no"}, \code{"ana"}, or \code{"jack"}. Default is \code{"ana"} (analytical).
#' 
#' @param 
#' iter.demeaning an optional integer value that specifies the maximum number of iterations of the demeaning algorithm. Default is \code{100}. 
#' Details are given under \code{Details}.
#' 
#' @param 
#' tol.demeaning an optional number that specifies the tolerance level of the demeaning algorithm. Default is \code{1e-5}. Details are given 
#' under \code{Details}.
#' 
#' @param 
#' iter.offset an optional integer value that specifies the maximum number of iterations of the offset algorithm for the computation of 
#' bias-adjusted fixed effects. Default is \code{1000}. Details are given under \code{Details}.
#' 
#' @param 
#' tol.offset an optional number that specifies the tolerance level of the offset algorithm for the computation of bias-adjusted fixed effects.
#' Default is \code{1e-5}. Details are given under \code{Details}.
#' 
#' @details 
#' A typical predictor has the form \eqn{response ~ terms | id} where response is the binary response vector (0-1 coded), terms is a series of terms
#' which specifies a linear predictor for the response, and refers to an individual identifier. The linear predictor must not include any constant regressors due to the perfect collinearity
#' with the fixed effects. Since individuals with a non-varying response do not contribute to the log likelihood they are dropped from the estimation
#' procedure (unlike glm). The analytical and jackknife bias-correction follow Newey and Hahn (2004).
#' 
#' Details for iter.demeaning and tol.demeaning: A special iteratively reweighted least squares demeaning algorithm is used following 
#' Stammann, A., F. Heiss, and D. McFadden (2016). The stopping criterion is defined as \eqn{||b(i) - b(i - 1)|| < tol.demeaning}. 
#' 
#' Details for iter.offset and tol.offset: The bias-adjusted fixed effects are computed via an iteratively reweighted least (IWLS) squares
#' algorithm efficiently tailored to sparse data. The algorithm includes the bias-corrected structural parameters in the linear predictor during 
#' fitting. The stopping criterion in the IWLS algorithm is defined as \eqn{any(|b(i) - b(i - 1)| / |b(i - 1)|) < tol.offset}.
#' 
#' @return An object of class \code{bife} is a list containing the following components:
#'  \item{par}{}
#'   \item{$beta}{a vector of the uncorrected structural parameters}
#'   \item{$alpha}{a vector of the uncorrected fixed effects}
#'   \item{$se.beta}{a vector of the standard errors of the uncorrected structural parameters}
#'   \item{$se.alpha}{a vector of the standard errors of the uncorrected fixed effects}
#'   \item{$beta.vcoc}{a matrix of the covariance matrix of the uncorrected structural parameters}
#'   \item{$avg.alpha}{the average of the uncorrected fixed effects}
#'  \item{par.corr}{}  
#'   \item{$beta}{a vector of the bias-corrected structural parameters}
#'   \item{$alpha}{a vector of the bias-adjusted fixed effects}
#'   \item{$se.beta}{a vector of the standard errors of the bias-corrected structural parameters}
#'   \item{$se.alpha}{a vector of the standard errors of the bias-adjusted fixed effects}
#'   \item{$beta.vcoc}{a matrix of the covariance matrix of the bias-corrected structural parameters}
#'   \item{$avg.alpha}{the average of the bias-adjusted fixed effects}
#'  \item{logl.info}{}
#'   \item{$nobs}{number of observations}  
#'   \item{$df}{degrees of freedom}
#'   \item{$loglik}{the log likelihood value given the uncorrected parameters}
#'   \item{$events}{number of events}
#'   \item{$iter.demeaning}{the number of iterations of the demeaning algorithm}
#'   \item{$conv.demeaning}{a logical value indicating convergence of the demeaning algorithm}
#'   \item{$loklik.corr}{the log likelihood given the bias-corrected/-adjusted parameters}
#'   \item{$iter.offset}{the number of iterations of the offset algorithm}
#'   \item{$conv.offset}{a logical value indicating convergence of the offset algorithm}
#'  \item{model.info}{}
#'   \item{$used.ids}{a vector of the retained ids during fitting}
#'   \item{$y}{the response vector given $used.ids}
#'   \item{$beta.start}{a vector of used starting values}
#'   \item{$X}{the model matrix given $used.ids}
#'   \item{$id}{a vector of the individual identifier given $used.ids}
#'   \item{$t}{a vector of the time identifier given $used.ids}
#'   \item{$drop.pc}{number of individuals dropped during fitting due to non-varying response (perfect classification)}
#'   \item{$drop.NA}{number of individuals dropped due to missing values}
#'   \item{...}{further objects passed to other methods in \code{bife}}
#' 
#' @author
#' Amrei Stammann, Daniel Czarnowske, Florian Heiss, Daniel McFadden
#' 
#' @references 
#' Hahn, J., and W. Newey (2004). "Jackknife and analytical bias reduction for nonlinear panel models". Econometrica 72(4), 1295-1319.
#' 
#' @references
#' Stammann, A., F. Heiss, and D. McFadden (2016). "Estimating Fixed Effects Logit Models with Large Panel Data". Working paper.
#'
#' @examples
#' library("bife")
#' 
#' # Load 'psid' dataset
#' data.set <- psid
#' head(data.set)
#' 
#' # Fixed effects logit model w/o bias-correction
#' mod.no <- bife(LFP ~ AGE + I(INCH / 1000) + KID1 + KID2 + KID3 | ID, 
#'  data = data.set, bias.corr = "no")
#' 
#' # Summary of uncorrected structural parameters only        
#' summary(mod.no)
#' 
#' # Summary plus fixed effects
#' summary(mod.no, fixed = TRUE)
#' 
#' # Fixed effects logit model with analytical bias-correction
#' mod.ana <- bife(LFP ~ AGE + I(INCH / 1000) + KID1 + KID2 + KID3 | ID,
#'  data = data.set)
#'                
#' # Summary of bias-corrected structural parameters only
#' summary(mod.ana)
#' 
#' # Summary of uncorrected structural parameters only
#' summary(mod.ana, corrected = FALSE)
#' 
#' # Summary of bias-corrected structural parameters plus -adjusted
#' # fixed effects
#' summary(mod.ana, fixed = TRUE)
#' 
#' # Extract bias-corrected structural parameters of mod.ana
#' beta.ana <- coef(mod.ana)
#' print(beta.ana)
#' 
#' # Extract bias-adjusted fixed effects of mod.ana
#' alpha.ana <- coef(mod.ana, fixed = TRUE)
#' print(alpha.ana)
#' 
#' # Extract uncorrected structural parameters of mod.ana
#' beta.no <- coef(mod.ana, corrected = FALSE)
#' print(beta.no)
#' 
#' # Extract covariance matrix of bias-corrected structural
#' # parameters of mod.ana
#' vcov.ana <- vcov(mod.ana)
#' print(vcov.ana)
#' 
#' # Extract covariance matrix of uncorrected structural parameters
#' # of mod.ana
#' vcov.no <- vcov(mod.ana, corrected = FALSE)
#' print(vcov.no)
#' 
#' @importFrom
#' Formula Formula model.part
#' 
#' @importFrom
#' stats model.frame model.response model.matrix update aggregate
#' 
#' @useDynLib 
#' bife
#' 
#' @importFrom
#' Rcpp evalCpp
#' 
#' @exportPattern
#' "^[[:alpha:]]+"


bife <- function(formula, data = list(),                       # Specify regression model
                 beta.start = NULL,                            # Starting values for beta
                 model = "logit", bias.corr = "ana",           # Model selection and type of bias correction
                 iter.demeaning = 100, tol.demeaning = 1e-5,   # Control parameters "pseudo demeaning"
                 iter.offset = 1000, tol.offset = 1e-5) {      # Control parameters "glm offset"
 
 
 # Checking input arguments
 if(model != "logit" && model != "probit") stop("'model' must be 'logit' or 'probit'")
 if(bias.corr != "no" && bias.corr != "ana" && bias.corr != "jack") stop("'bias.corr' must be 'no', 'ana', or 'jack'")
 
 # Update formula and drop missing values
 formula <- Formula(formula)
 mf <- model.frame(formula = formula, data = data)
 if(ncol(model.part(formula, data = mf, rhs = 2)) != 1) stop("'id' uncorrectly specified")
 drop.NA <- length(attr(mf, "na.action"))
 
 # Ordering data
 mf <- mf[order(mf[[ncol(mf)]]), ]
 
 # Extract data
 y <- model.response(mf)
 X <- model.matrix(update(formula, . ~ . - 1), data = mf, rhs = 1)
 id <- model.part(formula, data = mf, rhs = 2)[[1]]
 
 # Perfectly classified: avg in {0,1}
 mean.tab <- aggregate(y ~ id, FUN = mean)
 mean.y <- mean.tab[, 2]
 index.pc <- which(id %in% mean.tab[(mean.y > 0 & mean.y < 1), 1])
 drop.pc <- length(y) - length(index.pc)
 
 # Drop perfectly classified
 y <- y[index.pc]
 X <- X[index.pc, ]
 id <- id[index.pc]
 
 # Set starting values if needed and check dimension if specified
 if(is.null(beta.start)) {
  
  beta.start <- numeric(ncol(X))
 } else {
  
  if(length(beta.start) != ncol(X)) stop("'beta.start' must be of same dimension as the number of structural parameters")
 }
 
 # Map "model"
 switch(model,
        logit = model.int <- 0,
        probit = model.int <- 1)
 
 # Map "bias.corr"
 switch(bias.corr,
        no = bias.corr.int <- 0,
        ana = bias.corr.int <- 1,
        jack = bias.corr.int <- 2)
 
 # Start algorithm
 result <- .bife(y = y, X = X, id = id,
                 beta_start = beta.start,
                 model = model.int, bias_corr = bias.corr.int, 
                 iter_max1 = iter.demeaning, tolerance1 = tol.demeaning, 
                 iter_max2 = iter.offset, tolerance2 = tol.offset)
 
 # Complete list
 result$model.info$drop.NA  <- drop.NA
 result$model.info$drop.pc  <- drop.pc
 result$model.info$formula  <- formula
 result$model.info$str.name <- names(model.part(formula, data = mf, rhs = 1))
 result$model.info$model  <- model
 result$model.info$bias.corr  <- bias.corr
 
 
 # Return list
 return(structure(result, class = "bife"))
}