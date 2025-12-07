@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Prod'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
define view entity ZI_BSH_VN_PROD
  as select from zbsh_vn_product
{
  key product_id as ProductId,
      name       as Name,
      category   as Category,
      price      as Price,
      currency   as Currency,
      discount   as Discount
}
