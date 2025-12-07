@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for business aprtners'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_VN_CDS_ENT
  with parameters
    p_ctry : abap.char(4)

  as select from zbsh_vn_bpa1
{
  key bp_id        as BpId,
  key

      case bp_role
      when  '01'  then 'Customer'
      when '02'  then 'Supplier'
      end          as BpRole,
      company_name as CompanyName,
      street       as Street,
      country      as Country,
      region       as Region,
      city         as City
}
where
  country = $parameters.p_ctry
