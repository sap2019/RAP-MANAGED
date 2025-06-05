@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement interface view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_booksuppl_techm_1
  as select from zbooksup_techm_1

  association        to parent zi_booking_techm_1 as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                     and $projection.BookingId = _Booking.BookingId

  association [1..1] to zi_travel_techm_1         as _Travel         on  $projection.TravelId = _Travel.TravelId

  association [1..1] to /DMO/I_Supplement         as _Supplement     on  $projection.SupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText     as _supplementtext on  $projection.SupplementId = _supplementtext.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      last_changed_at       as LastChangedAt,
      _Travel,
      _Booking,
      _Supplement,
      _supplementtext
}
