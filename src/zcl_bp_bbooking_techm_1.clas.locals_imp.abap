CLASS lhc_zi_booking_techm_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_booking_techm_1 RESULT result.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_techm_1\_Bookingsuppl.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_techm_1~calculatetotalprice.
ENDCLASS.

CLASS lhc_zi_booking_techm_1 IMPLEMENTATION.

  METHOD get_instance_features.
   READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
   ENTITY zi_travel_techm_1 BY \_BOOKING
    FIELDS (  travelid BOOKINGstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_BOOKING).

    result = VALUE #( FOR ls_BOOKING IN lt_BOOKING
    ( %tky = ls_BOOKING-%tky

*    %features-%action-acceptTravel = COND #(  WHEN ls_BOOKING-BOOKINGstatus = 'A'
*    THEN if_abap_behv=>fc-o-disabled
*    ELSE if_abap_behv=>fc-o-ENabled )
*
*    %features-%action-REJECTTravel = COND #(  WHEN ls_travel-overallstatus = 'X'
*    THEN if_abap_behv=>fc-o-disabled
*    ELSE if_abap_behv=>fc-o-ENableD )

    %features-%aSSOC-_BOOKINGSUPPL = cond #(  when ls_BOOKING-BOOKINGstatus = 'X'
  THEN IF_ABAP_BEHV=>FC-O-disabled
  ELSE IF_ABAP_BEHV=>FC-O-ENableD ) ) ).
  ENDMETHOD.

  METHOD earlynumbering_cba_Bookingsupp.
     DATA: max_booking_suppl_id TYPE /dmo/booking_supplement_id .

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
      ENTITY zi_booking_techm_1  BY \_Bookingsuppl
        FROM CORRESPONDING #( entities )
        LINK DATA(booking_supplements).

    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                       FOR  booksuppl IN booking_supplements USING KEY entity
                                                                             WHERE (     source-TravelId  = <booking_group>-TravelId
                                                                                     AND source-BookingId = <booking_group>-BookingId )
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   booksuppl-target-BookingSupplementId > max
                                                                          THEN booksuppl-target-BookingSupplementId
                                                                          ELSE max )
                                     ).
      " Get highest assigned bookingsupplement_id from incoming entities
      max_booking_suppl_id = REDUCE #( INIT max = max_booking_suppl_id
                                       FOR  entity IN entities USING KEY entity
                                                               WHERE (     TravelId  = <booking_group>-TravelId
                                                                       AND BookingId = <booking_group>-BookingId )
                                       FOR  target IN entity-%target
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   target-BookingSupplementId > max
                                                                                     THEN target-BookingSupplementId
                                                                                     ELSE max )
                                     ).


      " Loop over all entries in entities with the same TravelID and BookingID
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE TravelId  = <booking_group>-TravelId
                                                                            AND BookingId = <booking_group>-BookingId.

        " Assign new booking_supplement-ids
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).
          APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-zi_booksuppl_techm_1 ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
          IF <booksuppl_wo_numbers>-BookingSupplementId IS INITIAL.
            max_booking_suppl_id += 1 .
            <mapped_booksuppl>-BookingSupplementId = max_booking_suppl_id .
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.
    METHOD calculateTotalPrice.

    DATA: it_travel TYPE STANDARD TABLE OF zi_travel_techm_1 WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel =  CORRESPONDING #(  keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
     ENTITY zi_travel_techm_1
     EXECUTE recalcTotPrice
     FROM CORRESPONDING #( it_travel ).

  ENDMETHOD.

ENDCLASS.
