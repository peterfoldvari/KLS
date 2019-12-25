# kls version 1.0
This a stata ado file to perform the Kinky Least Squares (KLS) estimator by professor J. F. Kiviet.
The current version only reports analytical standard errors, based on the assumption of normality of the error term and homoscedasticity.
I am working on an updated version.

## kls.ado
Contains the code for the KLS estimator, which returns a standard regression table. You can use prefixes such as xi or bootstrap and kls is byable. Only analytical standard errors are reported, that are cvalid under homoscedasticity and normality of the residual. When heteroscedasticity is present, I suggest using the bootstrap prefix. Unfortunately there is no block bootstrap in stata, so in case of time series model one needs to make sure that the error-term does not have autocorrelation.

## kls2.ado 
This code is for a grid-based inference by the KLS estimator. In short, this code estimates the coefficents by KLS on a grid of assumed correlations between the first explanatory variable and the error-term. The minimum and maximum values of the correlation is supplied by the user, and the number of steps can be changed as well. The code automatically creates a summary table, saves the results in a dta.file, and finally, it plots the coefficient with 95% confidence intervals. This code only works with a single endogenous variable and requires kls.ado to function.
