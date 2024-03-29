#' @export lmwBootstrapTests
#' @title Performs a test on the effects from the model
#'
#' @description
#' Tests the significance of the effects from the model using bootstrap. This function is based on the outputs of \code{\link{lmwEffectMatrices}}. Tests on combined effects are also provided.
#'
#' @param resLmwEffectMatrices A list of 12 from \code{\link{lmwEffectMatrices}}.
#' @param nboot An integer with the number of iterations to perform.
#' @param nCores The number of cores to use for parallel execution.
#' @param verbose If \code{TRUE}, will display a message with the duration of execution.
#'
#' @return A list with the following elements:
#'  \describe{
#'    \item{\code{f.obs}}{A vector of size F with the F statistics calculated on the initial data for each model term.}
#'    \item{\code{f.boot}}{A b × F matrix with the F statistics calculated for the bootstrap samples.}
#'    \item{\code{p.values}}{A vector of size F with the p-value for each model effect.}
#'    \item{\code{resultsTable}}{A 2 × F matrix with the p-value and the variance percentage for each model effect.}
#'  }
#'
#' @examples
#'  data('UCH')
#'  resLmwModelMatrix <- lmwModelMatrix(UCH)
#'  resLmwEffectMatrices <- lmwEffectMatrices(resLmwModelMatrix = resLmwModelMatrix)
#'
#'  res <- lmwBootstrapTests(resLmwEffectMatrices = resLmwEffectMatrices, nboot=10, nCores=2, verbose = TRUE)
#'
#' @references
#' Thiel M.,Feraud B. and Govaerts B. (2017) \emph{ASCA+ and APCA+: Extensions of ASCA and APCA
#' in the analysis of unbalanced multifactorial designs}, Journal of Chemometrics
#'
#' @import doParallel
#' @import parallel
#' @importFrom plyr laply llply

