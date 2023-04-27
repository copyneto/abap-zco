CLASS lcl_NFHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF gc_nf_status,
        error_pc TYPE c LENGTH 2  VALUE '02', " Processado com Erro
        in_reprs TYPE c LENGTH 2  VALUE '03', " Reprocessamento
        in_rever TYPE c LENGTH 2  VALUE '04', " A Estornar
        succs_pr TYPE c LENGTH 2  VALUE '05', " Processado com Êxito
        error_rv TYPE c LENGTH 2  VALUE '07', " Erro ao efetuar estorno
      END OF gc_nf_status.

    CONSTANTS:
      BEGIN OF gc_queue,
        reprocess TYPE trfcqout-qname VALUE 'MONITOR_NFS_REPROCESS', " Fila de reprocessamento
        reverse   TYPE trfcqout-qname VALUE 'MONITOR_NFS_REVERSE',   " File de estorno
      END OF gc_queue.

    METHODS toReprocess FOR MODIFY
      IMPORTING keys FOR ACTION NFHeader~toReprocess RESULT result.

    METHODS toReverse FOR MODIFY
      IMPORTING keys FOR ACTION NFHeader~toReverse RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR NFHeader RESULT result.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR NFHeader RESULT result.

    METHODS check_autorization_action
      IMPORTING iv_actvt               TYPE char2
                iv_bukrs               TYPE bukrs
      RETURNING VALUE(rv_autorization) TYPE abap_bool.

    METHODS execute_process
      IMPORTING iv_qname TYPE trfcqout-qname
                iv_actvt TYPE char2
                iv_nf    TYPE j_1bdocnum.

ENDCLASS.

