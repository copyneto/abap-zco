class ZCLCO_MERCANET_COPA definition
  public
  final
  create public .

public section.

  methods CREATE_COPA
    importing
      !IT_LANC_COPA type ZCTGCO_POST_COPA optional .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCLCO_MERCANET_COPA IMPLEMENTATION.


  METHOD create_copa.

    DATA: lt_inputdata TYPE STANDARD TABLE OF bapi_copa_data,
          lt_fieldlist TYPE STANDARD TABLE OF bapi_copa_field,
          lt_return    TYPE STANDARD TABLE OF bapiret2.

    DATA: ls_inputdata TYPE bapi_copa_data.

    DATA: lv_cont  TYPE rke_record_id,
          lv_tabix TYPE sy-tabix.

    CONSTANTS: lc_erkrs  TYPE tkeb-erkrs    VALUE 'AR3C',
               lc_curr   TYPE rke_rec_waers VALUE 'BRL',
               lc_error  TYPE sy-msgty      VALUE 'E',
               lc_field1 TYPE rke_field     VALUE 'BUDAT',
               lc_field2 TYPE rke_field     VALUE 'WERKS',
               lc_field3 TYPE rke_field     VALUE 'WWMT1',
               lc_field4 TYPE rke_field     VALUE 'WWRPS',
               lc_field5 TYPE rke_field     VALUE 'VTWEG',
               lc_field6 TYPE rke_field     VALUE 'BZIRK',
               lc_field7 TYPE rke_field     VALUE 'WWREP',
               lc_field8 TYPE rke_field     VALUE 'VV004'.

    SELECT SINGLE erkrs
      FROM tkeb
     WHERE erkrs = @lc_erkrs
      INTO @DATA(lv_concern).

    IF sy-subrc IS INITIAL.

      FREE: lt_inputdata[],
            lt_fieldlist[],
            lt_return[].

      CLEAR: lv_cont.

      DATA(lt_lanc_copa) = it_lanc_copa[].

      DATA: lv_valor(30) TYPE c,
            lv_data(10)  TYPE c.

      LOOP AT lt_lanc_copa ASSIGNING FIELD-SYMBOL(<fs_copa>) FROM lv_tabix.

        lv_cont  = lv_cont + 1.

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field1
                                                    value     = <fs_copa>-budat
                                                    currency  = lc_curr ) ).

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field2
                                                    value     = <fs_copa>-werks
                                                    currency  = lc_curr ) ).

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field3
                                                    value     = <fs_copa>-wwmt1
                                                    currency  = lc_curr ) ).

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs_copa>-wwrps
          IMPORTING
            output = <fs_copa>-wwrps.

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field4
                                                    value     = <fs_copa>-wwrps
                                                    currency  = lc_curr ) ).

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field5
                                                    value     = <fs_copa>-vtweg
                                                    currency  = lc_curr ) ).

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field6
                                                    value     = <fs_copa>-bzirk
                                                    currency  = lc_curr ) ).

        lv_data = <fs_copa>-wwrep.

        REPLACE ALL OCCURRENCES OF '-' IN lv_data WITH space .

        CONDENSE lv_data NO-GAPS.

        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_cont
                                                    fieldname = lc_field7
                                                    value     = lv_data
                                                    currency  = lc_curr ) ).

        ls_inputdata-record_id = lv_cont.
        ls_inputdata-fieldname = lc_field8.
        lv_valor = <fs_copa>-vv004.
        CONDENSE lv_valor NO-GAPS.
        ls_inputdata-value     = lv_valor.
*        CONDENSE ls_inputdata NO-GAPS.
        ls_inputdata-currency  = lc_curr.
        APPEND ls_inputdata TO lt_inputdata.
        CLEAR ls_inputdata.

        ls_inputdata-record_id = lv_cont.
        ls_inputdata-fieldname = 'VRGAR'.
        ls_inputdata-value     = 'Z'.
        ls_inputdata-currency  = lc_curr.
        APPEND ls_inputdata TO lt_inputdata.
        CLEAR ls_inputdata.

        ls_inputdata-record_id = lv_cont.
        ls_inputdata-fieldname = 'BUKRS'.

        SELECT SINGLE bukrs
          FROM t001k
          INTO ls_inputdata-value
          WHERE bwkey EQ <fs_copa>-werks.

        ls_inputdata-currency  = lc_curr.
        APPEND ls_inputdata TO lt_inputdata.
        CLEAR ls_inputdata.

      ENDLOOP.

      IF lt_inputdata[] IS NOT INITIAL.

        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field1 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field2 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field3 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field4 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field5 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field6 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field7 ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field8 ) ).

        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = 'VRGAR' ) ).
        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = 'BUKRS' ) ).


        CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
          EXPORTING
            operatingconcern = lv_concern
            testrun          = space
          TABLES
            inputdata        = lt_inputdata
            fieldlist        = lt_fieldlist
            return           = lt_return.

        SORT lt_return BY type.

        READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = lc_error BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
