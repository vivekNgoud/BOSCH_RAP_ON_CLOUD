@EndUserText.label: 'Calculate total sales with customer rank'
@ClientHandling.clientSafe: true
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
define table function ZBSH_VN_TF_SALES
returns {
 client : abap.clnt;
 company_name : abap.char(256);
 total_sales : abap.curr(15,2);
 currency_code : abap.cuky(5);
 customer_rank : abap.int4  ;
}
implemented by method zcl_bsh_VN_amdp=>get_total_sales;