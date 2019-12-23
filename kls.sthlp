{smcl}
{* *! version 1.0 19 Dec 2019}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "kls##syntax"}{...}
{viewerjumpto "Description" "kls##description"}{...}
{viewerjumpto "Options" "kls##options"}{...}
{viewerjumpto "Remarks" "kls##remarks"}{...}
{viewerjumpto "Examples" "kls##examples"}{...}
{title:Title}
{phang}
{bf:kls} {hline 2} Kinky Least Squares estimator developed by Professor Jan F. Kiviet (2019), University of Amsterdam.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:kls}
varlist
(numeric
ts
fv
min=2)
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt endog(numlist)}} A list of assumed correlation coefficients between the explanatory variables and the error term. {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt endog(numlist)} A list of of assumed correlation coefficients between the explanatory variables and the error-term. Assign values in the order of the variables. 
    {p_end}


{marker examples}{...}
{title:Examples}

{title: 1. Cross sectional data}

Use built-in auto dataset:
.  sysuse auto.dta
(1978 Automobile Data)

OLS regression:

. reg price mpg weight foreign

      Source |       SS           df       MS      Number of obs   =        74
-------------+----------------------------------   F(3, 70)        =     23.29
       Model |   317252881         3   105750960   Prob > F        =    0.0000
    Residual |   317812515        70  4540178.78   R-squared       =    0.4996
-------------+----------------------------------   Adj R-squared   =    0.4781
       Total |   635065396        73  8699525.97   Root MSE        =    2130.8

------------------------------------------------------------------------------
       price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |    21.8536   74.22114     0.29   0.769    -126.1758     169.883
      weight |   3.464706    .630749     5.49   0.000     2.206717    4.722695
     foreign |    3673.06   683.9783     5.37   0.000     2308.909    5037.212
       _cons |  -5853.696   3376.987    -1.73   0.087    -12588.88    881.4934
------------------------------------------------------------------------------

KLS, assuming only exogenous regressors:

. kls price mpg weight foreign, endog(0)
                                  
KLS estimator
                                                Number of obs   =           74
                                                F-stat          =        23.29
                                                Prob > F        =       0.0000
                                                R-squared       =       0.4996
                                                Root MSE        =     2.13e+03
------------------------------------------------------------------------------
       price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |    21.8536   74.22114     0.29   0.769    -126.1758     169.883
      weight |   3.464706    .630749     5.49   0.000     2.206717    4.722695
     foreign |    3673.06   683.9783     5.37   0.000     2308.909    5037.212
------------------------------------------------------------------------------
assumed correlations =    0

KLS estimator assuming that mpg is endogenous with r_mpg=0.2, hence rho=(0.2 0 0):

. kls price mpg weight foreign, endog(0.2)
                                  
KLS estimator
                                                Number of obs   =           74
                                                F-stat          =        17.49
                                                Prob > F        =       0.0006
                                                R-squared       =       0.4284
                                                Root MSE        =     2.27e+03
------------------------------------------------------------------------------
       price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |  -212.3417   83.52784    -2.54   0.013    -378.9327   -45.75064
      weight |   1.921854   .7124195     2.70   0.009     .5009781     3.34273
     foreign |   3286.631   730.9541     4.50   0.000     1828.789    4744.473
------------------------------------------------------------------------------
assumed correlations =    .2

KLS with bootstrap standard errors.

. bs, rep(1000) nodots: kls price mpg weight foreign, endog(0.2)

Bootstrap results                               Number of obs     =         74
                                                Replications      =      1,000
                                                R-squared         =     0.4284
                                                Root MSE          =  2269.5902

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
       price |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |  -212.3417   114.5114    -1.85   0.064    -436.7798    12.09645
      weight |   1.921854   1.010179     1.90   0.057    -.0580607    3.901769
     foreign |   3286.631   734.7282     4.47   0.000     1846.591    4726.672
------------------------------------------------------------------------------


KLS with bootstrap biasec corrected standard errors.

. bs, rep(1000) nodots bca: kls price mpg weight foreign, endog(0.2)

Bootstrap results                               Number of obs     =         74
                                                Replications      =      1,000
                                                R-squared         =     0.4284
                                                Root MSE          =  2269.5902

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
       price |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |  -212.3417   110.4818    -1.92   0.055     -428.882    4.198654
      weight |   1.921854   .9964509     1.93   0.054    -.0311539    3.874862
     foreign |   3286.631   750.4866     4.38   0.000     1815.705    4757.558
------------------------------------------------------------------------------



KLS, assuming that both mpg and weight are endogenous: rho=(0.2 -0.5 0) 

. kls price mpg weight foreign, endog(0.2 -0.5)
                                  
KLS estimator
                                                Number of obs   =           74
                                                F-stat          =        -3.45
                                                Prob > F        =       1.0000
                                                R-squared       =      -0.1732
                                                Root MSE        =     3.21e+03
------------------------------------------------------------------------------
       price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |   423.6538   127.6151     3.32   0.001     169.1335    678.1742
      weight |   9.319203   1.056947     8.82   0.000     7.211188    11.42722
     foreign |   7547.394   1267.323     5.96   0.000     5019.798    10074.99
------------------------------------------------------------------------------
assumed correlations =    .2 -.5

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(r2)}}  R-squared {p_end}
{synopt:{cmd:e(F)}}  F-statistics of joint significance {p_end}
{synopt:{cmd:e(Fp)}}  p-value for the F-test {p_end}
{synopt:{cmd:e(rmse)}}  Root mean squared error, a.k.a. the standard error of the regression {p_end}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:e(cmdline)}}  command used 
  {p_end}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(rho)}} The vector of correlations assumed {p_end}

{marker s_refs}{title:References}

{p 0 4}Kiviet, Jan F. 2019. Testing the impossible:
identifying exclusion restrictions. Forthcoming in The Journal of Econometrics.


{title:Author} 
Peter Foldvari 
Amsterdam School of Economics 
University of Amsterdam, the Netherlands
e-mail: p.foldvari@uva.nl
{p}


