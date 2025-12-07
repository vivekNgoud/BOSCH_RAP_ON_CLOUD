@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'aggre'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_VN_AGGR
  as select from ZBSH_vn_JOIN
{
  key CompanyName,
  key Country,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum(GrossAmount) as TotalSales,
      CurrencyCode
}
group by
  CompanyName,
  Country,
  CurrencyCode
