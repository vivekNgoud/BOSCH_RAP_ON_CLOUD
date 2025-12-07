CLASS zcl_bsh_vn_first_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BSH_VN_FIRST_CLASS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
   out->write(
     EXPORTING
       data   = 'Welcome to steampunk'
*        name   =
*      RECEIVING
*        output =
   ).

  ENDMETHOD.
ENDCLASS.
