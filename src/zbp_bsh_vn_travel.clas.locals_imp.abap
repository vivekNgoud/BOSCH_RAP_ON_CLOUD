CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: t_entity_create TYPE TABLE FOR CREATE ZBSH_VN_travel,
           t_entity_update TYPE TABLE FOR UPDATE ZBSH_VN_travel,
           t_entity_rep    TYPE TABLE FOR REPORTED ZBSH_VN_travel,
           t_entity_err    TYPE TABLE FOR FAILED ZBSH_VN_travel.

    METHODS precheck_vivek_reuse
      IMPORTING
        entities_u TYPE t_entity_update OPTIONAL
        entities_c TYPE t_entity_create OPTIONAL
      EXPORTING
        reported   TYPE t_entity_rep
        failed     TYPE t_entity_err.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.
    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA : ls_result LIKE LINE OF result.
    "Step 1: Get the data of my instance
    READ ENTITIES OF zBSH_vn_travel IN LOCAL MODE
        ENTITY travel
            FIELDS ( travelid OverallStatus )
                WITH CORRESPONDING #( keys )
                    RESULT DATA(lt_travel)
                    FAILED DATA(ls_failed).
    "Step 2: loop at the data
    LOOP AT lt_travel INTO DATA(ls_travel).
      "Step 3: Check if the instance was having status = cancelled
      IF ( ls_travel-OverallStatus = 'X' ).
        DATA(lv_auth) = abap_false.
        "Step 4: Check for authorization in org
