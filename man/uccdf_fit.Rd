\name{uccdf_fit}
\alias{print.uccdf_fit}
\alias{plot.uccdf_fit}
\title{Methods for uccdf Fit Objects}
\usage{
\method{print}{uccdf_fit}(x, ...)

\method{plot}{uccdf_fit}(x, type = c("selection", "confidence"), ...)
}
\arguments{
  \item{x}{A fitted \code{uccdf_fit} object.}

  \item{type}{Plot type.}

  \item{...}{Additional arguments passed to the underlying graphics function.}
}
\description{
Prints a short summary or plots either the K-selection curve or the confidence
distribution for a \code{uccdf_fit} object.
}
