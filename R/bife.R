#' @title
#' Binary Choice Models with Fixed Effects
#' 
#' @description
#' \code{bife} is used to fit fixed effects binary choice models (logit and probit) based on an unconditional likelihood approach.
#' It is tailored for the fast estimation of binary choice models with potentially many individual fixed effects.
#' The large dummy variable matrix is avoided by a special iteratively reweighted least squares demeaning algorithm (Stammann, Heiss, and McFadden, 2016).
#' The incidental parameter bias occuring in panels with shorter time horizons can be reduced by analytical 
#' bias-correction (Newey and Hahn, 2004). If no bias-correction is applied, the estimated coefficients will be identical 
#' to the ones obtained by \code{glm}. However, \code{bife} will compute faster than glm, if the model exhibits many fixed effects.
#' 
#' \strong{Remark:} The term fixed effect is used in econometrician`s sense of having a time-constant dummy for each individual. 
#' All other parameters in the model are referred to as structural parameters.
#' 
#' @param 
#' formula an object of class \code{"formula"} (or one that can be coerced to that class): a symbolic description of the model to be fitted.
#' \code{formula} must be of type \eqn{y ~ x | id} where the \code{id} refers to an individual identifier (fixed effects).
#'
#' @param 
#' data an optional data frame, list or environment (or object coercible by \code{as.data.frame} to a data frame) containing the variables in the model.
#' 
#' @param 
#' beta_start an optional vector of starting values used for the structural parameters in the demeaning algorithm. Default is zero for 
#' all structural parameters.
#' 
#' @param 
#' model the description of the error distribution and link function to be used in the model. For \code{bife} this has to be a character string
#' naming the model function. The value should be any of \code{"logit"} or \code{"probit"}. Default is \code{"logit"}.
#' 
#' @param 
#' bias_corr an optional string that specifies the type of the bias-correction: no bias-correction or analytical. The value should 
#' be any of \code{"no"} or \code{"ana"}. Default is \code{"ana"} (analytical).
#' 
#' @param 
#' iter_demeaning an optional integer value that specifies the maximum number of iterations of the demeaning algorithm. Default is \code{100}. 
#' Details are given under \code{Details}.
#' 
#' @param 
#' tol_demeaning an optional number that specifies the tolerance level of the demeaning algorithm. Default is \code{1e-5}. Details are given 
#' under \code{Details}.
#' 
#' @param 
#' iter_offset an optional integer value that specifies the maximum number of iterations of the offset algorithm for the computation of 
#' bias-adjusted fixed effects. Default is \code{1000}. Details are given under \code{Details}.
#' 
#' @param 
#' tol_offset an optional number that specifies the tolerance level of the offset algorithm for the computation of bias-adjusted fixed effects.
#' Default is \code{1e-5}. Details are given under \code{Details}.
#' 
#' @details 
#' A typical predictor has the form \eqn{response ~ terms | id} where response is the binary response vector (0-1 coded), terms is a series of terms
#' which specifies a linear predictor for the response, and refers to an individual identifier. The linear predictor must not include any constant regressors due to the perfect collinearity
#' with the fixed effects. Since individuals with a non-varying response do not contribute to the log likelihood they are dropped from the estimation
#' procedure (unlike \code{glm}). The analytical bias-correction follows Newey and Hahn (2004).
#' 
#' Details for iter_demeaning and tol_demeaning: A special iteratively reweighted least squares demeaning algorithm is used following 
#' Stammann, A., F. Heiss, and D. McFadden (2016). The stopping criterion is defined as \eqn{||b(i) - b(i - 1)|| < tol_demeaning}. 
#' 
#' Details for iter_offset and tol_offset: The bias-adjusted fixed effects are computed via an iteratively reweighted least (IWLS) squares
#' algorithm efficiently tailored to sparse data. The algorithm includes the bias-corrected structural parameters in the linear predictor during 
#' fitting. The stopping criterion in the IWLS algorithm is defined as \eqn{any(|b(i) - b(i - 1)| / |b(i - 1)|) < tol_offset}.
#' 
#' @return An object of class \code{bife} is a list containing the following components:
#'  \item{par}{}
#'   \item{$beta}{a vector of the uncorrected structural parameters}
#'   \item{$alpha}{a vector of the uncorrected fixed effects}
#'   \item{$se_beta}{a vector of the standard errors of the uncorrected structural parameters}
#'   \item{$se_alpha}{a vector of the standard errors of the uncorrected fixed effects}
#'   \item{$beta_vcov}{a matrix of the covariance matrix of the uncorrected structural parameters}
#'   \item{$avg_alpha}{the average of the uncorrected fixed effects}
#'  \item{par_corr}{}  
#'   \item{$beta}{a vector of the bias-corrected structural parameters}
#'   \item{$alpha}{a vector of the bias-adjusted fixed effects}
#'   \item{$se_beta}{a vector of the standard errors of the bias-corrected structural parameters}
#'   \item{$se_alpha}{a vector of the standard errors of the bias-adjusted fixed effects}
#'   \item{$beta_vcov}{a matrix of the covariance matrix of the bias-corrected structural parameters}
#'   \item{$avg_alpha}{the average of the bias-adjusted fixed effects}
#'  \item{logl_info}{}
#'   \item{$nobs}{number of observations}  
#'   \item{$k}{number of loglikelihood parameters}
#'   \item{$loglik}{the log likelihood value given the uncorrected parameters}
#'   \item{$events}{number of events}
#'   \item{$iter_demeaning}{the number of iterations of the demeaning algorithm}
#'   \item{$conv_demeaning}{a logical value indicating convergence of the demeaning algorithm}
#'   \item{$loklik_corr}{the log likelihood given the bias-corrected/-adjusted parameters}
#'   \item{$iter_offset}{the number of iterations of the offset algorithm}
#'   \item{$conv_offset}{a logical value indicating convergence of the offset algorithm}
#'  \item{model_info}{}
#'   \item{$used_ids}{a vector of the retained ids during fitting}
#'   \item{$y}{the response vector given $used.ids}
#'   \item{$beta_start}{a vector of used starting values}
#'   \item{$X}{the model matrix given $used.ids}
#'   \item{$id}{a vector of the individual identifier given $used.ids}
#'   \item{$t}{a vector of the time identifier given $used.ids}
#'   \item{$drop_pc}{number of individuals dropped during fitting due to non-varying response (perfect classification)}
#'   \item{$drop_NA}{number of individuals dropped due to missing values}
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
#' dataset <- psid
#' head(dataset)
#' 
#' # Fixed effects logit model w/o bias-correction
#' mod_no <- bife(LFP ~ AGE + I(INCH / 1000) + KID1 + KID2 + KID3 | ID, 
#'  data = dataset, bias_corr = "no")
#' 
#' # Summary of uncorrected structural parameters only        
#' summary(mod_no)
#' 
#' # Summary plus fixed effects
#' summary(mod_no, fixed = TRUE)
#' 
#' # Fixed effects logit model with analytical bias-correction
#' mod_ana <- bife(LFP ~ AGE + I(INCH / 1000) + KID1 + KID2 + KID3 | ID,
#'  data = dataset)
#'                
#' # Summary of bias-corrected structural parameters only
#' summary(mod_ana)
#' 
#' # Summary of uncorrected structural parameters only
#' summary(mod_ana, corrected = FALSE)
#' 
#' # Summary of bias-corrected structural parameters plus -adjusted
#' # fixed effects
#' summary(mod_ana, fixed = TRUE)
#' 
#' # Extract bias-corrected structural parameters of mod_ana
#' beta_ana <- coef(mod_ana)
#' print(beta_ana)
#' 
#' # Extract bias-adjusted fixed effects of mod_ana
#' alpha_ana <- coef(mod_ana, fixed = TRUE)
#' print(alpha_ana)
#' 
#' # Extract uncorrected structural parameters of mod_ana
#' beta_no <- coef(mod_ana, corrected = FALSE)
#' print(beta_no)
#' 
#' # Extract covariance matrix of bias-corrected structural
#' # parameters of mod_ana
#' vcov_ana <- vcov(mod_ana)
#' print(vcov_ana)
#' 
#' # Extract covariance matrix of uncorrected structural parameters
#' # of mod_ana
#' vcov_no <- vcov(mod_ana, corrected = FALSE)
#' print(vcov_no)
#' 
#' @importFrom
#' Formula Formula model.part
#' 
#' @importFrom
#' stats aggregate coef model.frame model.matrix model.response plogis pnorm
#' 
#' @useDynLib 
#' bife, .registration = TRUE 
#' 
#' @importFrom
#' Rcpp evalCpp
#' 
#' @export
bife <- function(formula, data = list(),
                 beta_start = NULL,
                 model = "logit", bias_corr = "ana",
                 iter_demeaning = 100L, tol_demeaning = 1.0e-05,
                 iter_offset = 1000L, tol_offset = 1.0e-05) {
 
 
  # Checking input arguments
  if(model != "logit" && model != "probit") {
    stop("'model' must be 'logit' or 'probit'.")
  }
  if(bias_corr != "no" && bias_corr != "ana") {
    stop("'bias_corr' must be 'no' or 'ana'.")
  }
  
  # Update formula and drop missing values
  formula <- Formula(formula)
  mf <- model.frame(formula = formula, data = data)
  if(ncol(model.part(formula, data = mf, rhs = 2L)) != 1L) {
    stop("'id' uncorrectly specified.")
  }
   
  # Ordering data
  mf <- mf[order(mf[[ncol(mf)]]), ]
   
  # Extract data
  # Ensures y is 0-1 encoded
  y <- as.integer(factor(model.response(mf))) - 1L
  # Changed (Version 0.5):
  # Users had some troubles using factor() variables. New code should be more in line with what
  # Users expect
  # Old:
  # X <- model.matrix(update(formula, . ~ . - 1), data = mf, rhs = 1)
  X <- model.matrix(formula, data = mf, rhs = 1L)[, - 1L, drop = FALSE]
  id <- model.part(formula, data = mf, rhs = 2L)[[1L]]
   
  # Perfectly classified: avg in {0,1}
  mean_table <- aggregate(y ~ id, FUN = mean)
  mean_y <- mean_table[, 2L]
  index_pc <- id %in% mean_table[(mean_y > 0.0 & mean_y < 1.0), 1L]
  
  # Store information
  nobs <- length(y)
  d <- ncol(X)
  events <- sum(y)
   
  # Drop perfectly classified
  y <- y[index_pc]
  X <- X[index_pc, , drop = FALSE]
  id <- id[index_pc]
   
  # Set starting values if needed and check dimension if specified
  if(is.null(beta_start)) {
    beta_start <- numeric(d)
  } else {
    if(length(beta_start) != d) {
      stop("'beta_start' must be of same dimension as the number of structural parameters.")
    }
  }
   
  # Map "model"
  switch(model, logit = model_int <- 0L, probit = model_int <- 1L)
   
  # Map "bias_corr"
  switch(bias_corr, no = bias_corr_int <- 0L, ana = bias_corr_int <- 1L)
   
  # Start algorithm
  result <- .bife(y = y, X = X, id = id,
                  beta_start = beta_start,
                  model = model_int, bias_corr = bias_corr_int, 
                  iter_max1 = iter_demeaning, tolerance1 = tol_demeaning, 
                  iter_max2 = iter_offset, tolerance2 = tol_offset)
   
  # Complete list
  result[["logl_info"]][["nobs"]] <- nobs
  result[["logl_info"]][["k"]] <- d + length(mean_y)
  result[["logl_info"]][["events"]] <- events
  result[["model_info"]][["drop_NA"]] <- length(attr(mf, "na.action"))
  result[["model_info"]][["drop_pc"]] <- nobs - length(index_pc)
  result[["model_info"]][["formula"]] <- formula
  result[["model_info"]][["str_name"]] <- attr(X, "dimnames")[[2L]]
  result[["model_info"]][["model"]] <- model
  result[["model_info"]][["bias_corr"]] <- bias_corr
   
   
  # Return list
  return(structure(result, class = "bife"))
}