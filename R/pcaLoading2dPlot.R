#' @export pcaLoading2dPlot
#' @title Loading plots on a 2D scatter plot
#'
#' @description
#' Produces loading plots from \code{\link{pcaBySvd}} with the same graphical options as \code{\link{plotScatter}}.
#'
#' @param resPcaBySvd A list corresponding to the output value of \code{\link{pcaBySvd}}.
#' @param axes A numerical vector with the 2 Principal Components axes to be drawn.
#' @param title Plot title.
#' @param points_labs_rn Boolean indicating if the rownames of the loadings matrix should be plotted.
#' @param pl_n The number of rownames that should be plotted, based on a distance measure (*see* details)
#' @param metadata A nxk "free encoded" data.frame corresponding to `design` in \code{\link{plotScatter}}.
#' @param ... Additional arguments to be passed to \code{\link{plotScatter}}.
#'
#' @return A `ggplot` object with the PCA loading plot.
#'
#' @details
#' `pcaLoading2dPlot` is a wrapper of \code{\link{plotScatter}}.
#'
#' The distance measure \eqn{d}{d} that is used to rank the variables is based on the following formula:
#' \deqn{d = \sqrt(P_{ab}^2*\lambda_{ab}^2)}{d = sqrt(P_ab^2 * lambda_ab^2)} where \eqn{a}{a}
#' and \eqn{b}{b} are two selected Principal Components, \eqn{P_{ab}}{P_ab} represents their
#' loadings and \eqn{\lambda_{ab}}{lambda_ab} their singular values.
#'
#' @examples
#'
#' data('UCH')
#' ResPCA = pcaBySvd(UCH$outcomes)
#'
#' # adding (arbitrary) color and shape to points
#' groups <- rep(c(1,2), length.out = ncol(UCH$outcomes))
#' metadata <- data.frame(groups)
#'
#' pcaLoading2dPlot(resPcaBySvd = ResPCA, axes = c(1,2),
#' title = "PCA loading plot UCH", metadata = metadata,
#' color = "groups", shape = "groups")
#'
#' pcaLoading2dPlot(resPcaBySvd = ResPCA, axes = c(1,2),
#' title = "PCA loading plot UCH", metadata = metadata,
#' color = "groups", shape = "groups", points_labs_rn = TRUE)
#'
#' pcaLoading2dPlot(resPcaBySvd = ResPCA, axes = c(1,2),
#' title = "PCA loading plot UCH", metadata = metadata,
#' color = "groups", shape = "groups", points_labs_rn = TRUE,
#' pl_n = 10)
#'
#' @import ggplot2

pcaLoading2dPlot <- function(resPcaBySvd, axes = c(1,2),
                         title = "PCA loading plot",
                         points_labs_rn = FALSE, pl_n = nrow(resPcaBySvd$loadings),
                           metadata = NULL, ...) {

  mcall = as.list(match.call())[-1L]

  # checks ===================
  checkArg(resPcaBySvd,c("list"),can.be.null = FALSE)
  checkArg(axes,c("int","pos"),can.be.null = FALSE)
  checkArg(title,c("str", "length1"),can.be.null = FALSE)
  checkArg(points_labs_rn,c("bool"),can.be.null = FALSE)
  checkArg(pl_n,c("int", "pos","length1"),can.be.null = FALSE)
  checkArg(metadata,"data.frame",can.be.null = TRUE)

  if (!identical(names(resPcaBySvd),c("scores","loadings","eigval","singvar",
                                      "var","cumvar","original.dataset"))){
    stop("resPcaBySvd is not an output value of pcaBySvd")}

  # loadings
  loadings <- resPcaBySvd$loadings
  checkArg(loadings,c("matrix"),can.be.null = FALSE)

  if (length(axes) !=2){
    stop("axes is not of length 2")
  }

  if (max(axes) > ncol(loadings)){
    stop(paste0("axes (",paste0(axes, collapse = ",")
                ,") is beyond the ncol of loadings (",ncol(loadings),")"))
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

  # distance measure   ===================

  load <- ResPCA$loadings[,axes]
  singvar <- ResPCA$singvar[axes]

  dista <- load^2%*%singvar^2

  points_labels <- rownames(loadings)

  ids <- order(dista, decreasing = TRUE)[1:pl_n]
  points_labels[-ids] <- ""

  # graphical parameters   ===================
  xlab <- pc_var_char[1]
  ylab <- pc_var_char[2]

  xlim1 <- max(abs(loadings[,axes[1]]))
  xlim_val <- c(-xlim1,xlim1)

  ylim1 <- max(abs(loadings[,axes[2]]))
  ylim_val <-  c(-ylim1,ylim1)

    if (points_labs_rn){
      if (!"xlab" %in% names(mcall)){
        if (!"ylab" %in% names(mcall)){
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, xlab = xlab, ylab = ylab,
                             points_labs = points_labels,
                             design = metadata,
                             ...)
        }else{
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, xlab = xlab,
                             points_labs = points_labels,
                             design = metadata,
                             ...)
        }
      }else{
        if (!"ylab" %in% names(mcall)){
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, ylab = ylab,
                             points_labs = points_labels,
                             design = metadata,
                             ...)
        }else{
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes,
                             points_labs = points_labels,
                             design = metadata,
                             ...)
        }
      }

    } else {
      if (!"xlab" %in% names(mcall)){
        if (!"ylab" %in% names(mcall)){
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, xlab = xlab, ylab = ylab,
                             design = metadata,...)
        }else{
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, xlab = xlab,
                             design = metadata,...)
        }
      }else{
        if (!"ylab" %in% names(mcall)){
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes, ylab = ylab,
                             design = metadata,...)
        }else{
          fig <- plotScatter(Y = loadings, title = title,
                             xy = axes,
                             design = metadata,...)
        }
      }

    }

  # loadings plot  ===================
  fig <- fig + ggplot2::xlim(xlim_val) + ggplot2::ylim(ylim_val)

  return(fig)

}
