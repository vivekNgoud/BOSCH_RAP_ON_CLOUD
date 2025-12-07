@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sales data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #FACT

define view entity ZI_BSH_VN_CO_S1
  as select from ZI_BSH_VN_SALES
  association of many to one ZI_BSH_VN_BPA as _BusinessPartner on $projection.Buyer = _BusinessPartner.BpId
{
  key ZI_BSH_VN_SALES.OrderId,
      ZI_BSH_VN_SALES.OrderNo,
      ZI_BSH_VN_SALES.Buyer,
      ZI_BSH_VN_SALES.ProductId,
      ZI_BSH_VN_SALES.Amount,
      ZI_BSH_VN_SALES.Currency,
      ZI_BSH_VN_SALES.Quantity,
      ZI_BSH_VN_SALES.Unit,
      _BusinessPartner
}
