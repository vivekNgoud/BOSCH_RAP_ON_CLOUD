@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel processor projection root entity'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
@VDM.viewType: #BASIC
define root view entity ZBSH_VN_TRAVEL_PROCESSOR
  as projection on ZBSH_VN_TRAVEL
{
  key     TravelId,
          AgencyId,
          CustomerId,
          BeginDate,
          EndDate,
          BookingFee,
          TotalPrice,
          CurrencyCode,
          Description,
          OverallStatus,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          AgencyName,
          CustomerName,
          IconColor,
          StatusDescription,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child ZBSH_VN_BOOKING_PROCESSOR,
          _Currency,
          _Customer,
          _Status,
          //Virtual elements
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BSH_VN_VE_CALC'
          @EndUserText.label: 'CO2 Tax'
  virtual CO2Tax         : abap.int4,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BSH_VN_VE_CALC'
          @EndUserText.label: 'Week Day'
  virtual dayOfTheFlight : abap.char( 9 )
}