*            AUTHORITY-CHECK OBJECT 'CUSTOM_OBJ'
*                ID 'FIELD_NAME' FIELD field1
*            IF sy-subrc = 0.
*                lv_auth = abap_true.
*            ENDIF.
      ELSE.
        lv_auth = abap_true.
      ENDIF.
      ls_result = VALUE #( TravelId = ls_travel-TravelId
                           %update = COND #( WHEN lv_auth EQ abap_false
                                                  THEN if_abap_behv=>auth-unauthorized
                                                  ELSE    if_abap_behv=>auth-allowed
                                           )
                           "%action-edit is mandatory in Odata V4 and optional in V2
                           %action-Edit = COND #( WHEN lv_auth EQ abap_false
                                                  THEN if_abap_behv=>auth-unauthorized
                                                  ELSE    if_abap_behv=>auth-allowed
                                           )
                           %action-copyTravel = COND #( WHEN lv_auth EQ abap_false
                                                  THEN if_abap_behv=>auth-unauthorized
                                                  ELSE    if_abap_behv=>auth-allowed
                                           )
      ).
      ""Finally send the result out to RAP
      APPEND ls_result TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: entity        TYPE STRUCTURE FOR CREATE zbsh_vn_travel,
          travel_id_max TYPE /dmo/travel_id.
    ""Step 1: Ensure that Travel id is not set for the record which is coming
    LOOP AT entities INTO entity WHERE TravelId IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.
    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.
    ""Step 2: Get the seuquence numbers from the SNRO
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = CONV #( '/DMO/TRAVL' )
            quantity          =  CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        ""Step 3: If there is an exception, we will throw the error
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
              TO reported-travel.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.
    CASE number_range_return_code.
      WHEN '1'.
        ""Step 4: Handle especial cases where the number range exceed critical %
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning
                          ) )
              TO reported-travel.
        ENDLOOP.
      WHEN '2' OR '3'.
        ""Step 5: The number range return last number, or number exhaused
        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                            %msg = NEW /dmo/cm_flight_messages(
                                        textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                        severity = if_abap_behv_message=>severity-warning
                            ) )
                TO reported-travel.
        APPEND VALUE #( %cid = entity-%cid
                        %key = entity-%key
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-travel.
    ENDCASE.
    ""Step 6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).
    ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
    ""        return MAPPED data which will then go to RAP framework
    travel_id_max = number_range_key - number_range_returned_quantity.
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.
      entity-TravelId = travel_id_max.
      reported-%other = VALUE #( ( new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = 'Travel id has been created now!' ) ) ).
      APPEND VALUE #( %cid      = entity-%cid
                      %is_draft = entity-%is_draft
                      %key      = entity-%key ) TO mapped-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.
    DATA max_booking_id TYPE /dmo/booking_id.
    ""Step 1: get all the travel requests and their booking data
    READ ENTITIES OF zbsh_vn_travel IN LOCAL MODE
        ENTITY travel BY \_Booking
        FROM CORRESPONDING #( entities )
        LINK DATA(bookings).
    ""Loop at unique travel ids
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.
      ""Step 2: get the highest booking number which is already there
      LOOP AT bookings INTO DATA(ls_booking) USING KEY entity
          WHERE source-TravelId = <travel_group>-TravelId.
        IF max_booking_id < ls_booking-target-BookingId.
          max_booking_id = ls_booking-target-BookingId.
        ENDIF.
      ENDLOOP.
      ""Step 3: get the asigned booking numbers for incoming request
      LOOP AT entities INTO DATA(ls_entity) USING KEY entity
          WHERE TravelId = <travel_group>-TravelId.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          IF max_booking_id < ls_target-BookingId.
            max_booking_id = ls_target-BookingId.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      ""Step 4: loop over all the entities of travel with same travel id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>)
          USING KEY entity WHERE TravelId = <travel_group>-TravelId.
        ""Step 5: assign new booking IDs to the booking entity inside each travel
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
          APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-booking
          ASSIGNING FIELD-SYMBOL(<mapped_booking>).
          IF <mapped_booking>-BookingId IS INITIAL.
            max_booking_id += 10.
            <mapped_booking>-BookingId = max_booking_id.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
    ""press F2 key on method to know the inp and output
    "Step 1: use the EML to read the status of the record which user is editing
    READ ENTITIES OF ZBSH_vn_TRAVEL IN LOCAL MODE
        ENTITY travel
         FIELDS ( TravelId OverallStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel)
         FAILED DATA(lt_failed).
    IF lt_failed IS INITIAL.
      "Step 2: Read the travel data
      DATA(ls_travel) = lt_travel[ 1 ].
      "Step 3: Check the status
      IF ( ls_travel-OverallStatus = 'X' ).
        DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
      ELSE.
        lv_allow = if_abap_behv=>fc-o-enabled.
      ENDIF.
      "Step 4: inform the RAP framework whether to allow/disallow editing of booking
      result = VALUE #( FOR travel IN lt_travel
                          (
                              %tky = travel-%tky
                              %assoc-_Booking = lv_allow
                           )
       ).
    ENDIF.

  ENDMETHOD.

  METHOD copyTravel.
    "Deep copy
    DATA: travels       TYPE TABLE FOR CREATE ZBSH_vn_travel\\Travel,
          bookings_cba  TYPE TABLE FOR CREATE ZBSH_vn_travel\\Travel\_Booking,
          booksuppl_cba TYPE TABLE FOR CREATE ZBSH_vn_travel\\Booking\_BookingSupplement.
    "Step 1: Remove the travel instances with initial %cid
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.
    "Step 2: Read all travel, booking and booking supplement using EML
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
    ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travel_read_result)
        FAILED failed.
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
    ENTITY Travel BY \_Booking
        ALL FIELDS WITH CORRESPONDING #( travel_read_result )
        RESULT DATA(book_read_result)
        FAILED failed.
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
    ENTITY booking BY \_BookingSupplement
        ALL FIELDS WITH CORRESPONDING #( book_read_result )
        RESULT DATA(booksuppl_read_result)
        FAILED failed.
    "Step 3: Fill travel internal table for travel data creation - %cid - abc123
    LOOP AT travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).
      "Travel data prepration
      APPEND VALUE #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                     %data = CORRESPONDING #( <travel> EXCEPT travelId )
      ) TO travels ASSIGNING FIELD-SYMBOL(<new_travel>).
      <new_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <new_travel>-OverallStatus = 'O'.
      "Step 3: Fill booking internal table for booking data creation - %cid_ref - abc123
      APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <travel>-%tky ]-%cid )
        TO bookings_cba ASSIGNING FIELD-SYMBOL(<bookings_cba>).
      LOOP AT  book_read_result ASSIGNING FIELD-SYMBOL(<booking>) WHERE TravelId = <travel>-TravelId.
        APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                        %data = CORRESPONDING #( book_read_result[ KEY entity %tky = <booking>-%tky ] EXCEPT travelid )
        )
            TO <bookings_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).
        <new_booking>-BookingStatus = 'N'.
        "Step 4: Fill booking supplement internal table for booking suppl data creation
        APPEND VALUE #( %cid_ref = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId )
                TO booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).
        LOOP AT booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>)
            USING KEY entity WHERE TravelId = <travel>-TravelId AND
                                   BookingId = <booking>-BookingId.
          APPEND VALUE #( %cid = keys[ KEY entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <booksuppl>-BookingSupplementId
                      %data = CORRESPONDING #( <booksuppl> EXCEPT travelid bookingid )
          )
          TO <booksuppl_cba>-%target.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
    "Step 5: MODIFY ENTITY EML to create new BO instance using existing data
    MODIFY ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
        ENTITY travel
            CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                WITH travels
                    CREATE BY \_Booking FIELDS ( Bookingid BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
                        WITH bookings_cba
                            ENTITY Booking
                                CREATE BY \_BookingSupplement FIELDS ( bookingsupplementid supplementid price currencycode )
                                    WITH booksuppl_cba
        MAPPED DATA(mapped_create).
    mapped-travel = mapped_create-travel.

  ENDMETHOD.

  METHOD reCalcTotalPrice.

*    Define a structure where we can store all the booking fees and currency code
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.
    DATA : amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.
*    Read all travel instances, subsequent bookings using EML
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
       ENTITY Travel
       FIELDS ( BookingFee CurrencyCode )
       WITH CORRESPONDING #( keys )
       RESULT DATA(travels).
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
       ENTITY Travel BY \_Booking
       FIELDS ( FlightPrice CurrencyCode )
       WITH CORRESPONDING #( travels )
       RESULT DATA(bookings).
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
       ENTITY Booking BY \_BookingSupplement
       FIELDS ( price CurrencyCode )
       WITH CORRESPONDING #( bookings )
       RESULT DATA(bookingsupplements).
*    Delete the values w/o any currency
    DELETE travels WHERE CurrencyCode IS INITIAL.
    DELETE bookings WHERE CurrencyCode IS INITIAL.
    DELETE bookingsupplements WHERE CurrencyCode IS INITIAL.
*    Total all booking and supplement amounts which are in common currency
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      "Set the first value for total price by adding the booking fee from header
      amounts_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                          currency_code = <travel>-CurrencyCode ) ).
