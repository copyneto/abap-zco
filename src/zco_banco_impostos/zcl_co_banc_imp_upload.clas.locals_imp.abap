CLASS lcl_BancImpUpload DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_bc_status,
        succs_pc TYPE c LENGTH 2  VALUE '01', " Processado
        succs_rv TYPE c LENGTH 2  VALUE '02', " Estornado
        error_pc TYPE c LENGTH 2  VALUE '03', " Erro ao Processar
        error_rv TYPE c LENGTH 2  VALUE '04', " Erro ao Estornar
        in_procs TYPE c LENGTH 2  VALUE '05', " Em processamento
        in_rever TYPE c LENGTH 2  VALUE '06', " Em estorno
      END OF gc_bc_status,

      BEGIN OF gc_item_status,
        succs_pc TYPE c LENGTH 2  VALUE '01', " Item Ok
        error_pc TYPE c LENGTH 2  VALUE '02', " Item com Erro
        in_procs TYPE c LENGTH 2  VALUE '03', " Item em Processamento
      END OF gc_item_status.

    CONSTANTS:
      BEGIN OF gc_queue,
        process      TYPE trfcqout-qname VALUE 'BANCO_IMPOSTOS_PROCESS', " Fila de reprocessamento
        reverse      TYPE trfcqout-qname VALUE 'BANCO_IMPOSTOS_REVERSE', " File de estorno
        task_process TYPE trfcqout-qname VALUE 'BANCIMP_PR', " Task de reprocessamento
        task_reverse TYPE trfcqout-qname VALUE 'BANCIMP_RE', " Task de estorno
      END OF gc_queue.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK BancImpUpload.

    METHODS read FOR READ
      IMPORTING keys FOR READ BancImpUpload RESULT result.

    METHODS rba_BancImpProcess FOR READ
      IMPORTING keys_rba FOR READ BancImpUpload\_BancImpProcess FULL result_requested RESULT result LINK association_links.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE BancImpUpload.

    METHODS cba_BancImpProcess FOR MODIFY
      IMPORTING entities_cba FOR CREATE BancImpUpload\_BancImpProcess.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE BancImpUpload.

    METHODS toProcessUpload FOR MODIFY
      IMPORTING keys FOR ACTION BancImpUpload~toProcessUpload.

    METHODS ProcessData FOR MODIFY
      IMPORTING keys FOR ACTION BancImpUpload~ProcessData.

    METHODS toReverse FOR MODIFY
      IMPORTING keys FOR ACTION BancImpUpload~toReverse RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR BancImpUpload RESULT result.

ENDCLASS.

