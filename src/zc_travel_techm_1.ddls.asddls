@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view of travel entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity zc_travel_techm_1 
 provider contract transactional_query
as projection on zi_travel_techm_1
{
    key TravelId,
    @ObjectModel.text.element: [ 'AgencyName' ]
    AgencyID,
    _Agency.Name as AgencyName,
     @ObjectModel.text.element: [ 'CustomerName' ]
    CustomerID,
    _Customer.LastName as CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
     @ObjectModel.text.element: [ 'OverallStatusText' ]
    OverallStatus,
    _Status._Text.Text as OverallStatusText: localized,
//    CreatedBy,
//    CreatedAt,
//    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Agency,
    _Booking : redirected to composition child zc_booking_techm_1,
    _currency,
    _Customer,
    _Status
}
