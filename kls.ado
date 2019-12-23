* v 1.0 P. Foldvari dec 2019
* This is an implementation of the KLS estimator by Prof. Jan F. Kiviet, University of Amsterdam

program define kls, eclass byable(recall)

 
syntax varlist (numeric ts fv min=2) [if] [in] , endog(numlist)
local endog: subinstr local endog " " ", ", all
gettoken depvar indepvar: varlist
_fv_check_depvar `depvar'
marksample touse
mata: m_kls("`varlist'", "`touse'",(`endog'))

tempname b V rho 
matrix `b' = r(b)'
matrix `V' = r(V)
matrix `rho' = r(rho)
 
local N = r(N)
local df = r(df)
local r2=r(r2)
local k=r(k)
local k_c=`k' - diag0cnt(`xpxi') - 1
local F=r(F)
local Fp=1-chi2(`k',`F')
local rmse=r(rmse)
local mss=r(mss)
local rss=r(rss)
local ll= -0.5*`N'*ln(2*c(pi)*`rss'/`N')-`rss'/(2*`rss'/`N')

matname `b' `indepvar' , c(.)
matname `V' `indepvar'
ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse') dof(`df')  buildfvinfo
ereturn matrix rho = `rho'
ereturn scalar r2 = `r2'
ereturn scalar mss = `mss'
ereturn scalar rss = `rss'
ereturn scalar F = `F'
ereturn scalar Fp = `Fp'
ereturn scalar rmse = `rmse'
ereturn scalar df_m = `k'
ereturn scalar rank = `k'
ereturn scalar ll= `ll'
*ereturn local cmd = "kls"
ereturn local cmdline = "kls price mpg weight, endog(`endog')"
*ereturn local predict = "kls_p"

di "                                  "
di as text "KLS estimator"
di _skip(48)  as text "Number of obs   =           " as result `N'
di _skip(48)  as text "F-stat          =    " as result %9.2f `F'
di _skip(48)  as text "Prob > F        =    " as result %9.4f `Fp'
di _skip(48)  as text "R-squared       =    " as result %9.4f `r2'
di _skip(48)  as text "Root MSE        =    " as result %9.5f `rmse'
ereturn display
di as text "assumed correlations =    "  as result `endog'

end




capture mata mata drop m_kls()
 
mata: mata clear
mata: 
void m_kls(string scalar varlist, string scalar touse, real vector r)
{
real matrix M, X, V
real colvector y 
real scalar n, k, k1, k2
M=X=y=.
st_view(M, ., tokens(varlist), touse)
st_subview(y, M, ., 1)
st_subview(X, M, ., (2\.))
//  demean variables
y=y:-mean(y)  
X=X:-mean(X,1)
n = rows(X)
k= cols(X)
k1= cols(r)
k2=k-k1

if (rank(cross(X,X)) < k) {
errprintf("near singular matrix\n")
exit(499)
}

// OLS estimates

bols = invsym(cross(X,X))*cross(X,y)
uols= y-X*bols
s2_uols=uols'*uols/(n-k-1)  // OLS estimate of error variance

// create necessary matrices for KLS
Sxx = cross(X,X) /n
Sx =sqrt(diag(Sxx))

rho=(r,J(1,k2,0))' // degree of endogeneity vector

// corrected error variance
theta=1-rho'*Sx*invsym(Sxx)*Sx*rho
R=diag(rho)
PHI=Sx*rho*rho'*Sx
s2_ukls=s2_uols/theta

//KLS estimator
bkls= bols - sqrt(s2_ukls)*invsym(Sxx)*Sx*rho
ukls= y-X*bkls
SSR=ukls'ukls
SST=y'y
F=((SST-SSR)/k)/(SSR/(n-k-1))
 
// cov matrix 
V=invsym(Sxx)*(Sxx-Sxx*R:^2-R:^2*Sxx-(Sxx*R:^2*invsym(Sxx)*PHI+PHI*invsym(Sxx)*R:^2*Sxx)/theta-(0.5/theta)*(PHI*R:^2+R:^2*PHI)+(theta^-1+theta^-2*(0.5-rho'*R*Sx*invsym(Sxx)*Sx*R*rho))*PHI+0.5*(I(k)+theta^-1*PHI*invsym(Sxx))*R*invsym(Sx)*(Sx:*Sx)*invsym(Sx)*R*(I(k)+theta^-1*invsym(Sxx)*PHI))*invsym(Sxx)/n

st_eclear()
st_matrix("r(rho)", rho)
st_matrix("r(b)", bkls)
st_matrix("r(V)", s2_ukls*V)
st_numscalar("r(N)", n)
st_numscalar("r(df)", n-k-1)
st_numscalar("r(r2)",1-SSR/SST)
st_numscalar("r(F)", F)
st_numscalar("r(k)", k)
st_numscalar("r(rmse)",sqrt(s2_ukls)) 
st_numscalar("r(mss)", SST-SSR)
st_numscalar("r(rss)",SSR)
}
end