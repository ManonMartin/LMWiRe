#' @export pcaLoading1dPlot
#' @title Loadings represented on a line plot.
#'
#' @description
#' Plots the loadings from \code{\link{pcaBySvd}} with line plots.
#'
#' @param resPcaBySvd A list corresponding to the output value of \code{\link{pcaBySvd}}.
#' @param axes A numerical vector with the Principal Components axes to be drawn.
#' @param title Plot title.
#' @param ... Additional arguments to be passed to \code{\link{plotLine}}.
#'
#' @return A `ggplot` object with the PCA loading plot.
#'
#' @details
#' `pcaLoading1dPlot` is a wrapper of \code{\link{plotLine}}.
#'
#'
#' @examples
#'
#' data('UCH')
#' ResPCA = pcaBySvd(UCH$outcomes)
#'
#' pcaLoading1dPlot(resPcaBySvd = ResPCA, axes = c(1,2),
#' title = "PCA loading plot UCH", xlab = "ppm", ylab = "Values")

pcaLoading1dPlot <- function(resPcaBySvd, axes = c(1,2),
                         title = "PCA loading plot", ...) {

  # checks   ===================
  checkArg(resPcaBySvd,c("list"),can.be.null = FALSE)
  checkArg(axes,c("int","pos"),can.be.null = FALSE)
  checkArg(title,c("str", "length1"),can.be.null = FALSE)

  if (!identical(names(resPcaBySvd),c("scores","loadings","eigval","singvar",
                                      "var","cumvar","original.dataset"))){
    stop("resPcaBySvd is not an output value of pcaBySvd")}

  # loadings
  loadings <- t(resPcaBySvd$loadings)
  checkArg(loadings,c("matrix"),can.be.null = FALSE)

  if (max(axes) > nrow(loadings)){
    stop(paste0("axes (",paste0(axes, collapse = ",")
                ,") is beyond the ncol of loadings (",nrow(loadings),")"))
  }

  # percentage of explained variance   ===================
  pc_var <- resPcaBySvd$var
  pc_var_x <- format(pc_var[pc_var>=0.1],digits = 2, trim=TRUE)
  pc_var_y <- format(pc_var[pc_var<0.1],digits = 2,
                     scientific = TRUE, trim=TRUE)
  pc_var_char <- as.character(pc_var)
  pc_var_char[pc_var>=0.1] <- pc_var_x
  pc_var_char[pc_var<0.1] <- pc_var_y

  pc_var_char <- paste0("PC", axes, " (",pc_var_char[axes], "%)")

  # Loadings plot  ===================
  fig <- plotLine(Y = loadings, title = title,
                  rows = axes, facet_label = pc_var_char,
                  ...)

  return(fig)

}
