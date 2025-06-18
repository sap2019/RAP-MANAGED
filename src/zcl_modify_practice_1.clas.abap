CLASS zcl_modify_practice_1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_modify_practice_1 IMPLEMENTATION.
METHOD if_oo_adt_classrun~main.
MODIFY ENTITY zi_travel_techm_1
     CREATE FROM VALUE #(
               ( %cid = 'cid1'
                 %data-BeginDate = '20240225'
                 %control-BeginDate = if_abap_behv=>mk-on

      ) )
     CREATE BY \_Booking
        FROM VALUE #( ( %cid_ref = 'cid1'
                        %target  = VALUE #( ( %cid = 'cid11'
                                              %data-bookingdate = '20240216'
                                              %control-Bookingdate = if_abap_behv=>mk-on  ) )



         ) )
      FAILED FINAL(it_failed)
      MAPPED FINAL(it_mapped)
      REPORTED FINAL(it_result).

    IF it_failed IS NOT INITIAL.
      out->write( it_failed ).
    ELSE.
      COMMIT ENTITIES.
    ENDIF.
ENDMETHOD.
ENDCLASS.
