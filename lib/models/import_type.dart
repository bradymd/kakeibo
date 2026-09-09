/// Which kind of monthly data an import screen is bulk-copying forward
/// from a prior month. Shared between the import screen and the routes
/// that launch it — pulled out to its own file so it doesn't require
/// depending on any particular screen implementation.
enum ImportType { fixedCosts, income }
