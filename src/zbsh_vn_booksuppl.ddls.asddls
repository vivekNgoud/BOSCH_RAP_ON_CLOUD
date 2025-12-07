@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement last child'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
     dataClass: #MIXED,
     serviceQuality: #X,
     sizeCategory: #S }
@VDM.viewType: #BASIC
define view entity ZBSH_VN_BOOKSUPPL
  as select from /dmo/booksuppl_m
  association        to parent ZBSH_VN_BOOKING as _Booking        on  $projection.BookingId = _Booking.BookingId
                                                                  and $projection.TravelId  = _Booking.TravelId
  association [1..1] to ZBSH_VN_TRAVEL         as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement      as _Product        on  $projection.SupplementId = _Product.SupplementID
  association [1..1] to /DMO/I_SupplementText  as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      last_changed_at       as LastChangedAt,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
