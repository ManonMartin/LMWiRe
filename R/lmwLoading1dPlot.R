#' @export lmwLoading1dPlot
#' @title Loadings represented on a line plot.
#'
#' @description
#' Plots the loadings for each effect matrix from \code{\link{lmwPcaEffects}} outputs with line plots.
#'
#' @param resLmwPcaEffects A list corresponding to the output value of \code{\link{lmwPcaEffects}}.
#' @param effectNames Names of the effects to be plotted. if `NULL`, all the effects are plotted.
#' @param axes A numerical vector with the Principal Components axes to be drawn.
#' @param ... Additional arguments to be passed to \code{\link{plotLine}}.
#'
#' @return A list of `ggplot` objects representing the loading plots.
#'
#' @details
#' `lmwLoading1dPlot` is a wrapper of \code{\link{plotLine}}.
#'
#'
#' @examples
#'
#' data('UCH')
#' resLmwModelMatrix = lmwModelMatrix(UCH)
#' resLmwEffectMatrices = lmwEffectMatrices(resLmwModelMatrix)
#' resASCA = lmwPcaEffects(resLmwEffectMatrices)
#'
#' lmwLoading1dPlot(resASCA, effectNames = c("Hippurate", "Citrate"))


lmwLoading1dPlot <- function(resLmwPcaEffects, effectNames = NULL,
                           axes = c(1,2), ...) {

  # checks   ===================

  checkArg(resLmwPcaEffects,c("list"),can.be.null = FALSE)
  checkArg(effectNames,c("str"),can.be.null = TRUE)
  checkArg(axes,c("int","pos"),can.be.null = FALSE)

  if(!all(effectNames%in%names(resLmwPcaEffects))){stop("One of the effects from effectNames is not in resLmwPcaEffects.")}

  if (!identical(names(resLmwPcaEffects[(length(resLmwPcaEffects)-5):length(resLmwPcaEffects)]),
                 c("Residuals","lmwDataList","effectsNamesUnique","method","type3SS","variationPercentages"))){
    stop("resLmwPcaEffects is not an output value of lmwPcaEffects")}

  if(is.null(effectNames)){
    effectNames <- resLmwPcaEffects$effectsNamesUnique
    effectNames <- effectNames[effectNames != "Intercept"]
    effectNames <- c(effectNames, "Residuals")
  }



  # loadings

  loadings <- lapply(effectNames, function(x) t(resLmwPcaEffects[[x]][["loadings"]]))
  names(loadings) <- effectNames

  # percentage of explained variance   ===================

  pc_var_fun <- function(effect){

    pc_var <- resLmwPcaEffects[[effect]][["var"]]
    pc_var_x <- format(pc_var[pc_var>=0.1],digits = 2, trim=TRUE)
    pc_var_y <- format(pc_var[pc_var<0.1],digits = 2,
                       scientific = TRUE, trim=TRUE)
    pc_var_char <- as.character(pc_var)
    pc_var_char[pc_var>=0.1] <- pc_var_x
    pc_var_char[pc_var<0.1] <- pc_var_y

    pc_var_char <- paste0("PC", axes, " (",pc_var_char[axes], "%)")

    return(pc_var_char)

  }

  lab <- lapply(effectNames, pc_var_fun)
  names(lab) <- effectNames


  # Loadings plot  ===================

  buildFig <- function(effect){
    title = paste(effect, ": loading plot")

    plotLine(Y = loadings[[effect]], title = title, rows = axes, facet_label = lab[[effect]], ...)
  }

  fig <- lapply(effectNames, buildFig)
  names(fig) <- effectNames

  return(fig)

}