*    Loop at all amounts and compare with target currency
      LOOP AT bookings INTO DATA(booking) WHERE TravelId = <travel>-TravelId.
        COLLECT VALUE ty_amount_per_currency( amount = booking-FlightPrice
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.
      ENDLOOP.
      LOOP AT bookingsupplements INTO DATA(bookingsupplement) WHERE TravelId = <travel>-TravelId.
        COLLECT VALUE ty_amount_per_currency( amount = bookingsupplement-Price
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.
      ENDLOOP.
      CLEAR <travel>-TotalPrice.
*    Perform currency conversion
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).
        IF amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(total_booking_amt)
          ).
          <travel>-TotalPrice = <travel>-TotalPrice + total_booking_amt.
        ENDIF.
      ENDLOOP.
*    Put back the total amount
    ENDLOOP.
*    Return the total amount in mapped so the RAP will modify this data to DB
    MODIFY ENTITIES OF    ZBSH_VN_travel IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD calculateTotalPrice.
    "Call the internal action which you created as reusable action
    MODIFY ENTITIES OF ZBSH_vn_travel IN LOCAL MODE
      ENTITY travel
          EXECUTE reCalcTotalPrice
          FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD validateHeaderData.
    "Step 1: Read the travel data
    READ ENTITIES OF ZBSH_VN_travel IN LOCAL MODE
        ENTITY travel
        FIELDS ( CustomerId AgencyId BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).
    "Step 2: Declare a sorted table for holding customer ids
    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    "Step 3: Extract the unique customer IDs in our table
    customers = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING
                                       customer_id = CustomerId EXCEPT *
     ).
    DELETE customers WHERE customer_id IS INITIAL.
    ""Get the validation done to get all customer ids from db
    ""these are the IDs which are present
    IF customers IS NOT INITIAL.
      SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @customers
      WHERE customer_id = @customers-customer_id
      INTO TABLE @DATA(lt_cust_db).
    ENDIF.
    ""loop at travel data
    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ( ls_travel-CustomerId IS INITIAL OR
           NOT  line_exists(  lt_cust_db[ customer_id = ls_travel-CustomerId ] ) ).
        ""Inform the RAP framework to terminate the create
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %element-customerid = if_abap_behv=>mk-on
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>customer_unkown
                                      customer_id           = ls_travel-CustomerId
                                      severity              = if_abap_behv_message=>severity-error
        )
        ) TO reported-travel.
      ENDIF.

      "Validate Agency ID
      "Delcare a sorted table for holding agency ID
      DATA agency TYPE SORTED TABLE OF /DMO/I_Agency WITH UNIQUE KEY AgencyID.
      "Extract unique egency ID
      agency = CORRESPONDING #(  lt_travel DISCARDING DUPLICATES MAPPING AgencyID = AgencyId EXCEPT * ).
      DELETE agency WHERE AgencyID IS INITIAL.
      IF agency IS NOT INITIAL.
        SELECT FROM /DMO/I_Agency FIELDS AgencyID
        FOR ALL ENTRIES IN @agency
        WHERE AgencyID = @agency-AgencyID
        INTO TABLE @DATA(lt_agency_db).
      ENDIF.
      IF ( ls_travel-AgencyId IS INITIAL OR NOT line_exists(  lt_agency_db[ AgencyID = ls_travel-AgencyId ] ) ).
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %element-AgencyId =  if_abap_behv=>mk-on
                           %msg = NEW /dmo/cm_flight_messages(
                                         textid                = VALUE #( msgid = 'ZBSH_VN_MSG_CLASS' msgno = '002' )
                                         agency_id             = ls_travel-AgencyId
                                         severity              = if_abap_behv_message=>severity-error
           )
           ) TO reported-travel.

      ENDIF.
      IF  ls_travel-begindate IS INITIAL. " Check Begin data and end date intial
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = VALUE #( msgid = 'ZBSH_VN_MSG_CLASS' msgno = '000' )
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = ls_travel-begindate
                                   end_date   = ls_travel-enddate
                                   travel_id  = ls_travel-travelid )
                        %element-begindate   = if_abap_behv=>mk-on
