CLASS lhc_zi_travel_techm_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_TRAVEL_TECHM_1 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_TRAVEL_TECHM_1 RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_TRAVEL_TECHM_1.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_TRAVEL_TECHM_1\_Booking.

ENDCLASS.

CLASS lhc_zi_travel_techm_1 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_entities)  = entities.

    DELETE lt_entities WHERE travelid IS INITIAL.

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

CLASS lhc_ZI_BOOKING_TECHM_1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_booking_techm_1 RESULT result.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_techm_1\_Bookingsuppl.

ENDCLASS.

CLASS lhc_ZI_BOOKING_TECHM_1 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD earlynumbering_cba_Bookingsupp.
  ENDMETHOD.

ENDCLASS.
