@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite, Cube for sales data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
   serviceQuality: #X,
   sizeCategory: #S,
   dataClass: #MIXED
}
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #CUBE
define view entity ZI_BSH_VN_CUBE
  as select from Zi_bsh_VN_CO_S1
  association of many to one ZI_BSH_VN_PROD as _Product on $projection.ProductId = _Product.ProductId
{
  key Zi_bsh_VN_CO_S1.OrderId,
      Zi_bsh_VN_CO_S1.OrderNo,
      Zi_bsh_VN_CO_S1.Buyer,
      Zi_bsh_VN_CO_S1.ProductId,
      @DefaultAggregation: #SUM
      Zi_bsh_VN_CO_S1.Amount,
      Zi_bsh_VN_CO_S1.Currency,
      @DefaultAggregation: #SUM
      Zi_bsh_VN_CO_S1.Quantity,
      Zi_bsh_VN_CO_S1.Unit,
      /* Associations */
      Zi_bsh_VN_CO_S1._BusinessPartner.CompanyName as Customer,
      Zi_bsh_VN_CO_S1._BusinessPartner.Country     as Country,
      _Product.Category                            as Category,
      _Product.Name                                as name

}
