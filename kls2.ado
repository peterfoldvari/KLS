program define kls2, eclass 
syntax varlist (numeric ts fv min=2) [if] [in] ,[ max(real -0.8) min(real 0.8) STep(integer 30)] var(string) save(string)
gettoken depvar indepvar: varlist



tempname result
local s=(`max'-`min')/`step'
postfile `result' rho b p ci_l ci_h using "`save'", replace

qui {
forvalues i=`min'(`s')`max' {


kls `varlist' `if' `in', endog(`i')
scalar rho=`i'
scalar b = _b[`var']
scalar se = _se[`var']
scalar t = _b[`var']/_se[`var'] 
scalar p = 2*ttail(e(N),abs(t))
scalar ci_l= _b[`var'] - 1.96*_se[`var']
scalar ci_h= _b[`var'] + 1.96*_se[`var']
post `result' (rho) (b) (p) (ci_l) (ci_h)

}

}
postclose `result'

use `save', clear
keep if p!=.
summarize
twoway (rarea ci_l ci_h rho, astyle(ci) fcolor(gs14%40)) (line b  rho, lcolor(black) )  if p!=., legend(order(2 "coeff" 1 "95% CI") region(lcolor(none)))  ylabel(, format(%9.1fc)) xlabel( minmax, format(%9.1fc) grid) ytitle("coefficient:`var'") xtitle("Postulated endogeneity")  scheme(s2mono)  graphregion(fcolor(white)) name(coeff) xlabel(#10)

twoway (line p  rho, lcolor(black))  if p!=.,  ylabel(, format(%9.1fc)) xlabel(minmax , format(%9.1fc) grid) ytitle("p-value exclusion test: `var'") xtitle("Postulated endogeneity")  scheme(s2mono)  graphregion(fcolor(white)) name(excl) xlabel(#10)

 

end

