* v1.0 P. Foldvari dec 2019
* This is an implementation of the KLS estiamtor by Prof. Jan F. Kiviet, University of Amsterdam

program define kls, eclass

 
syntax varlist [if] [in] , endog(numlist)
local endog: subinstr local endog " " ", ", all
gettoken depvar indepvar: varlist
marksample touse
mata: m_kls("`varlist'", "`touse'",(`endog'))

tempname b V
matrix `b' = r(b)'
matrix `V' = r(V)
local N = r(N)
matname `b' `indepvar' , c(.)
matname `V' `indepvar'
ereturn post `b' `V', depname(`depvar') obs(`N') esample(`touse')
ereturn local cmd = "kls"
ereturn display
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

// cov matrix 
V=invsym(Sxx)*(Sxx-Sxx*R:^2-R:^2*Sxx-(Sxx*R:^2*invsym(Sxx)*PHI+PHI*invsym(Sxx)*R:^2*Sxx)/theta-(0.5/theta)*(PHI*R:^2+R:^2*PHI)+(theta^-1+theta^-2*(0.5-rho'*R*Sx*invsym(Sxx)*Sx*R*rho))*PHI+0.5*(I(k)+theta^-1*PHI*invsym(Sxx))*R*invsym(Sx)*(Sx:*Sx)*invsym(Sx)*R*(I(k)+theta^-1*invsym(Sxx)*PHI))*invsym(Sxx)/n

st_eclear()
st_matrix("r(b)", bkls)
st_matrix("r(V)", s2_ukls*V)
st_numscalar("r(N)", n)
}
end
