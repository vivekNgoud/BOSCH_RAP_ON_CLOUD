@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sales'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #FACT
define view entity ZI_BSH_VN_SALES
  as select from zbsh_vn_so_hdr
  association of one to many zbsh_vn_so_item as _items on $projection.OrderId = _items.order_id

{
  key zbsh_vn_so_hdr.order_id as OrderId,
      zbsh_vn_so_hdr.order_no as OrderNo,
      zbsh_vn_so_hdr.buyer    as Buyer,
      _items.product          as ProductId,
      @Semantics.amount.currencyCode: 'Currency'
      _items.amount           as Amount,
      _items.currency         as Currency,
      _items.qty              as Quantity,
      _items.uom              as Unit

}