*                        %element-enddate     = if_abap_behv=>mk-on
                     ) TO reported-travel.

      ELSEIF ls_travel-EndDate IS INITIAL.  " Check Begin data and end date intial
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = VALUE #( msgid = 'ZBSH_VN_MSG_CLASS' msgno = '001' )
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = ls_travel-begindate
                                   end_date   = ls_travel-enddate
                                   travel_id  = ls_travel-travelid )
*                        %element-begindate   = if_abap_behv=>mk-on
                        %element-enddate     = if_abap_behv=>mk-on
                     ) TO reported-travel.

      ELSEIF ls_travel-enddate < ls_travel-begindate.  "end_date before begin_date
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = ls_travel-begindate
                                   end_date   = ls_travel-enddate
                                   travel_id  = ls_travel-travelid )
                        %element-begindate   = if_abap_behv=>mk-on
                        %element-enddate     = if_abap_behv=>mk-on
                     ) TO reported-travel.
      ELSEIF ls_travel-begindate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future
        APPEND VALUE #( %tky        = ls_travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-begindate  = if_abap_behv=>mk-on
                        %element-enddate    = if_abap_behv=>mk-on
                      ) TO reported-travel.
      ENDIF.
    ENDLOOP.
    ""Exercise: Validations
    "check if begin and end date is empty

  ENDMETHOD.

  METHOD precheck_create.
    precheck_vivek_reuse(
       EXPORTING
*        entities_u =
          entities_c = entities
       IMPORTING
         reported   = reported-travel
         failed     = failed-travel
          ).
  ENDMETHOD.

  METHOD precheck_update.
    precheck_vivek_reuse(
      EXPORTING
        entities_u = entities
*         entities_c =
      IMPORTING
        reported   = reported-travel
        failed     = failed-travel
    ).
  ENDMETHOD.

  METHOD precheck_vivek_reuse.
    ""Step 1: Data declaration
    DATA: entities  TYPE t_entity_update,
          operation TYPE if_abap_behv=>t_char01,
          agencies  TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id,
          customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    ""Step 2: Check either entity_c was passed or entity_u was passed
    ASSERT NOT ( entities_c IS INITIAL EQUIV entities_u IS INITIAL ).
    ""Step 3: Perform validation only if agency OR customer was changed
    IF entities_c IS NOT INITIAL.
      entities = CORRESPONDING #( entities_c ).
      operation = if_abap_behv=>op-m-create.
    ELSE.
      entities = CORRESPONDING #( entities_u ).
      operation = if_abap_behv=>op-m-update.
    ENDIF.
    DELETE entities WHERE %control-AgencyId = if_abap_behv=>mk-off AND %control-CustomerId = if_abap_behv=>mk-off.
    ""Step 4: get all the unique agencies and customers in a table
    agencies = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).
    customers = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    ""Step 5: Select the agency and customer data from DB tables
    SELECT FROM /dmo/agency FIELDS agency_id, country_code
    FOR ALL ENTRIES IN @agencies WHERE agency_id = @agencies-agency_id
    INTO TABLE @DATA(agency_country_codes).
    SELECT FROM /dmo/customer FIELDS customer_id, country_code
    FOR ALL ENTRIES IN @customers WHERE customer_id = @customers-customer_id
    INTO TABLE @DATA(customer_country_codes).
    ""Step 6: Loop at incoming entities and compare each agency and customer country
    LOOP AT entities INTO DATA(entity).
      READ TABLE agency_country_codes WITH KEY agency_id = entity-AgencyId INTO DATA(ls_agency).
      CHECK sy-subrc = 0.
      READ TABLE customer_country_codes WITH KEY customer_id = entity-CustomerId INTO DATA(ls_customer).
      CHECK sy-subrc = 0.
      IF ls_agency-country_code <> ls_customer-country_code.
        ""Step 7: if country doesnt match, throw the error
        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                                  %is_draft = entity-%is_draft
                                  %fail-cause = if_abap_behv=>cause-conflict
          ) TO failed.
        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                                  %is_draft = entity-%is_draft
                                  %msg = NEW /dmo/cm_flight_messages(
                                                                                          textid                = VALUE #(
                                                                                                                                 msgid = 'SY'
                                                                                                                                 msgno = 499
                                                                                                                                 attr1 = 'The country codes for agency and customer not matching'
                                                                                                                              )
                                                                                          agency_id             = entity-AgencyId
                                                                                          customer_id           = entity-CustomerId
                                                                                          severity  = if_abap_behv_message=>severity-error
                                                                                        )
                                  %element-agencyid = if_abap_behv=>mk-on
          ) TO reported.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
