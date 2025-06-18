CLASS lhc_zi_booksuppl_techm_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_booksuppl_techm_1~validateCurrencyCode.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_booksuppl_techm_1~validatePrice.

    METHODS validateSupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_booksuppl_techm_1~validateSupplement.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booksuppl_techm_1~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zi_booksuppl_techm_1 IMPLEMENTATION.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validatePrice.
  ENDMETHOD.

  METHOD validateSupplement.
  ENDMETHOD.

  METHOD calculateTotalPrice.
     MODIFY ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_travel_techm_1
    EXECUTE recalcTotPrice
    FROM CORRESPONDING #( keys ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_travel_techm_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_techm_1 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_techm_1 RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_techm_1~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_techm_1~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_techm_1~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_techm_1~rejecttravel RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_techm_1~validatecustomer.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_techm_1~validatebookingfee.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_techm_1~validatecurrencycode.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_techm_1~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_techm_1~validatestatus.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_techm_1.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_techm_1\_Booking.

ENDCLASS.

CLASS lhc_zi_travel_techm_1 IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_techm_1 ENTITY zi_travel_techm_1
    FIELDS (  travelid overallstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
    ( %tky = ls_travel-%tky

    %features-%action-acceptTravel = COND #(  WHEN ls_travel-overallstatus = 'A'
    THEN if_abap_behv=>fc-o-disabled
    ELSE if_abap_behv=>fc-o-ENabled )

    %features-%action-REJECTTravel = COND #(  WHEN ls_travel-overallstatus = 'X'
    THEN if_abap_behv=>fc-o-disabled
    ELSE if_abap_behv=>fc-o-ENableD )

    %features-%aSSOC-_Booking = COND #(  WHEN ls_travel-overallstatus = 'X'
  THEN if_abap_behv=>fc-o-disabled
  ELSE if_abap_behv=>fc-o-ENableD ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_entities)  = entities.

*    DELETE lt_entities WHERE travelid IS INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*      ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          =  CONV #( lines( lt_entities ) )
*      subobject         =
*      toyear            =
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges.
    ENDTRY.


    ASSERT lv_qty = lines(  lt_entities ).

    DATA: lt_travel_techm_1 TYPE TABLE FOR MAPPED EARLY zi_travel_techm_1,
          ls_travel_techm_1 LIKE  LINE OF lt_travel_techm_1.
    DATA(lv_curr_num) = lv_latest_num - lv_qty.

    LOOP AT lt_entities INTO DATA(ls_entities).
*    LS_TRAVEL_TECHM_1 = VALUE #( %CID = LS_ENTITIES-%cid TRAVELID = LV_CURR_NUM ).
      APPEND VALUE #( %cid = ls_entities-%cid travelid = lv_curr_num  ) TO mapped-zi_travel_techm_1.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA : lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
     ENTITY zi_travel_techm_1 BY \_Booking
     FROM CORRESPONDING #( entities )
     LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
                               GROUP BY <ls_group_entity>-TravelId .


      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                 FOR ls_link IN lt_link_data USING KEY entity
                                      WHERE ( source-TravelId = <ls_group_entity>-TravelId  )
                                 NEXT  lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                       THEN ls_link-target-BookingId
                                                                        ELSE lv_max ) ).
      lv_max_booking  = REDUCE #( INIT lv_max = lv_max_booking
                                   FOR ls_entity IN entities USING KEY entity
                                       WHERE ( TravelId = <ls_group_entity>-TravelId  )
                                     FOR ls_booking IN ls_entity-%target
                                     NEXT lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                        THEN ls_booking-BookingId
                                                                         ELSE lv_max )
       ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
                        USING KEY entity
                         WHERE TravelId = <ls_group_entity>-TravelId.

        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
          APPEND CORRESPONDING #( <ls_booking> )  TO   mapped-zi_booking_techm_1
             ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <ls_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.


            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
      ENTITY zi_travel_techm_1
       UPDATE FIELDS ( OverallStatus )
       WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                           OverallStatus = 'A' ) ).

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_travel_techm_1
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).
  ENDMETHOD.

  METHOD copyTravel.

    DATA: it_travel        TYPE TABLE FOR CREATE zi_travel_techm_1,
          it_booking_cba   TYPE TABLE FOR CREATE zi_travel_techm_1\_Booking,
          it_booking_suppl TYPE TABLE FOR CREATE zi_booking_techm_1\_Bookingsuppl,
          it_booksuppl_cba TYPE TABLE FOR CREATE Zi_booking_techm_1\_Bookingsuppl.

