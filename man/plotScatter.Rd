% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotScatter.R
\name{plotScatter}
\alias{plotScatter}
\title{Scatter plot}
\usage{
plotScatter(
  Y,
  xy,
  design = NULL,
  color = NULL,
  shape = NULL,
  points_labs = NULL,
  title = "Scatter plot",
  xlab = NULL,
  ylab = NULL,
  size = 2,
  size_lab = 3,
  drawShapes = c("none", "ellipse", "polygon", "segment"),
  typeEl = c("norm", "t", "euclid"),
  levelEl = 0.9,
  alphaPoly = 0.4,
  theme = theme_bw()
)
}
\arguments{
\item{Y}{A nxm matrix with n observations and m variables.}

\item{xy}{x- and y-axis values: a vector of length 2 with either the column name(s) of the Y matrix to plot (character) or the index position(s).}

\item{design}{A nxk "free encoded" experimental design data frame.}

\item{color}{If not \code{NULL}, a character string giving the column name of \code{design} to be used as color.}

\item{shape}{If not \code{NULL}, a character string giving the column name of \code{design} to be used as shape.}

\item{points_labs}{If not \code{NULL}, a character vector with point labels.}

\item{title}{Plot title.}

\item{xlab}{If not \code{NULL}, label for the x-axis.}

\item{ylab}{If not \code{NULL}, label for the y-axis.}

\item{size}{The points size.}

\item{size_lab}{The size of points labels.}

\item{drawShapes}{Multiple shapes can be drawn based on the \code{color}: "none" for non shape (default), "ellipse" (ellipses with ggplot2::stat_ellipse), "polygon" (polygons with ggplot2::geom_polygon) or "segment" (segment from the centroids with ggplot2::geom_segment).}

\item{typeEl}{The type of ellipse, either \code{norm} (multivariate normal distribution), \code{t} (multivariate t-distribution) or \code{euclid} (draws a circle with the radius equal to level, representing the euclidean distance from the center).}

\item{levelEl}{The confidence level at which to draw an ellipse.}

\item{alphaPoly}{The degree of transparency for polygons.}

\item{theme}{ggplot theme, see \code{?ggtheme} for more info.}
}
\value{
A scatter plot (ggplot).
}
\description{
Produces a plot describing the relationship between two columns of the outcomes matrix \code{Y}. It allows to chose colors and markers for the levels of the design factors. Ellipses, polygones or segments can be added to group sets of points on the graph.
}
\examples{

data("UCH")

# Without design
plotScatter(Y = UCH$outcomes, xy = c(453, 369))

# With color and shape
plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), color = "Hippurate",
            shape = "Citrate")

# With color and drawShapes
plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), color = "Hippurate",
            drawShapes = "ellipse")

plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), color = "Hippurate",
            drawShapes = "polygon")

plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), color = "Hippurate",
            drawShapes = "segment")

# Customize shapes
library(ggplot2)
plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), shape = "Hippurate", size = 3) +
  scale_discrete_identity(aesthetics = 'shape',
                          guide = 'legend')

plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), shape = "Hippurate") +
  scale_shape_discrete(solid=FALSE)

plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), shape = "Hippurate") +
  scale_shape_manual(values = c(15,16,17))

# With labels
plotScatter(Y = UCH$outcomes, design = UCH$design,
            xy = c(453, 369), points_labs = rownames(UCH$design))

}
