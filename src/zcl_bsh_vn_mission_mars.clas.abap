CLASS zcl_bsh_vn_mission_mars DEFINITION
 PUBLIC
 FINAL
 CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
    DATA: itab TYPE TABLE OF string.
    METHODS reach_to_mars.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
CLASS zcl_bsh_vn_mission_mars IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    me->reach_to_mars(  ).
    out->write(
          EXPORTING
            data   = itab
*            name   =
*          RECEIVING
*            output =
        ).
  ENDMETHOD.
  METHOD reach_to_mars.
    DATA lv_text TYPE string.
    DATA(lo_earth) = NEW zcl_earth( ).
    DATA(lo_iplanet1) = NEW zcl_planet1(  ).
    DATA(lo_mars) = NEW zcl_mars( ).
    lv_text = lo_earth->start_engine( ).
    APPEND lv_text TO itab.
    lv_text = lo_earth->leave_orbit(  ).
    APPEND lv_text TO itab.
    lv_text = lo_iplanet1->enter_orbit( ).
    APPEND lv_text TO itab.
    lv_text = lo_iplanet1->leave_orbit(  ).
    APPEND lv_text TO itab.
    lv_text = lo_mars->enter_orbit( ).
    APPEND lv_text TO itab.
    lv_text = lo_mars->explore_mars( ).
    APPEND lv_text TO itab.
  ENDMETHOD.
ENDCLASS.


