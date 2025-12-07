@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplement processor entity'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZBSH_VN_BOOKSUPPL_PROCESSOR
  as projection on ZBSH_VN_BOOKSUPPL
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZBSH_VN_BOOKING_PROCESSOR,
      _SupplementText,
      _Travel  : redirected to ZBSH_VN_TRAVEL_PROCESSOR
}