CLASS lcl_BancImpUpload IMPLEMENTATION.

  METHOD lock.

    TYPES: ty_t_seq TYPE TABLE OF seqg3 WITH DEFAULT KEY.

    DATA: lt_seq TYPE REF TO ty_t_seq.

    CREATE DATA lt_seq.

    "---Recupera classe de bloqueio da tabela
    TRY.
        DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZTCO_BANC_IM_UP' ).
      CATCH cx_abap_lock_failure.
        "handle exception
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>) WHERE Guid <> '00000000000000000000000000000000' "#EC CI_STDSEQ
     GROUP BY <fs_key>-Guid.

      "---Verifica bloqueio para não colidir lançamento simultâneo
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient = sy-mandt
          gname   = CONV seqg3-gname( |ZTCO_BANC_IMP_UP| )
          garg    = CONV seqg3-garg( |{ sy-mandt }{ <fs_key>-Guid }| )
          guname  = '*'
        TABLES
          enq     = lt_seq->*
                    EXCEPTIONS
                    communication_failure
                    system_failure.

      IF  lt_seq->* IS INITIAL
      AND sy-subrc  IS INITIAL.

        TRY.

            "Realiza Bloqueio
            TRY.

                lo_lock->enqueue(
                it_parameter = VALUE #( ( name = 'MANDT' value = REF #( sy-mandt ) )
                                        ( name = 'GUID'  value = REF #( <fs_key>-Guid ) ) )
                ).

              CATCH cx_abap_lock_failure INTO DATA(lo_exce).


                "---Marca objeto como incorreto
                APPEND VALUE #( Guid = <fs_key>-Guid ) TO failed-bancimpupload.

                "---Reporta mensagem de erro
                APPEND VALUE #( Guid = <fs_key>-Guid
                %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text     = |{ lo_exce->get_longtext(  ) }|
                       )
                ) TO reported-bancimpupload.

            ENDTRY.

            "---Indica que objeto está bloqueado
          CATCH cx_abap_foreign_lock INTO DATA(lo_foreign_lock).

            "---Marca objeto como incorreto
            APPEND VALUE #( Guid = <fs_key>-Guid ) TO failed-bancimpupload.

            "---Reporta mensagem de erro
            APPEND VALUE #( Guid = <fs_key>-Guid
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |{ lo_foreign_lock->get_longtext(  ) }|
                   )
            ) TO reported-bancimpupload.

        ENDTRY.

      ELSE.

        IF NOT line_exists( lt_seq->*[ guname = sy-uname ] ). "#EC CI_STDSEQ
          "---Marca objeto como incorreto
          APPEND VALUE #( Guid = <fs_key>-Guid ) TO failed-bancimpupload.

          "---Objeto Bloqueado
          APPEND VALUE #( Guid = <fs_key>-Guid
          %msg = new_message(
                   id       = 'ZCO_BANCO_IMPOSTOS'
                   number   = '001'
                   severity = if_abap_behv_message=>severity-error
                 )
          ) TO reported-bancimpupload.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    "---Tabelas
    DATA: lt_upload TYPE TABLE OF zi_co_banc_imp_upload.

    "---Variáveis
    DATA: lr_guid TYPE RANGE OF zi_co_banc_imp_upload-Guid.

    "---Seleção
    DATA: lt_fields     TYPE TABLE OF char100.

    "---Field-Symbols
    FIELD-SYMBOLS: <fs_field> LIKE LINE OF lt_fields.

    "---Campos
    DEFINE insert_field.

      IF &1 <> |00|.

          APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

          <fs_field> = &2.

      ENDIF.

    END-OF-DEFINITION.

    lr_guid = VALUE #( FOR ls_key IN keys ( option = 'EQ'
                                            sign   = 'I'
                                            low    = ls_key-Guid ) ).

    "---Pega campos solicitados
    TRY.
        DATA(ls_key_fields) = keys[ 1 ].
      CATCH cx_root.
    ENDTRY.

    "---Campo chave
    APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

    <fs_field> = |GUID|.

    "---Outros campos solicitados
    insert_field ls_key_fields-%control-FileDirectory ',FileDirectory'.
    insert_field ls_key_fields-%control-Status        ',Status'.
    insert_field ls_key_fields-%control-CreatedBy     ',CreatedBy'.
    insert_field ls_key_fields-%control-CreatedAt     ',CreatedAt'.
    insert_field ls_key_fields-%control-LastChangedBy ',LastChangedBy'.
    insert_field ls_key_fields-%control-LastChangedAt ',LastChangedAt'.

    CHECK lr_guid[] IS NOT INITIAL.

    SELECT FROM zi_co_banc_imp_upload
      FIELDS (lt_fields)
      WHERE Guid IN @lr_guid
      INTO CORRESPONDING FIELDS OF TABLE @lt_upload.

    result = CORRESPONDING #( lt_upload ).

  ENDMETHOD.

  METHOD rba_BancImpProcess.

    "---Tabelas
    DATA: lt_process TYPE TABLE OF zi_co_banc_imp_process.

    "---Variáveis
    DATA: lr_guid TYPE RANGE OF zi_co_banc_imp_upload-Guid.

    "---Seleção
    DATA: lt_fields     TYPE TABLE OF char100.

    "---Field-Symbols
    FIELD-SYMBOLS: <fs_field> LIKE LINE OF lt_fields.

    "---Campos
    DEFINE insert_field.

      IF &1 <> |00|.

          APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

          <fs_field> = &2.

      ENDIF.

    END-OF-DEFINITION.

    lr_guid = VALUE #( FOR ls_key IN keys_rba ( option = 'EQ'
                                                sign   = 'I'
                                                low    = ls_key-Guid ) ).

    "---Pega campos solicitados
    TRY.
        DATA(ls_key_fields) = keys_rba[ 1 ].
      CATCH cx_root.
    ENDTRY.

    "---Campos chaves
    APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

    <fs_field> = |GUID|.

    APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.

    <fs_field> = |,GuidItem|.

    "---Outros campos solicitados
    insert_field ls_key_fields-%control-CompanyCode    ',CompanyCode'.
    insert_field ls_key_fields-%control-Division       ',Division'.
    insert_field ls_key_fields-%control-SheetLine      ',SheetLine'.
    insert_field ls_key_fields-%control-FbDocument     ',FbDocument'.
    insert_field ls_key_fields-%control-FbYear         ',FbYear'.
    insert_field ls_key_fields-%control-FbDocument2    ',FbDocument2'.
    insert_field ls_key_fields-%control-FbYear2        ',FbYear2'.
    insert_field ls_key_fields-%control-FbDocument3    ',FbDocument3'.
    insert_field ls_key_fields-%control-FbYear3        ',FbYear3'.
    insert_field ls_key_fields-%control-MrDocument     ',MrDocument'.
    insert_field ls_key_fields-%control-MrYear         ',MrYear'.
    insert_field ls_key_fields-%control-MrDocument2    ',MrDocument2'.
    insert_field ls_key_fields-%control-MrYear2        ',MrYear2'.
    insert_field ls_key_fields-%control-MrDocument3    ',MrDocument3'.
    insert_field ls_key_fields-%control-MrYear3        ',MrYear3'.
    insert_field ls_key_fields-%control-CpDocument     ',CpDocument'.
    insert_field ls_key_fields-%control-CpYear         ',CpYear'.

    insert_field ls_key_fields-%control-FbDocumentRev  ',FbDocumentRev'.
    insert_field ls_key_fields-%control-FbYearRev      ',FbYearRev'.
    insert_field ls_key_fields-%control-FbDocumentRev2 ',FbDocumentRev2'.
    insert_field ls_key_fields-%control-FbYearRev2     ',FbYearRev2'.
    insert_field ls_key_fields-%control-FbDocumentRev3 ',FbDocumentRev3'.
    insert_field ls_key_fields-%control-FbYearRev3     ',FbYearRev3'.
    insert_field ls_key_fields-%control-MrDocumentRev  ',MrDocumentRev'.
    insert_field ls_key_fields-%control-MrYearRev      ',MrYearRev'.
    insert_field ls_key_fields-%control-MrDocumentRev2 ',MrDocumentRev2'.
    insert_field ls_key_fields-%control-MrYearRev2     ',MrYearRev2'.
    insert_field ls_key_fields-%control-MrDocumentRev3 ',MrDocumentRev3'.
    insert_field ls_key_fields-%control-MrYearRev3     ',MrYearRev3'.
    insert_field ls_key_fields-%control-CpDocumentRev  ',CpDocumentRev'.
    insert_field ls_key_fields-%control-CpYearRev      ',CpYearRev'.

    CHECK lr_guid[] IS NOT INITIAL.

    SELECT FROM zi_co_banc_imp_process
      FIELDS (lt_fields)
      WHERE Guid IN @lr_guid
      INTO CORRESPONDING FIELDS OF TABLE @lt_process.

    result = CORRESPONDING #( lt_process ).

  ENDMETHOD.

  METHOD create.

    "---Variáveis
    DATA: ls_upload TYPE ztco_banc_imp_up.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_up>).

      "---Recupera dados
      ls_upload = CORRESPONDING #( <fs_up> MAPPING FROM ENTITY USING CONTROL ).

      INSERT ztco_banc_imp_up FROM ls_upload.       "#EC CI_IMUD_NESTED

      IF sy-subrc IS NOT INITIAL.

        "---Marca objeto como incorreto
        APPEND VALUE #( Guid = <fs_up>-Guid ) TO failed-bancimpupload.

        "---Erro ao salvar os dados - tab ZTCO_BANC_IMP_UP
        APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = TEXT-e01 )
                      ) TO reported-bancimpupload.
        RETURN.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_BancImpProcess.

    "---Variáveis
    DATA: ls_process TYPE ztco_banc_imp_pc.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_up>).

      DATA(lv_guid) = <fs_up>-Guid.

      LOOP AT <fs_up>-%target ASSIGNING FIELD-SYMBOL(<fs_pc>). "#EC CI_NESTED

        "---Recupera dados
        ls_process = CORRESPONDING #( <fs_pc> MAPPING FROM ENTITY USING CONTROL ) .

        INSERT ztco_banc_imp_pc FROM ls_process.    "#EC CI_IMUD_NESTED

        IF sy-subrc IS NOT INITIAL.

          "---Marca objeto como incorreto
          APPEND VALUE #( Guid = lv_guid ) TO failed-bancimpupload.

          "---Erro ao salvar os dados - tab ZTCO_BANC_IMP_PC
          APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = TEXT-e02 )
                        ) TO reported-bancimpupload.
          RETURN.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    "---Variáveis
    DATA: ls_upload  TYPE ztco_banc_imp_up.

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

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_up>).

      CLEAR lt_set.

      ls_upload = CORRESPONDING #( <fs_up> MAPPING FROM ENTITY USING CONTROL ).

      APPEND INITIAL LINE TO lt_set ASSIGNING <fs_set>.

      insert_set <fs_up>-%control-LastChangedAt 'LAST_CHANGED_AT = LS_UPLOAD-LAST_CHANGED_AT'.
      insert_set <fs_up>-%control-LastChangedBy 'LAST_CHANGED_BY = LS_UPLOAD-LAST_CHANGED_BY'.
      insert_set <fs_up>-%control-Status        'STATUS = LS_UPLOAD-STATUS'.

      UPDATE ztco_banc_imp_up SET (lt_set) WHERE guid = <fs_up>-guid. "#EC CI_IMUD_NESTED

      IF sy-subrc IS NOT INITIAL.

        "---Marca objeto como incorreto
        APPEND VALUE #( Guid = <fs_up>-Guid ) TO failed-bancimpupload.

        "---Erro ao salvar os dados - tab ZTCO_BANC_IMP_UP
        APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = TEXT-e01 )
                      ) TO reported-bancimpupload.
        RETURN.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD toProcessUpload.

    "---Executa ação de salvar dados e a execução do processo
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
    ENTITY BancImpUpload
        EXECUTE ProcessData
         FROM CORRESPONDING #( keys )
    REPORTED DATA(lt_save_reported)
    FAILED   DATA(lt_save_failed).

    reported = CORRESPONDING #( DEEP lt_save_reported ).
    failed   = CORRESPONDING #( DEEP lt_save_failed ).

  ENDMETHOD.

  METHOD toReverse.

    "---Variáveis
    DATA: lr_status TYPE RANGE OF char2,
          lr_guid   TYPE RANGE OF sysuuid_x16.

    "---Recupera linhas selecionadas
    READ ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload
        FIELDS ( Guid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data_to_reverse)
      FAILED failed
      REPORTED reported.

    CHECK lt_data_to_reverse IS NOT INITIAL.

    "---Status permitido
    lr_status = VALUE #( ( option = 'EQ'
                           sign   = 'I'
                           low    = gc_bc_status-succs_pc )
                         ( option = 'EQ'
                           sign   = 'I'
                           low    = gc_bc_status-error_rv ) ).

    DELETE lt_data_to_reverse WHERE Status
                                NOT IN lr_status[]. "#EC CI_STDSEQ

    IF lt_data_to_reverse IS INITIAL.

      TRY.

          "---Marca objeto como incorreto
          APPEND VALUE #( Guid = keys[ 1 ]-Guid ) TO failed-bancimpupload.

          "---Linha já em estorno, favor atualizar a página...
          APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = TEXT-e04 )
                        ) TO reported-bancimpupload.
          RETURN.

        CATCH cx_root.
      ENDTRY.

    ENDIF.

    "---Recupera dados
    lr_guid = VALUE #( FOR <fs_up_rv_guid> IN lt_data_to_reverse
                        ( option = 'EQ'
                          sign   = 'I'
                          low    = <fs_up_rv_guid>-Guid ) ).

    "---Selecionando os itens
    READ ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload BY \_BancImpProcess
        FIELDS ( Guid GuidItem StatusItem ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data_to_reverse_itens)
      FAILED failed
      REPORTED reported.

    DELETE lt_data_to_reverse_itens WHERE guid NOT IN lr_guid[]. "#EC CI_STDSEQ

    IF lt_data_to_reverse_itens IS INITIAL.

      TRY.

          "---Marca objeto como incorreto
          APPEND VALUE #( Guid = keys[ 1 ]-Guid ) TO failed-bancimpupload.

          "---Linhas não encontradas para estorno.
          APPEND VALUE #( %msg  = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text     = TEXT-e05 )
                        ) TO reported-bancimpupload.

        CATCH cx_root.
      ENDTRY.

      RETURN.

    ENDIF.

    DATA(lv_times) = VALUE timestamp( ).

    GET TIME STAMP FIELD lv_times.

    "---Modifica o status para status de "Em estorno"
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
     ENTITY BancImpUpload
      UPDATE FIELDS ( Status LastChangedAt LastChangedBy )
      WITH VALUE #( FOR <fs_up> IN lt_data_to_reverse
                     ( %tky          = <fs_up>-%tky
                       Status        = gc_bc_status-in_rever
                       LastChangedAt = lv_times
                       LastChangedBy = sy-uname ) )
      FAILED failed
      REPORTED reported.

    CHECK failed IS INITIAL.

    "---Modifica os itens subsequêntes
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
     ENTITY BancImpProcess
      UPDATE FIELDS ( StatusItem )
      WITH VALUE #( FOR <fs_pc> IN lt_data_to_reverse_itens
                     ( %tky       = <fs_pc>-%tky
                       StatusItem = gc_item_status-in_procs ) )
      FAILED failed
      REPORTED reported.

    CHECK failed IS INITIAL.

    "---Recupera linhas selecionadas com as modificações
    READ ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT lt_data_to_reverse
      REPORTED reported
      FAILED failed.

    CHECK failed IS INITIAL.

    "---Passa resultado
    result = VALUE #( FOR ls_data_to_reverse IN lt_data_to_reverse
                        ( %tky   = ls_data_to_reverse-%tky
                          %param = ls_data_to_reverse ) ).

    LOOP AT lt_data_to_reverse ASSIGNING FIELD-SYMBOL(<fs_rv_up>).

      "---Cria Fila do processo e executa ação
      DATA(lv_task) = |{ gc_queue-task_reverse }{ sy-datum }{ sy-uzeit }{ sy-tabix }|.

      CALL FUNCTION 'ZFMCO_BANCO_IMPOSTOS_TASK_PR'
        STARTING NEW TASK lv_task
        EXPORTING
          iv_qname      = gc_queue-reverse
          iv_sheet_guid = <fs_rv_up>-Guid
          iv_reverse    = abap_true.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_features.

    "---Recupera linhas selecionadas
    READ ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload
        FIELDS ( Guid Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upload)
      FAILED failed
      REPORTED reported.

    result = VALUE #( FOR ls_upload IN lt_upload ( %tky              = ls_upload-%tky
                                                   %action-toReverse = COND #( WHEN ls_upload-Status = gc_bc_status-succs_pc
                                                                                 OR ls_upload-Status = gc_bc_status-error_rv
                                                                                THEN if_abap_behv=>fc-o-enabled
                                                                                ELSE if_abap_behv=>fc-o-disabled )
                     ) ).

  ENDMETHOD.

  METHOD processdata.

    "Tabelas internas
    DATA: lt_banc_imp_pc TYPE TABLE OF ztco_banc_imp_pc,
          lt_banc_imp_lg TYPE TABLE OF ztco_banc_imp_lg.

    "Estruturas
    DATA: ls_data TYPE zsco_banco_impostos_data.


    DATA(lv_times) = VALUE timestamp( ).

    GET TIME STAMP FIELD lv_times.

    "Obtendo o primeiro registro para preenchimento dos campos do Header
    DATA(ls_key) = keys[ 1 ].


    "Preenchendo o Header
    TRY.

        DATA(ls_banc_imp_up) = VALUE ztco_banc_imp_up(  guid            = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( )
                                                        filedirectory   = ls_key-%param-filedirectory
                                                        status          = gc_bc_status-in_procs "Em processamento
                                                        created_by      = sy-uname
                                                        created_at      = lv_times
                                                        last_changed_by = sy-uname
                                                        last_changed_at = lv_times ).

        ls_data-header = CORRESPONDING #( ls_banc_imp_up ).

      CATCH cx_uuid_error INTO DATA(lo_uuid_error).

    ENDTRY.

    "Preenchendo os Itens
    TRY.
        LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_s_keys>).
          DATA(lv_index) = sy-tabix.

          APPEND INITIAL LINE TO lt_banc_imp_pc ASSIGNING FIELD-SYMBOL(<fs_s_banc_imp_pc>).

          <fs_s_banc_imp_pc>-guid     = ls_banc_imp_up-guid.
          <fs_s_banc_imp_pc>-guiditem = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
          <fs_s_banc_imp_pc>-bukrs    = <fs_s_keys>-%param-empresa.
          <fs_s_banc_imp_pc>-gsber    = <fs_s_keys>-%param-divisao.
          <fs_s_banc_imp_pc>-line     = lv_index.
          <fs_s_banc_imp_pc>-status   = gc_item_status-in_procs. "Item em Processamento

          APPEND INITIAL LINE TO ls_data-item ASSIGNING FIELD-SYMBOL(<fs_s_item>).

          MOVE-CORRESPONDING <fs_s_banc_imp_pc> TO <fs_s_item>.
          MOVE-CORRESPONDING <fs_s_keys>-%param TO <fs_s_item>.

          <fs_s_item>-line  = lv_index.
          <fs_s_item>-bukrs = <fs_s_keys>-%param-empresa.
          <fs_s_item>-gsber = <fs_s_keys>-%param-divisao.

          APPEND INITIAL LINE TO lt_banc_imp_lg ASSIGNING FIELD-SYMBOL(<fs_s_banc_imp_lg>).

          GET TIME STAMP FIELD lv_times.

          <fs_s_banc_imp_lg>-guid       = <fs_s_banc_imp_pc>-guid.
          <fs_s_banc_imp_lg>-guiditem   = <fs_s_banc_imp_pc>-guiditem.
          <fs_s_banc_imp_lg>-guidmsg    = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
          <fs_s_banc_imp_lg>-created_at = lv_times.
          <fs_s_banc_imp_lg>-message    = TEXT-s02. "Registro salvo no S/4HANA. Aguardando processamento.
          <fs_s_banc_imp_lg>-type       = 'S'.

        ENDLOOP.
      CATCH cx_uuid_error INTO lo_uuid_error.

    ENDTRY.

    "---Criação do registro excel
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload
      CREATE
      FIELDS ( Guid FileDirectory Status CreatedAt CreatedBy LastChangedAt LastChangedBy  )
      WITH VALUE #( ( %key          = VALUE #( Guid = ls_banc_imp_up-guid )
                      FileDirectory = ls_banc_imp_up-filedirectory
                      Status        = ls_banc_imp_up-status
                      CreatedAt     = ls_banc_imp_up-created_at
                      CreatedBy     = ls_banc_imp_up-created_by
                      LastChangedAt = ls_banc_imp_up-last_changed_at
                      LastChangedBy = ls_banc_imp_up-last_changed_by ) )

      REPORTED reported
      FAILED failed.

    "---Checa se não houve erro
    CHECK failed IS INITIAL.

    "---Criação de registros dos itens do processo
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpUpload
      CREATE BY \_BancImpProcess
      FIELDS ( Guid GuidItem CompanyCode Division StatusItem SheetLine )
      WITH VALUE #( ( %tky    = VALUE #( Guid = ls_banc_imp_up-guid )
                      %target = VALUE #( FOR <fs_pc> IN lt_banc_imp_pc
                                         ( %key = VALUE #( Guid     = <fs_pc>-guid
                                                           GuidItem = <fs_pc>-guiditem )
                                           CompanyCode = <fs_pc>-bukrs
                                           Division    = <fs_pc>-gsber
                                           StatusItem  = <fs_pc>-status
                                           SheetLine   = <fs_pc>-line ) )
                   ) )
      REPORTED reported
      FAILED failed.

    "---Checa se não houve erro
    CHECK failed IS INITIAL.

    "---Criação de registros de log dos itens
    MODIFY ENTITIES OF zi_co_banc_imp_upload IN LOCAL MODE
      ENTITY BancImpProcess
      CREATE BY \_BancImpLog
      FIELDS ( Guid GuidItem GuidMsg Message Type CreatedAt )
      WITH VALUE #( FOR <fs_pc> IN lt_banc_imp_pc
                    ( %tky    = VALUE #( Guid     = <fs_pc>-guid
                                         GuidItem = <fs_pc>-guiditem )
                      %target = VALUE #( FOR <fs_log> IN lt_banc_imp_lg WHERE ( guiditem = <fs_pc>-guiditem ) "#EC CI_STDSEQ
                                          ( %key = VALUE #( Guid     = <fs_log>-guid
                                                            GuidItem = <fs_log>-guiditem
                                                            GuidMsg  = <fs_log>-guidmsg  )
                                            Message   = <fs_log>-message
                                            Type      = <fs_log>-type
                                            CreatedAt = <fs_log>-created_at ) )
                   ) )
      REPORTED reported
      FAILED failed.

    CHECK failed IS INITIAL.

    "Mensagem de execução de sucesso
    APPEND VALUE #( guid            = ls_banc_imp_up-guid
                    %msg            = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                             text     = TEXT-s01 ) "Planilha importada com sucesso
                  ) TO reported-bancimpupload.

    "---Cria Fila do processo e executa ação
    DATA(lv_task) = |{ gc_queue-task_process }{ sy-datum }{ sy-uzeit }|.

    CALL FUNCTION 'ZFMCO_BANCO_IMPOSTOS_TASK_PR'
      STARTING NEW TASK lv_task
      EXPORTING
        iv_qname = gc_queue-process
        is_data  = ls_data.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_ZI_CO_BANC_IMP_UPLOAD DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_ZI_CO_BANC_IMP_UPLOAD IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
