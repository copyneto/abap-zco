CLASS lhc_ZI_CO_OKB9 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_co_okb9 RESULT result.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_co_okb9~authoritycreate.

ENDCLASS.

CLASS lhc_ZI_CO_OKB9 IMPLEMENTATION.

  METHOD get_authorizations.

    READ ENTITIES OF zi_co_okb9 IN LOCAL MODE
        ENTITY zi_co_okb9
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    DATA: lv_update TYPE if_abap_behv=>t_xflag,
          lv_delete TYPE if_abap_behv=>t_xflag.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclco_auth_zcobukrs=>bukrs_update( <fs_data>-bukrs ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

        IF zclco_auth_zcobukrs=>bukrs_delete( <fs_data>-bukrs ).
          lv_delete = if_abap_behv=>auth-allowed.
        ELSE.
          lv_delete = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky = <fs_data>-%tky
                      %update = lv_update
                      %delete = lv_delete )
             TO result.

    ENDLOOP.

  ENDMETHOD.

    METHOD authorityCreate.

      CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

      READ ENTITIES OF zi_co_okb9 IN LOCAL MODE
          ENTITY zi_co_okb9
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_data).

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        IF zclco_auth_zcobukrs=>bukrs_create( <fs_data>-bukrs ) EQ abap_false.

          APPEND VALUE #( %tky        = <fs_data>-%tky
                          %state_area = lc_area )
          TO reported-zi_co_okb9.

          APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-zi_co_okb9.

          APPEND VALUE #( %tky        = <fs_data>-%tky
                          %state_area = lc_area
                          %msg        = NEW zcxca_authority_check(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = zcxca_authority_check=>gc_create )
                          %element-bukrs = if_abap_behv=>mk-on )
            TO reported-zi_co_okb9.
        ENDIF.

      ENDLOOP.

    ENDMETHOD.

ENDCLASS.
