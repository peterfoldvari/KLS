
program define kls_c, eclass 
syntax varlist (numeric ts fv min=2) [if] [in] ,[ max(real -0.8) min(real 0.8) STep(integer 30)] var(string) save(string)
gettoken depvar indepvar: varlist

local var1 : word 2 of `varlist'
local var2 : word 3 of `varlist'

tempname result
local s=(`max'-`min')/`step'
postfile `result' rho1 rho2 b p ci_l ci_h using "`save'", replace

qui {
forvalues i=`min'(`s')`max' {
   forvalues j=`min'(`s')`max' {

kls `varlist' `if' `in', endog(`i' `j')
scalar rho1=`i'
scalar rho2=`j'
scalar b = _b[`var']
scalar se = _se[`var']
scalar t = _b[`var']/_se[`var'] 
scalar p = 2*ttail(e(N),abs(t))
scalar ci_l= _b[`var'] - 1.96*_se[`var']
scalar ci_h= _b[`var'] + 1.96*_se[`var']
post `result' (rho1) (rho2) (b) (p) (ci_l) (ci_h)
 }
}

}
postclose `result'

use `save', clear
keep if p!=.
summarize

twoway (contour p rho2 rho1, ccuts(0.01 0.05 0.1 0.2 0.3 .5 .7 1)) , scheme(scientific)  graphregion(fcolor(white))   xlabel(#10, format(%9.1fc)) ylabel(#10, format(%9.1fc)) zlabel(#10, format(%9.1fc)) ytitle("{&rho}{sub:`var2'}") xtitle("{&rho}{sub:`var1'}") ztitle("p-value: `var'") name(excl)

twoway (contour b rho2 rho1, levels(10)  minmax ) , scheme(scientific)  graphregion(fcolor(white))  ytitle("{&rho}{sub:`var2'}") xtitle("{&rho}{sub:`var1'}") xlabel(#10,format(%9.1fc)) ylabel(#10,format(%9.1fc)) zlabel(#10,format(%9.1fc)) ztitle("coefficient: `var'") name(coeff)

end

