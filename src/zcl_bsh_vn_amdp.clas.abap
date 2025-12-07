CLASS zcl_bsh_vn_amdp DEFINITION
 PUBLIC
 FINAL
 CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb .
    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS basic_amdp AMDP OPTIONS CLIENT INDEPENDENT READ-ONLY
      IMPORTING VALUE(x)   TYPE i
                VALUE(y)   TYPE i
      EXPORTING
                VALUE(res) TYPE i.
    CLASS-METHODS get_airport AMDP OPTIONS CDS SESSION CLIENT DEPENDENT READ-ONLY
      IMPORTING VALUE(code) TYPE /dmo/airport_id
      EXPORTING
                VALUE(res)  TYPE /dmo/airport_name.
    CLASS-METHODS get_total_sales
        FOR TABLE FUNCTION zbsh_vn_tf_sales.


    CLASS-METHODS get_product_mrp AMDP OPTIONS CDS SESSION CLIENT DEPENDENT READ-ONLY
      IMPORTING VALUE(i_tax) TYPE i
      EXPORTING
                VALUE(otab)  TYPE zbsh_vn_tt_mrp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BSH_VN_AMDP IMPLEMENTATION.


  METHOD basic_amdp BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT .
    --sql script coda
    res := :x + :y;
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    "calling my first amdp of life  🤔
    zcl_bsh_vn_amdp=>get_airport(
      EXPORTING
        code = 'JFK'
      IMPORTING
        res = DATA(res)
    ).
    out->write(
      EXPORTING
        data   = res
*        name   =
*      RECEIVING
*        output =
    ).

    zcl_bsh_vn_amdp=>get_product_mrp(
     EXPORTING
       i_tax = 18
     IMPORTING
       otab  = DATA(itab)
   ).
    out->write(
      EXPORTING
        data   = itab
*        name   =
*      RECEIVING
*        output =
    ).

  ENDMETHOD.


  METHOD get_airport BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
         USING /dmo/airport.
    select name into res from "/DMO/AIRPORT" where airport_id = :code;
  ENDMETHOD.


  METHOD get_product_mrp BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
        USING zbsh_VN_product.
    --declare variables
    declare lv_count integer;
    declare i integer;
    declare lv_mrp bigint;
    declare lv_price_d integer;
    --get all products in a implicit table
    lt_prod = SELECT * FROM zbsh_VN_product;
    --count the records
    lv_count := record_count( :lt_prod );
    --Loop AT each record, calculate the discounted price and ADD tax amount
    for i in 1..:lv_count do
        --calculate the dicounted price
        lv_price_d := :lt_prod.price[i] * ( 100 - :lt_prod.discount[i] ) / 100;
        lv_mrp := lv_price_d * ( 100 + :i_tax ) / 100 ;
        --if the MRP is over 3200 an extra 2%
        if lv_mrp > 3200 then
            lv_mrp := :lv_mrp * 0.98;
        END if;
        --fill the result table append wa to ktab
         :otab.insert( (
                            :lt_prod.product_id[i],
                            :lt_prod.name[i],
                            :lt_prod.category[i],
                            :lt_prod.price[i],
                            :lv_price_d,
                            :lv_mrp
                        ) , i );
    END FOR ;
  ENDMETHOD.


  METHOD get_total_sales
BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
   USING zbsh_VN_bpa1 zbsh_VN_so_hdr.
    RETURN select bpa.client,
           bpa.company_name,
           sum( so.gross_amount ) as total_sales,
           so.currency_code as currency_code,
           rank(  ) over ( order by sum( so.gross_amount ) desc )  as customer_rank
            from zbsh_VN_bpa1 as bpa
            inner join zbsh_VN_so_hdr as so
            on bpa.bp_id = so.buyer
            group by bpa.client,
                     bpa.company_name, so.currency_code;

  endmethod.
ENDCLASS.
