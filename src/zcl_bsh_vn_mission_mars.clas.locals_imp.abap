*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS zcl_earth DEFINITION.
  PUBLIC SECTION.
    METHODS start_engine RETURNING VALUE(str) TYPE string.
    METHODS leave_orbit RETURNING VALUE(str) TYPE string.
ENDCLASS.
CLASS zcl_earth IMPLEMENTATION.
  METHOD start_engine.
    str = 'Hey Command, we start the count down for lift off'.
  ENDMETHOD.
  METHOD leave_orbit.
    str = 'Moonshot to Intermediate planet'.
  ENDMETHOD.
ENDCLASS.
CLASS zcl_planet1 DEFINITION.
  PUBLIC SECTION.
    METHODS enter_orbit RETURNING VALUE(str) TYPE string.
    METHODS leave_orbit RETURNING VALUE(str) TYPE string.
ENDCLASS.
CLASS zcl_planet1 IMPLEMENTATION.
  METHOD enter_orbit.
    str = 'We are entering the orbit for solar charge'.
  ENDMETHOD.
  METHOD leave_orbit.
    str = 'Moonshot to mars'.
  ENDMETHOD.
ENDCLASS.
CLASS zcl_mars DEFINITION.
  PUBLIC SECTION.
    METHODS enter_orbit RETURNING VALUE(str) TYPE string.
    METHODS explore_mars RETURNING VALUE(str) TYPE string.
ENDCLASS.
CLASS zcl_mars IMPLEMENTATION.
  METHOD enter_orbit.
    str = 'We reached mars'.
  ENDMETHOD.
  METHOD explore_mars.
    str = 'Roger we found the water on mars'.
  ENDMETHOD.
ENDCLASS.