CLASS lcl_NFHeader IMPLEMENTATION.

  METHOD toReprocess.

    "----Recupera linhas selecionadas
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader
        FIELDS ( NFDocument Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_NFs)
      FAILED failed
      REPORTED reported.

    CHECK lt_nfs IS NOT INITIAL.

    "----Recupera Itens
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader BY \_NFItem
        FIELDS ( NFDocument NFItem ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_Itens)
      FAILED failed
      REPORTED reported.

    "----Executa modificação no status
    LOOP AT lt_nfs REFERENCE INTO DATA(lo_nf).

      "----Modifica o status
      MODIFY ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
       ENTITY NFHeader
        UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky   = lo_nf->%tky
                        Status = gc_nf_status-in_reprs ) )
        FAILED failed
        REPORTED DATA(lt_reported).

    ENDLOOP.

    "----Modifica os itens subsequêntes
    LOOP AT lt_itens REFERENCE INTO DATA(lo_item).

      MODIFY ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
       ENTITY NFItem
        UPDATE FIELDS ( LastUserChange LastDateChange LastTimeChange MessageTextInfor )
        WITH VALUE #( ( %tky             = lo_item->%tky
                        LastUserChange   = sy-uname
                        LastDateChange   = sy-datum
                        LastTimeChange   = sy-uzeit
                        MessageTextInfor = TEXT-p01 ) )
        FAILED failed
        REPORTED DATA(lt_reported_item).

    ENDLOOP.

    "----Executa o processamento
    me->execute_process(
      EXPORTING
        iv_qname = gc_queue-reprocess
        iv_actvt = '01'
        iv_nf    = lo_nf->NFDocument
    ).

    "----Recupera linhas selecionadas com as modificações
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader
        FIELDS ( NFDocument Status ) WITH CORRESPONDING #( keys )
      RESULT lt_NFs
      REPORTED reported
      FAILED failed.

    "----Passa resultado
    result = VALUE #( FOR ls_nf IN lt_nfs
                        ( %tky   = ls_nf-%tky
                          %param = ls_nf ) ).

  ENDMETHOD.

  METHOD toReverse.

    "----Recupera linhas selecionadas
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader
        FIELDS ( NFDocument Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_NFs)
      FAILED failed
      REPORTED reported.

    CHECK lt_nfs IS NOT INITIAL.

    "----Recupera Itens
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader BY \_NFItem
        FIELDS ( NFDocument NFItem ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_Itens)
      FAILED failed
      REPORTED reported.

    "----Executa modificação no status
    LOOP AT lt_nfs REFERENCE INTO DATA(lo_nf).

      "----Modifica o status para stauts de "A Estornar"
      MODIFY ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
       ENTITY NFHeader
        UPDATE FIELDS ( Status )
        WITH VALUE #( ( %tky   = lo_nf->%tky
                        Status = gc_nf_status-in_rever ) )
        FAILED failed
        REPORTED DATA(lt_reported).

    ENDLOOP.

    "----Modifica os itens subsequêntes
    LOOP AT lt_itens REFERENCE INTO DATA(lo_item).

      MODIFY ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
       ENTITY NFItem
        UPDATE FIELDS ( LastUserChange LastDateChange LastTimeChange MessageTextInfor )
        WITH VALUE #( ( %tky             = lo_item->%tky
                        LastUserChange   = sy-uname
                        LastDateChange   = sy-datum
                        LastTimeChange   = sy-uzeit
                        MessageTextInfor = TEXT-p01 ) )
        FAILED failed
        REPORTED DATA(lt_reported_item).

    ENDLOOP.

    "----Executa o processamento
    me->execute_process(
      EXPORTING
        iv_qname = gc_queue-reverse
        iv_actvt = '02'
        iv_nf    = lo_nf->NFDocument
    ).

    "----Recupera linhas selecionadas com as modificações
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader
        FIELDS ( NFDocument Status ) WITH CORRESPONDING #( keys )
      RESULT lt_NFs
      REPORTED reported
      FAILED failed.

    "----Passa resultado
    result = VALUE #( FOR ls_nf IN lt_nfs
                      ( %tky   = ls_nf-%tky
                        %param = ls_nf ) ).

  ENDMETHOD.

  METHOD get_features.

    " Verificar os dados em exibição
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
      ENTITY NFHeader
        FIELDS ( CompanyCode Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_NFs)
      FAILED failed.

    "Retornar a ação como habilitada/desabilitada
    result =
        VALUE #(
          FOR ls_nf IN lt_nfs
            LET lv_reprocess = COND #( WHEN ls_nf-Status = '02'
                                        THEN if_abap_behv=>fc-o-enabled
                                        ELSE if_abap_behv=>fc-o-disabled )
                lv_reverse   = COND #( WHEN ls_nf-Status = '05' OR  ls_nf-Status = '07'
                                        THEN if_abap_behv=>fc-o-enabled
                                        ELSE if_abap_behv=>fc-o-disabled )
            IN
              ( %tky                = ls_nf-%tky
                %action-toReprocess = lv_reprocess
                %action-toReverse   = lv_reverse
               ) ).

  ENDMETHOD.

  METHOD check_autorization_action.

    AUTHORITY-CHECK OBJECT 'Z_MR22_BUK'
       ID 'ACTVT' FIELD iv_actvt
       ID 'BUKRS' FIELD iv_bukrs.

    rv_autorization = COND #( WHEN sy-subrc IS INITIAL
                                 THEN abap_true
                              ELSE abap_false ).

  ENDMETHOD.

  METHOD get_authorizations.

    "----Ranges
    DATA: lr_nfs TYPE RANGE OF zi_co_pr_mr22_fb50-NFDocument.

    "----Variáveis
    DATA: lv_actvt(2).

    "----Seleciona linhas exibidas
    READ ENTITIES OF zi_co_monitor_notas_cab IN LOCAL MODE
        ENTITY NFHeader
          FIELDS ( NFDocument CompanyCode Status ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_nfs)
        FAILED failed.

    CHECK lt_nfs IS NOT INITIAL.

    "----Checa ação
    lv_actvt = COND #( WHEN requested_authorizations-%action-toReprocess  = if_abap_behv=>mk-on
                       AND  requested_authorizations-%action-toReverse   <> if_abap_behv=>mk-on
                        THEN '01'
                       WHEN requested_authorizations-%action-toReverse    = if_abap_behv=>mk-on
                       AND  requested_authorizations-%action-toReprocess <> if_abap_behv=>mk-on
                        THEN '02' ).

    CHECK lv_actvt IS NOT INITIAL.

    lr_nfs = VALUE #( FOR <fs_nf> IN lt_nfs
                            ( sign   = 'I'
                              option = 'EQ'
                              low    = <fs_nf>-NFDocument ) ).

    "----Seleciona notas para identificar se estão no período permitido para laçamento/estorno
    SELECT FROM zi_co_pr_mr22_fb50
     FIELDS NFDocument, Status  WHERE NFDocument IN @lr_nfs
     INTO TABLE @DATA(lt_granted).

    LOOP AT lt_nfs REFERENCE INTO DATA(lo_nf).

      "----Checa autorizações
      DATA(lv_rp_granted) = me->check_autorization_action( iv_actvt = '01'
                                                           iv_bukrs = lo_nf->CompanyCode ).

      DATA(lv_rv_granted) = me->check_autorization_action( iv_actvt = '02'
                                                           iv_bukrs = lo_nf->CompanyCode ).

      IF ( lv_actvt = '01'
      AND lv_rp_granted = abap_false )
      OR ( lv_actvt = '02'
      AND lv_rv_granted = abap_false ).

        APPEND VALUE #( %tky = lo_nf->%tky ) TO failed-nfheader.

        "----Sem autorização para efetuar ação.
        APPEND VALUE #( %tky        = lo_nf->%tky
                        %msg        = NEW zcxco_monitor_nfs( iv_severity = if_abap_behv_message=>severity-error
                                                             iv_textid   = zcxco_monitor_nfs=>gc_unauthorized )
                      ) TO reported-nfheader.

      ELSEIF NOT line_exists( lt_granted[ NFDocument = lo_nf->NFDocument ] ). "#EC CI_STDSEQ

        lv_rp_granted = abap_false.
        lv_rv_granted = abap_false.

        APPEND VALUE #( %tky = lo_nf->%tky ) TO failed-nfheader.

        "----Nota está fora do período permitido para lançamento e estorno.
        APPEND VALUE #( %tky        = lo_nf->%tky
                        %msg        = NEW zcxco_monitor_nfs( iv_severity = if_abap_behv_message=>severity-error
                                                             iv_textid   = zcxco_monitor_nfs=>gc_period_not_permited )
                      ) TO reported-nfheader.
      ELSE.

        DATA(lv_status) = lt_granted[ NFDocument = lo_nf->NFDocument ]-Status. "#EC CI_STDSEQ

        IF ( lv_actvt = '01'
         AND lv_status <> gc_nf_status-error_pc )
        OR ( lv_actvt = '02'
         AND lv_status <> gc_nf_status-succs_pr
         AND lv_status <> gc_nf_status-error_rv ).

          lv_rp_granted = abap_false.
          lv_rv_granted = abap_false.

          APPEND VALUE #( %tky = lo_nf->%tky ) TO failed-nfheader.

          "----N.Fiscal está em processamento, favor atualizar para visualizar status.
          APPEND VALUE #( %tky        = lo_nf->%tky
                          %msg        = NEW zcxco_monitor_nfs( iv_severity = if_abap_behv_message=>severity-error
                                                               iv_textid   = zcxco_monitor_nfs=>gc_nf_in_action_pc )
                        ) TO reported-nfheader.

        ENDIF.

      ENDIF.

      "----Resultado
      APPEND VALUE #( %tky = lo_nf->%tky
                      %action-toReprocess = COND #( WHEN lv_rp_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
                      %action-toReverse   = COND #( WHEN lv_rv_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
                    )
        TO result.

    ENDLOOP.


  ENDMETHOD.

  METHOD execute_process.

    "----Cria Fila do processo e executa ação

    DATA(lv_task) = |{ iv_qname }-{ iv_nf }|.

    CALL FUNCTION 'ZFGCO_PR_TASK_PR' STARTING NEW TASK lv_task
      EXPORTING
        iv_qname = iv_qname
        iv_actvt = iv_actvt
        iv_nf    = iv_nf.

  ENDMETHOD.

ENDCLASS.
