// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// jqr
std::vector<std::string> jqr(std::string json, std::string program, int flags);
RcppExport SEXP jqr_jqr(SEXP jsonSEXP, SEXP programSEXP, SEXP flagsSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< std::string >::type json(jsonSEXP);
    Rcpp::traits::input_parameter< std::string >::type program(programSEXP);
    Rcpp::traits::input_parameter< int >::type flags(flagsSEXP);
    __result = Rcpp::wrap(jqr(json, program, flags));
    return __result;
END_RCPP
}