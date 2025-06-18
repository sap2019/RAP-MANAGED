@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view of Booking entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_booking_techm_1 as projection on zi_booking_techm_1
{
    key TravelId,
    key BookingId,
    BookingDate,
    @ObjectModel.text.element: ['CustomerName']
    CustomerId,
    _Customer.FirstName as CustomerName,
    @ObjectModel.text.element: [ 'CarrierName' ]
    CarrierId,
    _Carrier.Name as CarrierName,
    ConnectionID,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookingSuppl : redirected to composition child zc_booksuppl_techm_1,
    _Booking_Status,
    _Carrier,
    _Connection,
    _Customer,
    _Travel  : redirected to parent zc_travel_techm_1
}
