@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'view on view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_VN_VOV
  as select from ZBSH_VN_CDS_ENT( p_ctry: 'IN' )
{
  key BpId,
  key BpRole,
      CompanyName,
      Street,
      Country,
      Region,
      City
}
