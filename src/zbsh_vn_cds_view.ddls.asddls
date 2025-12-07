@AbapCatalog.sqlViewName: 'ZBSHCDSVIEW1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view'
@Metadata.ignorePropagatedAnnotations: true
define view ZBSH_VN_CDS_VIEW
  as select from zbsh_vn_bpa1
{
  key bp_id        as BpId,
  key bp_role      as BpRole,
      company_name as CompanyName,
      street       as Street,
      country      as Country,
      region       as Region,
      city         as City
}
