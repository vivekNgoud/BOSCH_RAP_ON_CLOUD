@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Managed Travel root entity'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #BASIC
define root view entity ZBSH_VN_TRAVEL
  as select from /dmo/travel_m
  composition [0..*] of ZBSH_VN_BOOKING             as _Booking
  association of one to one /DMO/I_Agency           as _Agency   on $projection.AgencyId = _Agency.AgencyID
  association of one to one /DMO/I_Customer         as _Customer on $projection.CustomerId = _Customer.CustomerID
  association of one to one I_Currency              as _Currency on $projection.CurrencyCode = _Currency.Currency
  association of one to one /DMO/I_Travel_Status_VH as _Status   on $projection.OverallStatus = _Status.TravelStatus
{
      @ObjectModel.text.element: [ 'Description' ]
  key travel_id          as TravelId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{
                   entity.name: '/DMO/I_Agency',
                   entity.element: 'AgencyID' }]
      agency_id          as AgencyId,
      @Consumption.valueHelpDefinition: [{
      entity.name : '/DMO/I_Customer',
      entity.element: 'CustomerID'
      }]
      @ObjectModel.text.element: [ 'CustomerName' ]

      customer_id        as CustomerId,
      _Customer.LastName as CustomerName,

      begin_date         as BeginDate,
      end_date           as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee        as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,
      currency_code      as CurrencyCode,
      description        as Description,
      @ObjectModel.text.element: [ 'StatusDescription' ]
      @Consumption.valueHelpDefinition: [{
          entity.name : '/DMO/I_Travel_Status_VH',
          entity.element: 'TravelStatus'
      }]
      overall_status     as OverallStatus,
      case overall_status
       when 'O' then 2
       when 'A' then 3
       when 'X' then 1
       else 1 end        as IconColor,

      case overall_status
      when 'O' then 'Open'
      when 'A' then 'Approved'
      when 'X' then 'Rejected'
      else 'New' end     as StatusDescription,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by    as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at    as LastChangedAt,
      _Booking,
      _Agency,
      _Customer,
      _Currency,
      _Status
}
