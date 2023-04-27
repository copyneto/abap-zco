FUNCTION zfmco_banco_impostos.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_SHEET_GUID) TYPE  SYSUUID_X16
*"     VALUE(IV_REVERSE) TYPE  FLAG
*"     VALUE(IS_DATA) TYPE  ZSCO_BANCO_IMPOSTOS_DATA
*"----------------------------------------------------------------------


  "----Variáveis
  DATA: lo_main TYPE REF TO zcl_co_process_banc_imp_upload.

  TRY.

      "----Classe de processamento
      CREATE OBJECT lo_main
        EXPORTING
          iv_sheet_guid = iv_sheet_guid
          is_data       = is_data.

      IF iv_reverse = abap_false.

        lo_main->process( ).

      ELSE.

        lo_main->reverse( ).

      ENDIF.

    CATCH zcx_co_process_banc_imp_upload INTO DATA(lo_cx).

      DATA(lt_return) = lo_cx->get_bapi_return( ).

      READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_s_return>) INDEX 1.

      CHECK sy-subrc = 0.

      MESSAGE ID     <fs_s_return>-id
              TYPE   'S'
              NUMBER <fs_s_return>-number WITH <fs_s_return>-message_v1
                                               <fs_s_return>-message_v2
                                               <fs_s_return>-message_v3
                                               <fs_s_return>-message_v4 DISPLAY LIKE 'E'.

  ENDTRY.

ENDFUNCTION.
