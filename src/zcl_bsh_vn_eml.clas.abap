CLASS zcl_bsh_VN_eml DEFINITION
 PUBLIC
 FINAL
 CREATE PUBLIC .
  PUBLIC SECTION.
    DATA : lv_opr TYPE c VALUE 'D'.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
CLASS zcl_bsh_VN_eml IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    CASE lv_opr.
      WHEN 'R'.
        READ ENTITIES OF zbsh_vn_travel
        ENTITY Travel
        FIELDS ( travelid agencyid CustomerId OverallStatus ) WITH
        VALUE #( ( TravelId = '00000010' )
                 ( TravelId = '00000024' )
                 ( TravelId = '009595' )
               )
        RESULT DATA(lt_result)
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_messages).
        out->write(
          EXPORTING
            data   = lt_result
        ).
        out->write(
          EXPORTING
            data   = lt_failed
        ).
      WHEN 'C'.
        DATA(lv_description) = 'Vivek Rocks with RAP'.
        DATA(lv_agency) = '070016'.
        DATA(lv_customer) = '000697'.
        MODIFY ENTITIES OF zbsh_vn_travel
        ENTITY Travel
        CREATE FIELDS ( TravelId AgencyId CurrencyCode BeginDate EndDate Description OverallStatus )
        WITH VALUE #(
                        (
                          %cid = 'VIVEK'
                          TravelId = '00019347'
                          AgencyId = lv_agency
                          CustomerId = lv_customer
                          BeginDate = cl_abap_context_info=>get_system_date( )
                          EndDate = cl_abap_context_info=>get_system_date( ) + 30
                          Description = lv_description
                          OverallStatus = 'O'
                         )
                        ( %cid = 'VIVEK-1'
                          TravelId = '00012358'
                          AgencyId = lv_agency
                          CustomerId = lv_customer
                          BeginDate = cl_abap_context_info=>get_system_date( )
                          EndDate = cl_abap_context_info=>get_system_date( ) + 30
                          Description = lv_description
                          OverallStatus = 'O'
                         )
                         (
                          %cid = 'VIVEK-2'
                          TravelId = '00000010'
                          AgencyId = lv_agency
                          CustomerId = lv_customer
                          BeginDate = cl_abap_context_info=>get_system_date( )
                          EndDate = cl_abap_context_info=>get_system_date( ) + 30
                          Description = lv_description
                          OverallStatus = 'O'
                         )
         )
         MAPPED DATA(lt_mapped)
         FAILED lt_failed
         REPORTED lt_messages.
        COMMIT ENTITIES.
        out->write(
         EXPORTING
           data   = lt_mapped
       ).
        out->write(
          EXPORTING
            data   = lt_failed
        ).
      WHEN 'U'.
        lv_description = 'Wow, That was an greate update'.
        lv_agency = '070032'.
        MODIFY ENTITIES OF zbsh_vn_travel
        ENTITY Travel
        UPDATE FIELDS ( AgencyId Description )
        WITH VALUE #(
                        ( TravelId = '00019347'
                          AgencyId = lv_agency
                          Description = lv_description
                         )
                        ( TravelId = '00012358'
                          AgencyId = lv_agency
                          Description = lv_description
                         )
         )
         MAPPED lt_mapped
         FAILED lt_failed
         REPORTED lt_messages.
        COMMIT ENTITIES.
        out->write(
         EXPORTING
           data   = lt_mapped
       ).
        out->write(
          EXPORTING
            data   = lt_failed
        ).
      WHEN 'D'.
        MODIFY ENTITIES OF zbsh_vn_travel
            ENTITY Travel
            DELETE FROM VALUE #(
                            ( TravelId = '00019347'
                             )
             )
             MAPPED lt_mapped
             FAILED lt_failed
             REPORTED lt_messages.
        COMMIT ENTITIES.
        out->write(
         EXPORTING
           data   = lt_mapped
       ).
        out->write(
          EXPORTING
            data   = lt_failed
        ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.


