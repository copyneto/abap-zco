CLASS lcl_BancImpProcess DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE BancImpProcess.

    METHODS read FOR READ
      IMPORTING keys FOR READ BancImpProcess RESULT result.

    METHODS cba_BancImpLog FOR MODIFY
      IMPORTING entities_cba FOR CREATE BancImpProcess\_BancImpLog.

    METHODS rba_BancImpLog FOR READ
      IMPORTING keys_rba FOR READ BancImpProcess\_BancImpLog FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lcl_BancImpProcess IMPLEMENTATION.

  METHOD update.

    "---Variáveis
    DATA: ls_process  TYPE ztco_banc_imp_pc.

    "---Ajustes
    DATA: lt_set     TYPE TABLE OF char100.

    "---Field-Symbols
    FIELD-SYMBOLS: <fs_set> LIKE LINE OF lt_set.

    "---Campos
    DEFINE insert_set.

      IF &1 <> |00|.

          APPEND INITIAL LINE TO lt_set ASSIGNING <fs_set>.

          <fs_set> = &2.

      ENDIF.

    END-OF-DEFINITION.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_pc>).

      CLEAR lt_set.

      ls_process = CORRESPONDING #( <fs_pc> MAPPING FROM ENTITY USING CONTROL ).

      insert_set <fs_pc>-%control-StatusItem 'STATUS = LS_PROCESS-STATUS'.

      UPDATE ztco_banc_imp_pc SET (lt_set) WHERE guid     = <fs_pc>-guid "#EC CI_IMUD_NESTED
                                             AND guiditem = <fs_pc>-GuidItem.

      IF sy-subrc IS NOT INITIAL.

        "----Marca objeto como incorreto
        APPEND VALUE #( Guid = <fs_pc>-Guid ) TO failed-bancimpupload.

        APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = TEXT-e02 ) "Erro ao salvar os dados na tabela ZTCO_BANC_IMP_PC
                      ) TO reported-bancimpupload.
        RETURN.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    RETURN.
  ENDMETHOD.

  METHOD cba_BancImpLog.

    "---Variáveis
    DATA: ls_log TYPE ztco_banc_imp_lg.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_pc>).

      DATA(lv_guid) = <fs_pc>-Guid.

      LOOP AT <fs_pc>-%target ASSIGNING FIELD-SYMBOL(<fs_log>). "#EC CI_NESTED

        "---Recupera dados
        ls_log = CORRESPONDING #( <fs_log> MAPPING FROM ENTITY USING CONTROL ) .

        INSERT ztco_banc_imp_lg FROM ls_log.        "#EC CI_IMUD_NESTED

        IF sy-subrc IS NOT INITIAL.

          "----Marca objeto como incorreto
          APPEND VALUE #( Guid = lv_guid ) TO failed-bancimpupload.

          APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = TEXT-e01 ) "Erro ao salvar os dados na tabela ZTCO_BANC_IMP_LG
                        ) TO reported-bancimpupload.
          RETURN.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_BancImpLog.
    RETURN.
  ENDMETHOD.

ENDCLASS.
