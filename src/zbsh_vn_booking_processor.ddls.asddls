@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking processor cds entity'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZBSH_VN_BOOKING_PROCESSOR
  as projection on ZBSH_VN_BOOKING
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZBSH_VN_BOOKSUPPL_PROCESSOR,
      _Carrier,
      _Connections,
      _Customer,
      _Travel            : redirected to parent ZBSH_VN_TRAVEL_PROCESSOR
}
