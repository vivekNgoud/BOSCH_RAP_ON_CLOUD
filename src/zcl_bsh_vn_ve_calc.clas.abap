CLASS zcl_bsh_vn_ve_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_bsh_vn_ve_calc IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    CHECK NOT it_original_data IS INITIAL.
    DATA: lt_calc_data TYPE STANDARD TABLE OF zbsh_AB_travel_processor WITH DEFAULT KEY,
          lv_rate      TYPE p DECIMALS 2 VALUE '0.025'.
    lt_calc_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc>).
      <fs_calc>-CO2Tax = <fs_calc>-TotalPrice * lv_rate.
      ""here you can call a BAPI and calculate some values and send those in VE
      "logic to get day name from the date
      DATA(lv_weekday) = ( <fs_calc>-BeginDate + 1 - '00010101' ) MOD 7 + 1.

      <fs_calc>-dayOfTheFlight =  SWITCH string( lv_weekday
                                       WHEN 1 THEN 'Monday'
                                       WHEN 2 THEN 'Tuesday'
                                       WHEN 3 THEN 'Wednesday'
                                       WHEN 4 THEN 'Thursday'
                                       WHEN 5 THEN 'Friday'
                                       WHEN 6 THEN 'Saturday'
                                       WHEN 7 THEN 'Sunday'
                                       ELSE 'Unknown' ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #(  lt_calc_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
