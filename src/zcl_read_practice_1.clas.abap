CLASS zcl_read_practice_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_practice_1 IMPLEMENTATION.

  METHOD if_OO_adt_classrun~main.

    READ ENTITY zi_travel_techm_1
    FROM VALUE #( ( %key-travelid = '00000032'
    %control = VALUE #( AgencyID = if_abap_behv=>mk-on
    customerid = if_abap_behv=>mk-on
    begindate = if_abap_behv=>mk-on  ) ) )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed).

    READ ENTITY zi_travel_techm_1 FIELDS ( AgencyID
    CreatedAt
    begindate ) WITH VALUE #( ( %key-travelid = '00000032' ) )
    RESULT lt_result
    FAILED lt_failed.

*    read entity zi_travel_techm_1
*    by \_Booking
*    ALL FIELDS WITH  VALUE #( ( %key-travelid = '00000034' )
*    (  %key-travelid = '00000033' ) )
*    RESULT data(lt_result_travel)
*    FAILED data(lt_failed_travel).
*      IF lt_failed_travel IS NOT INITIAL.
*      out->write( 'Read Failed' ).
*    ELSE.
*
*      out->write( lt_result_travel ).
*    ENDIF.

READ ENTITIES OF zi_travel_techm_1

    ENTITY zi_travel_techm_1
    ALL FIELDS
    WITH VALUE #( ( %key-TravelId = '00000035'   )
                    ( %key-TravelId = '00000036' )
                    )
     RESULT DATA(lt_result_travel)

    ENTITY zi_booking_techm_1
    ALL FIELDS WITH VALUE #( ( %key-TravelId = '00000034'
                               %key-BookingId = '0001'
                                ) )
     RESULT DATA(lt_result_book)

     FAILED DATA(lt_failed_sort).

    IF lt_failed_sort IS NOT INITIAL.
      out->write( 'Read failed' ).

    ELSE.
      out->write( lt_result_travel ).
      out->write( lt_result_book ).
    ENDIF.

    IF lt_failed IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.

      out->write( lt_result ).
    ENDIF.


    DATA: it_optab         TYPE abp_behv_retrievals_tab,
          it_travel        TYPE TABLE FOR READ IMPORT zi_travel_techm_1,
          it_travel_result TYPE TABLE FOR READ RESULT  zi_travel_techm_1,
           it_BOOKING        TYPE TABLE FOR READ IMPORT zi_BOOKING_techm_1,
          it_BOOKING_result TYPE TABLE FOR READ RESULT  zi_BOOKING_techm_1.



    it_travel = VALUE #( ( %key-TravelId = '0000004172'
                          %control = VALUE #( AgencyId    = if_abap_behv=>mk-on
                                              CUSTOMERID  = if_abap_behv=>mk-on
                                              BEGINDATE   = if_abap_behv=>mk-on
                                         )
                         ) ).

                         it_BOOKING = VALUE #( ( %key-TravelId = '0000004172'
                          %control = VALUE #( BOOKINGDATE   = if_abap_behv=>mk-on
                                              BOOKINGSTATUS  = if_abap_behv=>mk-on
                                              BOOKINGID   = if_abap_behv=>mk-on
                                         )
                         ) ).
    it_optab = VALUE #( (
                          op = if_abap_behv=>op-r-READ
                          entity_name = 'ZI_TRAVEL_TECHM_1'
                          instances = REF #( it_travel )
                          results =  REF #( it_travel_result ) )
                          (
                          op = if_abap_behv=>op-r-READ_BA
                          entity_name = 'ZI_TRAVEL_TECHM_1'
                          sub_name   = '_BOOKING'
                          instances =  REF #( it_BOOKING )
                          results = REF #( it_BOOKING_RESULT )
                          )


                          ).


READ ENTITIES OPERATIONS IT_OPTAB FAILED DATA(Lt_FAILED_DY).
IF  LT_FAILED_DY IS NOT INITIAL.
OUT->write( 'Read Failed' ).
else.
out->write( it_travel_result ).
endif.


  ENDMETHOD.
ENDCLASS.