*    READ TABLE keys
*    ASSIGNING FIELD-SYMBOL(<ls_without_cid>) WITH KEY %cid = ''.
*    ASSERT <ls_without_cid> IS INITIAL.

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_travel_techm_1
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_r)
    FAILED DATA(lt_failed).

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_travel_techm_1 BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
    RESULT DATA(lt_booking_r).

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_BOOKING_techm_1 BY \_BookingSUPPL
    ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
    RESULT DATA(lt_BOOKSUPP_r).

    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

*  APPEND INITIAL LINE TO IT_TRAVEL ASSIGNING  FIELD-SYMBOL(<LS_TRAVEL>).
      APPEND VALUE #( %cid = keys[ KEY entity travelid = <ls_travel_r>-travelid ]-%cid

      %data = CORRESPONDING #( <ls_travel_r> EXCEPT travelid ) )
      TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date(  ) + 30.
      <ls_travel>-overallstatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
       TO it_booking_cba ASSIGNING FIELD-SYMBOL(<it_booking>).

      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
                        USING KEY entity
                        WHERE TravelId = <ls_travel_r>-TravelId.
        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                      %data = CORRESPONDING #( <ls_booking_r> EXCEPT TravelId ) )
               TO  <it_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).
        <ls_booking_n>-BookingStatus  = 'N'.
        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid )
             TO it_booksuppl_cba ASSIGNING FIELD-SYMBOL(<ls_booksupp>).
        LOOP AT lt_booksupp_r ASSIGNING FIELD-SYMBOL(<ls_booksupp_r>)
                              USING KEY entity
                              WHERE TravelId = <ls_travel_r>-TravelId
                              AND   BookingId = <ls_booking_r>-BookingId.

          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId && <ls_booksupp_r>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_booksupp_r> EXCEPT TravelId BookingId ) )
                  TO <ls_booksupp>-%target.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
    MODIFY ENTITIES OF Zi_travel_techm_1 IN LOCAL MODE
   ENTITY Zi_travel_techm_1
   CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
   WITH it_travel
   ENTITY Zi_travel_techm_1
    CREATE BY \_Booking
    FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
    WITH it_booking_cba
   ENTITY Zi_booking_techm_1
    CREATE BY \_Bookingsuppl
    FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
    WITH it_booksuppl_cba
    MAPPED DATA(it_mapped).


    mapped-Zi_travel_techm_1 = it_mapped-Zi_travel_techm_1.

  ENDMETHOD.

  METHOD recalcTotPrice.
  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
  ENTITY zi_travel_techm_1
   UPDATE FIELDS ( OverallStatus )
   WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                       OverallStatus = 'X' ) ).

    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
    ENTITY zi_travel_techm_1
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).
    .

    result  = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                 %param  =  ls_result ) ).
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITY  IN LOCAL MODE zi_travel_techm_1
      FIELDS ( CustomerId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId  ).
    DELETE lt_cust WHERE customer_id IS INITIAL.
    SELECT
     FROM /dmo/customer
     FIELDS customer_id
     FOR ALL ENTRIES IN @lt_cust
     WHERE customer_id = @lt_cust-customer_id
     INTO TABLE @DATA(lt_cust_db).
    IF sy-subrc IS INITIAL.

    ENDIF.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
         OR  NOT line_exists( lt_cust_db[ customer_id = <ls_travel>-CustomerId  ] )   .

        APPEND VALUE #( %tky = <ls_travel>-%tky )
                   TO failed-zi_travel_techm_1.
        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                            textid                = /dmo/cm_flight_messages=>customer_unkown
                                           customer_id           = <ls_travel>-CustomerId
                                severity              = if_abap_behv_message=>severity-error
                                )
                        %element-CustomerId = if_abap_behv=>mk-on

        )
                   TO reported-zi_travel_techm_1.



      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateBookingFee.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateDates.
  READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
              ENTITY zi_travel_techm_1
                FIELDS ( BeginDate EndDate )
                WITH CORRESPONDING #( keys )
              RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(travel).

      IF travel-EndDate < travel-BeginDate.  "end_date before begin_date

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_techm_1.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = travel-BeginDate
                                   end_date   = travel-EndDate
                                   travel_id  = travel-TravelId )
                        %element-BeginDate   = if_abap_behv=>mk-on
                        %element-EndDate     = if_abap_behv=>mk-on
                     ) TO reported-zi_travel_techm_1.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %tky        = travel-%tky ) TO failed-zi_travel_techm_1.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate  = if_abap_behv=>mk-on
                        %element-EndDate    = if_abap_behv=>mk-on
                      ) TO reported-zi_travel_techm_1.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.
  READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE
        ENTITY zi_travel_techm_1
          FIELDS ( OverallStatus )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).
      CASE ls_travel-OverallStatus.
        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.
          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-zi_travel_techm_1.

          APPEND VALUE #( %tky = ls_travel-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid = /dmo/cm_flight_messages=>status_invalid
                                     severity = if_abap_behv_message=>severity-error
                                     status = ls_travel-OverallStatus )
                          %element-OverallStatus = if_abap_behv=>mk-on
                        ) TO reported-zi_travel_techm_1.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_travel_techm_1 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_techm_1 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

