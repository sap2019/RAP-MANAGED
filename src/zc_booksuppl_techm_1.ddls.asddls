@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supp Projection View Manged'
@Metadata.ignorePropagatedAnnotations: true
define view entity zc_booksuppl_techm_1 as projection on zi_booksuppl_techm_1
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
     _Travel: redirected to zc_travel_techm_1 ,
    _Booking : redirected to parent zc_booking_techm_1,
    _Supplement,
    _supplementtext
   
}
