% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lmwScoreScatterPlotM.R
\name{lmwScoreScatterPlotM}
\alias{lmwScoreScatterPlotM}
\title{Score scatter plot matrix}
\usage{
lmwScoreScatterPlotM(
  resLmwPcaEffects,
  effectNames = NULL,
  PCdim = NULL,
  modelAbbrev = FALSE,
  ...
)
}
\arguments{
\item{resLmwPcaEffects}{A list corresponding to the output value of \code{\link{lmwPcaEffects}}.}

\item{effectNames}{A character vector with the name of the effects to plot.}

\item{PCdim}{A numeric vector with the same length than effectNames and indicating the number of component to plot.}

\item{modelAbbrev}{A logical whether to abbreviate the interaction terms or not.}

\item{...}{Additional arguments to be passed to \code{\link{plotScatterM}}.}
}
\value{
A matrix of graphs
}
\description{
Plots the scores of all model effects simultaneously in a scatterplot matrix. By default, the first principal component only is kept for each model effect and, as a wrapper of \code{\link{plotScatterM}}, the choice markers and colors for factor levels allow to enrich the visualization of the factor effects on the responses.
}
\details{
\code{lmwScoreScatterPlotM} is a wrapper of \code{\link{plotScatterM}}.
}
\examples{

 data('UCH')
 resLmwModelMatrix = lmwModelMatrix(UCH)
 ResLmwEffectMatrices = lmwEffectMatrices(resLmwModelMatrix)
 resLmwPcaEffects = lmwPcaEffects(ResLmwEffectMatrices,method="ASCA-E")

 lmwScoreScatterPlotM(resLmwPcaEffects,
                 varname.colorup = "Citrate",
                 varname.pchup="Hippurate",
                 varname.pchdown = "Day",
                 varname.colordown="Time")

 # advanced setting
 lmwScoreScatterPlotM(resLmwPcaEffects,
                 modelAbbrev=FALSE,
                 effectNames = c("Citrate","Hippurate","Hippurate:Citrate"),
                 PCdim=c(2,2,2),
                 varname.colorup = "Citrate",
                 vec.colorup = c("red","blue","green"),
                 varname.pchup="Hippurate",
                 vec.pchup=c(1,2,3),
                 varname.pchdown = "Day",
                 vec.pchdown = c(4,5),
                 varname.colordown="Time",
                 vec.colordown = c("brown","grey"))

}