ENDCLASS.

*CLASS lhc_ZI_BOOKING_TECHM_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR zi_booking_techm_1 RESULT result.
*
*    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
*      IMPORTING entities FOR CREATE zi_booking_techm_1\_Bookingsuppl.
*
*ENDCLASS.
*
*CLASS lhc_ZI_BOOKING_TECHM_1 IMPLEMENTATION.
*
*  METHOD get_instance_features.
*  ENDMETHOD.
*
*  METHOD earlynumbering_cba_Bookingsupp.
*    DATA: lv_maX_booking TYPE /dmo/booking_id.
*
*    READ ENTITIES OF zi_travel_techm_1 IN LOCAL MODE ENTITY zi_travel_techm_1
*    BY \_Booking FROM CORRESPONDING #( entities ) LINK DATA(lt_link_data).
*
*    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>) GROUP BY <ls_group_entity>-TravelId.
*
*      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' ) FOR ls_link IN lt_link_data USING KEY entity
*      WHERE (  source-travelid = <ls_group_entity>-travelid )
*      NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
*                                                                           THEN ls_link-target-BookingId
*                                                                            ELSE lv_max ) ).
*      lv_max_booking  = REDUCE #( INIT lv_max = lv_max_booking
*                                       FOR ls_entity IN entities USING KEY entity
*                                           WHERE ( TravelId = <ls_group_entity>-TravelId  )
*                                         FOR ls_booking IN ls_entity-%target
*                                         NEXT lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
*                                                                            THEN ls_booking-BookingId
*                                                                             ELSE lv_max )
*           ).
*
*      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
*                 USING KEY entity
*                  WHERE TravelId = <ls_group_entity>-TravelId.
*
*        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
*          APPEND CORRESPONDING #( <ls_booking> )  TO   mapped-Zi_booking_techm_1
*             ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
*          IF <ls_booking>-BookingId IS INITIAL.
*            lv_max_booking += 10.
*
*
*            <ls_new_map_book>-BookingId = lv_max_booking.
*          ENDIF.
*
*        ENDLOOP.
*
*
*
*      ENDLOOP.
*    ENDLOOP.
*  ENDMETHOD.


*ENDCLASS.
