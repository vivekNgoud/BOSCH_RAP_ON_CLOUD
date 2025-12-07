@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking child entity'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
     dataClass: #MIXED,
     serviceQuality: #X,
     sizeCategory: #S }
@VDM.viewType: #BASIC
define view entity ZBSH_VN_BOOKING
  as select from /dmo/booking_m
  composition [0..*] of ZBSH_VN_BOOKSUPPL            as _BookingSupplement
  association        to parent ZBSH_VN_TRAVEL               as _Travel on  $projection.TravelId = _Travel.TravelId
  association of one to one /DMO/I_Customer          as _Customer      on  $projection.CustomerId = _Customer.CustomerID
  association of one to one /DMO/I_Carrier           as _Carrier       on  $projection.CarrierId = _Carrier.AirlineID
  association of one to one /DMO/I_Connection        as _Connections   on  $projection.CarrierId    = _Connections.AirlineID
                                                                       and $projection.ConnectionId = _Connections.ConnectionID
  association of one to one /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,
      _Travel,
      _Customer,
      _Carrier,
      _Connections,
      _BookingStatus,
      _BookingSupplement
}