lmwBootstrapTests = function(resLmwEffectMatrices,nboot=100,nCores=2, verbose = FALSE){

  # Checking the resLmwEffectMatrices list

  checkname = c("lmwDataList","modelMatrix","modelMatrixByEffect","effectsNamesUnique",
                "effectsNamesAll","effectMatrices",
                "predictedvalues","residuals","parameters",
                "type3SS","variationPercentages","varPercentagesPlot")


  if(!is.list(resLmwEffectMatrices)){stop("Argument resLmwEffectMatrices is not a list")}
  if(length(resLmwEffectMatrices)!=12){stop("List does not contain 12 arguments")}
  if(!all(names(resLmwEffectMatrices)==checkname)){stop("Argument is not a resLmwEffectMatrices object")}
  if(length(resLmwEffectMatrices$effectMatrices)!=length(resLmwEffectMatrices$effectsNamesUnique)){stop("Number of effect matrices differs from the number of effects")}

  # check if SS = TRUE

  if(all(is.na(resLmwEffectMatrices$type3SS)) & all(is.na(resLmwEffectMatrices$variationPercentages))){
    stop("lmwBootstrapTests can't be performed if resLmwEffectMatrices doesn't include the effect percentage variations (SS=FALSE)")
  }

  # Attributing names
  start_time = Sys.time()
  lmwDataList <- resLmwEffectMatrices$lmwDataList
  formula_complete = resLmwEffectMatrices$lmwDataList$formula
  outcomes = resLmwEffectMatrices$lmwDataList$outcomes
  modelMatrix = resLmwEffectMatrices$modelMatrix
  modelMatrixByEffect = resLmwEffectMatrices$modelMatrixByEffect
  effectsNamesAll = resLmwEffectMatrices$effectsNamesAll
  effectsNamesUnique = resLmwEffectMatrices$effectsNamesUnique
  nEffect <- length(effectsNamesUnique)
  SS_complete = resLmwEffectMatrices$type3SS
  SSE_complete = resLmwEffectMatrices$type3SS[which(names(SS_complete)=="Residuals")]
  nObs = nrow(outcomes)
  nParam = length(effectsNamesAll)

  # Recreate resLmwModelMatrix

  resLmwModelMatrix = resLmwEffectMatrices[1:6]

  # Parallel computing

  doParallel::registerDoParallel(cores=nCores)

  #### Estimating the partial model for each effect ####

  listResultPartial = list()
  Fobs = list()
  Pobs = list()

  partial_mod_fun <- function(iEffect){

    selection_tmp <- which(effectsNamesAll == effectsNamesUnique[iEffect])
    selectionall <- which(effectsNamesAll == effectsNamesUnique[iEffect])
    selectionComplement_tmp <- which(effectsNamesUnique != effectsNamesUnique[iEffect])
    selectionComplementall <- which(effectsNamesAll != effectsNamesUnique[iEffect])

    #Model matrices Partial

    modelMatrixPartial = modelMatrixByEffect[[selectionComplement_tmp[1]]]
    listModelMatrixByEffectPartial_temp = list()
    listModelMatrixByEffectPartial_temp[[1]] = modelMatrixByEffect[[selectionComplement_tmp[1]]]

    for(i in 2:length(selectionComplement_tmp)){

      # Create Model Matrix for the partial model
      modelMatrixPartial = cbind(modelMatrixPartial,
                                 modelMatrixByEffect[[selectionComplement_tmp[i]]])

      # Create listModelMatrixByEffectPartial
      listModelMatrixByEffectPartial_temp[[i]] = modelMatrixByEffect[[selectionComplement_tmp[i]]]
    }

    colnames(modelMatrixPartial) = colnames(modelMatrix[,selectionComplementall])

    # Be careful modelMatrixByEffect with 1 parameters have no colnames

    # Create effectsNamesAll

    effectsNamesUniquePartial = effectsNamesUnique[selectionComplement_tmp]
    effectsNamesAllPartial = effectsNamesAll[selectionComplementall]
    names(listModelMatrixByEffectPartial_temp)=effectsNamesUniquePartial

    # Create the partial formula

    temp=gsub(":","*",effectsNamesUniquePartial)
    temp = paste(temp,collapse="+")
    temp = paste0("outcomes~",temp)
    formula_temp = as.formula(temp)
    lmwDataList$formula <- as.formula(temp)

    # Create pseudo ResLMModelMatrix

    Pseudo_resLmwModelMatrix = list(lmwDataList=lmwDataList,
                                   modelMatrix=modelMatrixPartial,
                                   modelMatrixByEffect=listModelMatrixByEffectPartial_temp,
                                   effectsNamesUnique=effectsNamesUniquePartial,
                                   effectsNamesAll=effectsNamesAllPartial)

    # Compute the partial models

    listResultPartial = lmwEffectMatrices(Pseudo_resLmwModelMatrix,SS=TRUE)

    # Compute Fobs

    Fobs = (SS_complete[iEffect]/length(selection_tmp))/(SSE_complete/(nObs - nParam ))

    return(list(listResultPartial=listResultPartial, Fobs=Fobs))
  }

  res_partial_mod_fun <- plyr::llply(1:nEffect, partial_mod_fun, .parallel = TRUE)


  listResultPartial <- lapply(res_partial_mod_fun, function(x) x[["listResultPartial"]])
  Fobs <- lapply(res_partial_mod_fun[2:nEffect], function(x) x[["Fobs"]])

  # Formating the output
  names(listResultPartial) = effectsNamesUnique
  Fobs = unlist(Fobs)
  names(Fobs) = effectsNamesUnique[2:nEffect]

  #### Bootstrap #####

  ###  useful functions for ComputeFboot()

  # Compute the Sum of Squares Type 3
  # function based on LMSSv2()
  LMSSv2_bis <- function(Res,listcontrast){
    computeSS_bis = function(Xmat,L,coef){
      if(is.vector(L)){L=t(L)}
      LB = L %*% coef
      BL = t(LB)
      mat = BL %*% solve(L%*%solve(t(Xmat)%*%Xmat)%*%t(L)) %*% LB
      SS = sum(diag(mat))
      return(SS)
    }

    L = listcontrast

    Y_withoutIntercept = Res$outcomes - Res$Intercept
    denom = norm(x= data.matrix(Y_withoutIntercept),"F")^2

    result <- sapply(L, function(x) computeSS_bis(Xmat=Res$modelMatrix,L=x,
                                                  Res$parameters))

    result = c(result,((norm(x=Res$residuals,"F")^2)/denom)*100)
    #result = c(result,norm(x=Res$residuals,"F")^2)

    names(result) = c(Res$effectsNamesUnique,"Residuals")

    LMSS = list(SS=result)
    return(LMSS)
  }

  # Compute Fboot from Sum of Squares Type 3
  Fboot_fun <- function(i,result_boot, effect_names, npar,nObs){
    nume <- result_boot[[i]]$SS[which(names(result_boot[[i]]$SS)==effect_names[i])]/npar[[effect_names[i]]]
    denom <- result_boot[[i]]$SS[which(names(result_boot[[i]]$SS)=="Residuals")]/(nObs - nParam)
    Fboot = nume/denom
    return(Fboot)
  }

  ### ComputeFboot() function to compute the F statistic for every effect

  ComputeFboot <- function(E_sample, listResultPartial,
                           resLmwModelMatrix){

    effectsNamesAll = resLmwModelMatrix$effectsNamesAll
    effectsNamesUnique = resLmwModelMatrix$effectsNamesUnique
    nEffect <- length(effectsNamesUnique)

    # prepare  Res_list input argument for LMSSv2_bis --------------

    # Y_boot_list (simulated outcomes with partial models) for all the effects

    E_boot_list <- plyr::llply(listResultPartial[2:nEffect],
                               function(x) x$residuals[E_sample,],
                               .parallel = FALSE)

    Y_boot_list <- plyr::llply(1:length(E_boot_list),
                               function(i) {
                                 listResultPartial[2:nEffect][[i]]$predictedvalues +
                                   E_boot_list[[i]]}, .parallel = FALSE)

    names(Y_boot_list) <- names(E_boot_list)

    # # Find the number of parameters for each effect
    # npar <- plyr::llply(resLmwModelMatrix$modelMatrixByEffect, ncol,
    #                     .parallel = FALSE)

    # Estimate (X'X)-1X'

    X <- resLmwModelMatrix$modelMatrix
    XtX_1Xt <- solve(t(X)%*%X)%*%t(X)

    # Compute the parameters

    parameters_list <- plyr::llply(Y_boot_list, function(y) XtX_1Xt %*% y,
                                   .parallel = FALSE)


    # effectMatrices_list and intercept_list

    selection <- lapply(effectsNamesUnique,
                        function(x) which(effectsNamesAll == x))
    names(selection) <- effectsNamesUnique

    effectMatrices_list <- plyr::llply(parameters_list, function(y)
      lapply(selection, function(x)
        as.matrix(modelMatrix[, x]) %*% y[x,]),
      .parallel = FALSE)

    Intercept_list <- plyr::llply(effectMatrices_list, function(x) x[["Intercept"]],
                                  .parallel = FALSE)


    # residuals

    residuals_list <- plyr::llply(1:length(Y_boot_list),
                                  function(i) {
                                    Y_boot_list[[i]] -
                                      Reduce('+', effectMatrices_list[[i]])},
                                  .parallel = FALSE)

    names(residuals_list) <- names(Y_boot_list)


    # prepare  Res_list input arg for LMSSv2_bis

    Res <- list(outcomes = Y_boot_list,
                residuals = residuals_list ,
                Intercept = Intercept_list,
                modelMatrix = resLmwModelMatrix$modelMatrix,
                parameters = parameters_list)

    Res_list <- plyr::llply(1:length(Y_boot_list),
                            function(x) list(outcomes = Res$outcomes[[x]],
                                             residuals = Res$residuals[[x]],
                                             Intercept = Res$Intercept[[x]],
                                             modelMatrix = Res$modelMatrix,
                                             parameters = Res$parameters[[x]],
                                             effectsNamesUnique =
                                               effectsNamesUnique),
                            .parallel = FALSE)

    names(Res_list) <- names(Y_boot_list)

    # List of contrasts

    listcontrast <- contrastSS(resLmwModelMatrix)


    ### Compute the Sum of Squares Type 3 -----------

    result_boot <- lapply(Res_list,
                          function(x) LMSSv2_bis(Res = x,
                                                 listcontrast = listcontrast))

    effect_names <- names(result_boot)

    ### Compute Fboot from Sum of Squares Type 3 --------------

    # Find the number of parameters for each effect
    npar <- plyr::llply(resLmwModelMatrix$modelMatrixByEffect, ncol,
                        .parallel = FALSE)

    Fboot <- plyr::laply(1:length(effect_names),
                         function(x) Fboot_fun(x, result_boot,
                                               effect_names, npar,nObs),
                         .parallel = FALSE)

    return(Fboot)
  }


  # sample the observations for bootstrap

  E_sample = lapply(1:nboot, function(x) sample(c(1:nObs),nObs,replace=TRUE))

  # compute Fboot for simulated data
  Fboot <- plyr::laply(E_sample,
                       function(x) ComputeFboot(E_sample=x,
                                                listResultPartial=listResultPartial,
                                                resLmwModelMatrix=resLmwModelMatrix),
                       .parallel = TRUE)


  ###### Compute the boostrapped pvalue ######
  result = vector()
  matrix_temp = rbind(Fobs,Fboot)

  ComputePval = function(Effect,Fobs){
    result=1-sum(Effect[1]>Effect[2:(nboot+1)])/nboot
    return(result)
  }

  # Outputs generation
  result = apply(X=matrix_temp,FUN = ComputePval,MARGIN = 2)
  result = signif(result, digits = log10(nboot))
  colnames(Fboot) = names(Fobs)

  result <- replace(result, result == 0, paste0("< ", format(1/nboot, digits = 1, scientific = FALSE)))

  resultsTable_temp = rbind(result,
                       round(resLmwEffectMatrices$variationPercentages[1:length(Fobs)], 2))
  resultsTable = cbind(resultsTable_temp, c("-", round(resLmwEffectMatrices$variationPercentages[["Residuals"]],2)))
  rownames(resultsTable) = c("Bootstrap p-values", "% of variance (T III)")
  colnames(resultsTable) = c(resLmwEffectMatrices$effectsNamesUnique[-1],"Residuals")

  resLmwBootstrapTests = list(f.obs=Fobs,f.boot=Fboot,p.values=result,resultsTable=resultsTable)

  doParallel::stopImplicitCluster
  if (verbose){
    print(Sys.time() - start_time)
  }

  return(resLmwBootstrapTests)
  }
