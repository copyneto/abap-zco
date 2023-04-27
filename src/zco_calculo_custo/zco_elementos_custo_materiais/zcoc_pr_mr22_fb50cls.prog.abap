*&---------------------------------------------------------------------*
*& Include zcoc_pr_mr22_fb50cls
*&---------------------------------------------------------------------*
CLASS lcx_exception IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF iv_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = iv_textid.
    ENDIF.

    me->gv_msgv1 = iv_msgv1.
    me->gv_msgv2 = iv_msgv2.
    me->gv_msgv3 = iv_msgv3.
    me->gv_msgv4 = iv_msgv4.

  ENDMETHOD.

  METHOD get_bapi_return.

    DATA: ls_message LIKE LINE OF rt_return.

    ls_message-type        = 'E'.
    ls_message-id          = if_t100_message~t100key-msgid.
    ls_message-number      = if_t100_message~t100key-msgno.
    IF gv_msgv1 IS NOT INITIAL.
      ls_message-message_v1 = gv_msgv1.
    ELSE.
      ls_message-message_v1 = if_t100_message~t100key-attr1.
      IF ls_message-message_v1 CA 'MSG'.
        CLEAR ls_message-message_v1.
      ENDIF.
    ENDIF.
    IF gv_msgv2 IS NOT INITIAL.
      ls_message-message_v2 = gv_msgv2.
    ELSE.
      ls_message-message_v2 = if_t100_message~t100key-attr2.
      IF ls_message-message_v2 CA 'MSG'.
        CLEAR ls_message-message_v2.
      ENDIF.
    ENDIF.
    IF gv_msgv3 IS NOT INITIAL.
      ls_message-message_v3 = gv_msgv3.
    ELSE.
      ls_message-message_v3 = if_t100_message~t100key-attr3.
      IF ls_message-message_v3 CA 'MSG'.
        CLEAR ls_message-message_v3.
      ENDIF.
    ENDIF.
    IF gv_msgv4 IS NOT INITIAL.
      ls_message-message_v4 = gv_msgv4.
    ELSE.
      ls_message-message_v4 = if_t100_message~t100key-attr4.
      IF ls_message-message_v4 CA 'MSG'.
        CLEAR ls_message-message_v4.
      ENDIF.
    ENDIF.

    APPEND ls_message TO rt_return.
    CLEAR ls_message.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD instance.

    DATA: lr_year TYPE ty_r_periodyear.

    IF p_year IS NOT INITIAL.

      APPEND VALUE #( sign   = 'I'
                      option = 'EQ'
                      low    = p_year  ) TO lr_year.

    ENDIF.

    ro_main = NEW #( iv_monitor     = p_moni
                     iv_actvt       = p_actvt
                     iv_nf          = p_nf
                     ir_companycode = VALUE #( FOR ls_compc IN s_compc[] ( sign   = ls_compc-sign
                                                                           option = ls_compc-option
                                                                           low    = ls_compc-low
                                                                           high   = ls_compc-high )  )
                     ir_periodmonth = VALUE #( FOR ls_mon   IN s_month[] ( sign   = ls_mon-sign
                                                                           option = ls_mon-option
                                                                           low    = ls_mon-low
                                                                           high   = ls_mon-high   )  )
                     ir_periodyear  = lr_year ).

  ENDMETHOD.

  METHOD handle_error.

    DATA(lt_return) = io_cx->get_bapi_return( ).

    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_s_return>) INDEX 1.

    CHECK sy-subrc = 0.

    "Mensagem footer
    IF iv_popup EQ abap_false.

      MESSAGE ID     <fs_s_return>-id
              TYPE   'S'
              NUMBER <fs_s_return>-number WITH <fs_s_return>-message_v1
                                               <fs_s_return>-message_v2
                                               <fs_s_return>-message_v3
                                               <fs_s_return>-message_v4 DISPLAY LIKE 'E'.
    ELSE.

      "Message in pop-up
      CALL FUNCTION 'FB_MESSAGES_DISPLAY_POPUP'
        EXPORTING
          it_return = lt_return.

    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    me->gv_monitor     = iv_monitor.
    me->gv_actvt       = iv_actvt.
    me->gv_nf          = iv_nf.
    me->gr_companycode = ir_companycode.
    me->gr_month       = ir_periodmonth.
    me->gr_year        = ir_periodyear.

  ENDMETHOD.

  METHOD start.

    TRY.

        "----Seleciona notas para o processo
        me->select_data( ).

        "----Realiza bloqueio para evitar duplicidade em caso de execução do monitor
        me->enqueue_nf( ).

        "----Salva/Atualiza dados.
        me->save_data( ).

        "----Executa o processamento
        me->process_data( ).

        "----Salva o resultado do processamento.
        me->save_data( ).

        "----Retira bloqueio em caso de vir do monitor
        me->dequeue_nf( ).

      CATCH lcx_exception INTO DATA(lo_cx).

        RAISE EXCEPTION TYPE lcx_exception
          EXPORTING
            iv_textid = lo_cx->if_t100_message~t100key
            iv_msgv1  = lo_cx->gv_msgv1
            iv_msgv2  = lo_cx->gv_msgv2
            iv_msgv3  = lo_cx->gv_msgv3
            iv_msgv4  = lo_cx->gv_msgv4.

    ENDTRY.

  ENDMETHOD.

  METHOD enqueue_nf.

    TYPES: ty_t_seq TYPE TABLE OF seqg3 WITH DEFAULT KEY.

    DATA: lt_seq TYPE REF TO ty_t_seq.

    CHECK me->gv_monitor = abap_true.

    CREATE DATA lt_seq.

    TRY.

        "----Verifica bloqueio para não colidir lançamento simultâneo
        CALL FUNCTION 'ENQUEUE_READ'
          EXPORTING
            gclient = sy-mandt
            gname   = CONV seqg3-gname( |ZTCO_NOTAS_CAB| )
            garg    = CONV seqg3-garg( |{ sy-mandt }{ me->gv_nf }| )
            guname  = '*'
          TABLES
            enq     = lt_seq->*
                      EXCEPTIONS
                      communication_failure
                      system_failure.

        IF  lt_seq->* IS INITIAL
        AND sy-subrc  IS INITIAL.

          "----Bloqueia registro
          CALL FUNCTION 'ENQUEUE_EZTCO_NOTAS_CAB'
            EXPORTING
              _wait               = abap_true
              mode_ztco_notas_cab = 'S'
              mandt               = sy-mandt
              docnum              = me->gv_nf
            EXCEPTIONS
              foreign_lock        = 1
              system_failure      = 2
              OTHERS              = 3.

          "----Tabela bloqueada
          IF sy-subrc <> 0.

            "----Nota Fiscal está em processamento por outra execução.
            RAISE EXCEPTION TYPE lcx_exception
              EXPORTING
                iv_textid = lcx_exception=>gc_nf_blocked.

          ENDIF.

        ELSE.

          "----Nota Fiscal está em processamento por outra execução.
          RAISE EXCEPTION TYPE lcx_exception
            EXPORTING
              iv_textid = lcx_exception=>gc_nf_blocked.

        ENDIF.

      CATCH cx_root.

        "----Nota Fiscal está em processamento por outra execução.
        RAISE EXCEPTION TYPE lcx_exception
          EXPORTING
            iv_textid = lcx_exception=>gc_nf_blocked.


    ENDTRY.

  ENDMETHOD.

  METHOD dequeue_nf.

    CHECK me->gv_monitor = abap_true.

    TRY.

        "----Retira bloqueio
        CALL FUNCTION 'DEQUEUE_EZTCO_NOTAS_CAB'
          EXPORTING
            _synchron           = abap_true
            mode_ztco_notas_cab = 'S'
            mandt               = sy-mandt
            docnum              = me->gv_nf.

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD select_data.

    DATA: lv_status        TYPE zi_co_pr_mr22_fb50-Status,
          lr_transferencia TYPE RANGE OF j_1bnflin-mwskz,
          lr_entrada       TYPE RANGE OF j_1bnflin-mwskz.

    "----Criação de dados
    CREATE DATA me->gt_nfs.
    CREATE DATA me->gt_ncab.
    CREATE DATA me->gt_nitm.

    IF me->gv_monitor = abap_true.

      "----Seleciona as notas que foram selecionadas para reprocessamento ou estorno no monitor pelo responsável
      SELECT FROM zi_co_pr_mr22_fb50  "#EC CI_SEL_DEL
       FIELDS NFDocument,
              NFItem,
              NFTaxGrp,
              NFTaxTyp,
              TaxValue,
              CompanyCode,
              ReleaseDate,
              PartnerID,
              NFENumber,
              Currency,
              Direction,
              Canceled,
              Center,
              Material,
              Quantity,
              ValuationType,
              EvaluationArea,
              ReferenceKey,
              TaxCode,
              PurchaseOrder,
              PurchaseOrderItem,
              IsAffiliated,
              ReferenceKeyDoc,
              ExecMr22,
              Sign,
              ExecFb50,
              DebitAccount,
              CreditAccount,
              TypeDoc,
              Status,
              AccountingDocument,
              AccountingYear,
              MrDocument,
              MrYear,
              ReversalDocument,
              ReversalYear,
              MrRevDocument,
              MrRevYear,
              LastUserChange,
              LastDateChange,
              LastTimeChange,
              MessageTextInfor,
              TransferCenter
           WHERE NFDocument = @me->gv_nf
           AND Status IS NOT NULL
         INTO TABLE @me->gt_nfs->*.

    ELSE.

      "Determinando IVAs de entrada e de transferência para seleções dos registros
      get_ranges_ivas( IMPORTING er_entrada       = lr_entrada
                                 er_transferencia = lr_transferencia ).

      "----Seleciona as notas que não foram processadas e que podem ser estornadas por cancelamento da nota
      IF lr_entrada IS NOT INITIAL.
        SELECT FROM zi_co_pr_mr22_fb50  "#EC CI_SEL_DEL
         FIELDS NFDocument,
                NFItem,
                NFTaxGrp,
                NFTaxTyp,
                TaxValue,
                CompanyCode,
                ReleaseDate,
                PartnerID,
                NFENumber,
                Currency,
                Direction,
                Canceled,
                Center,
                Material,
                Quantity,
                ValuationType,
                EvaluationArea,
                ReferenceKey,
                TaxCode,
                PurchaseOrder,
                PurchaseOrderItem,
                IsAffiliated,
                ReferenceKeyDoc,
                ExecMr22,
                Sign,
                ExecFb50,
                DebitAccount,
                CreditAccount,
                TypeDoc,
                Status,
                AccountingDocument,
                AccountingYear,
                MrDocument,
                MrYear,
                ReversalDocument,
                ReversalYear,
                MrRevDocument,
                MrRevYear,
                LastUserChange,
                LastDateChange,
                LastTimeChange,
                MessageTextInfor,
                TransferCenter
           WHERE Direction = '1'
             AND ( ( Canceled = @abap_false AND Status IS NULL  )
                OR ( Canceled = @abap_false AND Status = '01'   )
                OR ( Canceled = @abap_true  AND Status = '05'   ) )
             AND CompanyCode IN @me->gr_companycode[]
             AND PeriodMonth IN @me->gr_month[]
             AND PeriodYear  IN @me->gr_year[]
             AND TaxCode     IN @lr_entrada
           INTO TABLE @me->gt_nfs->*.
      ENDIF.

      IF lr_transferencia IS NOT INITIAL.
        SELECT FROM zi_co_pr_mr22_fb50  "#EC CI_SEL_DEL
         FIELDS NFDocument,
                NFItem,
                NFTaxGrp,
                NFTaxTyp,
                TaxValue,
                CompanyCode,
                ReleaseDate,
                PartnerID,
                NFENumber,
                Currency,
                Direction,
                Canceled,
                Center,
                Material,
                Quantity,
                ValuationType,
                EvaluationArea,
                ReferenceKey,
                TaxCode,
                PurchaseOrder,
                PurchaseOrderItem,
                IsAffiliated,
                ReferenceKeyDoc,
                ExecMr22,
                Sign,
                ExecFb50,
                DebitAccount,
                CreditAccount,
                TypeDoc,
                Status,
                AccountingDocument,
                AccountingYear,
                MrDocument,
                MrYear,
                ReversalDocument,
                ReversalYear,
                MrRevDocument,
                MrRevYear,
                LastUserChange,
                LastDateChange,
                LastTimeChange,
                MessageTextInfor,
                TransferCenter
           WHERE Direction = '2'
             AND ( ( Canceled = @abap_false AND Status IS NULL  )
                OR ( Canceled = @abap_false AND Status = '01'   )
                OR ( Canceled = @abap_true  AND Status = '05'   ) )
             AND CompanyCode IN @me->gr_companycode[]
             AND PeriodMonth IN @me->gr_month[]
             AND PeriodYear  IN @me->gr_year[]
             AND TaxCode     IN @lr_transferencia
           APPENDING TABLE @me->gt_nfs->*.
      ENDIF.

    ENDIF.

    IF me->gt_nfs->* IS INITIAL.

      RAISE EXCEPTION TYPE lcx_exception
        EXPORTING
          iv_textid = lcx_exception=>gc_no_data_found.

    ELSE.

      "----Deleta linhas em que haja elemento de custo ELEM24 que o parceiro não seja coligada
      IF me->gv_monitor = abap_false.

        DELETE me->gt_nfs->* WHERE referencekeydoc = 'ELEM24'  "#EC CI_STDSEQ
                               AND isaffiliated    = abap_false.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD save_data.

    IF me->gt_ncab->* IS INITIAL.

      "----Ordenação
      SORT me->gt_nfs->* BY nfdocument NFItem NFTaxGrp NFTaxTyp.

      "----Cabeçalho
      me->gt_ncab->* = VALUE #( FOR ls_nf IN me->gt_nfs->*
                                 ( docnum = ls_nf-nfdocument
                                   bukrs  = ls_nf-companycode
                                   pstdat = ls_nf-releasedate
                                   parid  = ls_nf-partnerid
                                   nfenum = ls_nf-nfenumber
                                   status = COND #( WHEN ls_nf-status IS INITIAL THEN '01' ELSE  ls_nf-status ) ) )."Em Processamento

      DELETE ADJACENT DUPLICATES FROM me->gt_ncab->* COMPARING docnum.

      "----Itens
      me->gt_nitm->* = VALUE #( FOR ls_nf IN me->gt_nfs->*
                                 ( docnum   = ls_nf-nfdocument
                                   itmnum   = ls_nf-nfitem
                                   taxgrp   = ls_nf-nftaxgrp
                                   taxtyp   = ls_nf-nftaxtyp
                                   werks    = COND #( WHEN ls_nf-direction = 2 THEN ls_nf-TransferCenter
                                                      ELSE ls_nf-center )
                                   matnr    = ls_nf-material
                                   bwtar    = ls_nf-valuationtype
                                   taxval   = ls_nf-taxvalue
                                   refkey   = ls_nf-referencekey
                                   mwskz    = ls_nf-taxcode
                                   xped     = ls_nf-purchaseorder
                                   nitemped = ls_nf-purchaseorderitem
                                   xblnr    = ls_nf-referencekeydoc
                                   bln_c_fb = ls_nf-accountingdocument
                                   gjr_c_fb = ls_nf-accountingyear
                                   bln_c_mr = ls_nf-mrdocument
                                   gjr_c_mr = ls_nf-mryear
                                   bln_s_fb = ls_nf-reversaldocument
                                   gjr_s_fb = ls_nf-reversalyear
                                   bln_s_mr = ls_nf-mrrevdocument
                                   gjr_s_mr = ls_nf-mrrevyear
                                   user_mod = ls_nf-LastUserChange
                                   date_mod = ls_nf-LastDateChange
                                   time_mod = ls_nf-LastTimeChange
                                   text_msg = COND #( WHEN ls_nf-MessageTextInfor IS INITIAL THEN TEXT-p03
                                                      ELSE ls_nf-MessageTextInfor ) ) ).

    ENDIF.

    "----Salva dados
    MODIFY ztco_notas_cab FROM TABLE me->gt_ncab->*.

    IF sy-subrc IS INITIAL.

      COMMIT WORK.

    ENDIF.

    "----Salva dados
    MODIFY ztco_notas_itm FROM TABLE me->gt_nitm->*.

    IF sy-subrc IS INITIAL.

      COMMIT WORK.

    ENDIF.

  ENDMETHOD.

  METHOD process_data.

    LOOP AT me->gt_nfs->* REFERENCE INTO DATA(lo_nf)
      GROUP BY lo_nf->NFDocument.

      TRY.

          LOOP AT GROUP lo_nf REFERENCE INTO DATA(lo_gp).

            "----Checa se é execução do monitor
            IF me->gv_monitor = abap_true.

              "----Reprocessamento
              IF me->gv_actvt = me->gc_actvt-process.

                DATA(lv_process) = me->gc_actvt-process."Processamento/Reprocessamento

                me->execute_mr22( CHANGING co_nf = lo_gp ).

                me->execute_fb50( CHANGING co_nf = lo_gp ). "#EC CI_SEL_NESTED

                "----Estorno
              ELSEIF me->gv_actvt = me->gc_actvt-reverse.

                lv_process = me->gc_actvt-reverse."Estorno

                me->reverse_mr22( CHANGING co_nf = lo_gp ).

                me->reverse_fb50( CHANGING co_nf = lo_gp ).

              ENDIF.

            ELSE.

              "----Procesamento
              IF lo_gp->canceled = abap_false.

                lv_process = me->gc_actvt-process.

                me->execute_mr22( CHANGING co_nf = lo_gp ).

                me->execute_fb50( CHANGING co_nf = lo_gp ). "#EC CI_SEL_NESTED

                "----Estorno
              ELSE.

                lv_process = me->gc_actvt-reverse.

                me->reverse_mr22( CHANGING co_nf = lo_gp ).

                me->reverse_fb50( CHANGING co_nf = lo_gp ).

              ENDIF.

            ENDIF.

          ENDLOOP.

          "----Modifica registros e adiciona status de sucesso
          me->change_data(
            EXPORTING
              io_nf      = lo_gp
          ).

        CATCH lcx_exception INTO DATA(lo_cx).

          "----Modifica registros e adiciona status de erro.
          me->change_data(
            EXPORTING
              io_nf      = lo_gp
              iv_error   = abap_true
          ).

        CATCH cx_root INTO DATA(lo_cx_root).

          lo_gp->status = COND #( WHEN lv_process = me->gc_actvt-process THEN me->gc_status-error_to_process
                                  WHEN lv_process = me->gc_actvt-reverse THEN me->gc_status-error_to_reverse ).

          lo_gp->messagetextinfor = COND #( WHEN lv_process = me->gc_actvt-process THEN TEXT-p04   "Erro ao processar, favor tentar novamente se erro persistir contacte o suporte.
                                            WHEN lv_process = me->gc_actvt-reverse THEN TEXT-p05 )."Erro ao processar, favor tentar novamente se erro persistir contacte o suporte.

          me->change_data(
            EXPORTING
              io_nf      = lo_gp
              iv_error   = abap_true
          ).

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD change_data.

    IF iv_error = abap_true.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      "----Atualiza status do cabeçalho
      READ TABLE me->gt_ncab->* REFERENCE INTO DATA(lo_cab) WITH KEY docnum = io_nf->nfdocument. "#EC CI_STDSEQ

      CHECK sy-subrc IS INITIAL.

      lo_cab->status = io_nf->status.

      READ TABLE me->gt_nitm->* REFERENCE INTO DATA(lo_itm) WITH KEY docnum = io_nf->nfdocument "#EC CI_STDSEQ
                                                                     itmnum = io_nf->nfitem
                                                                     taxgrp = io_nf->nftaxgrp
                                                                     taxtyp = io_nf->nftaxtyp.

      CHECK sy-subrc IS INITIAL.

      lo_itm->text_msg = ''.

      "----Limpa o texto de mensagem
      MODIFY me->gt_nitm->* FROM lo_itm->* TRANSPORTING text_msg WHERE docnum = io_nf->nfdocument. "#EC CI_STDSEQ

      "---Adiciona mensagem no item que ocorreu erro
      lo_itm->user_mod = io_nf->LastUserChange.
      lo_itm->date_mod = io_nf->LastDateChange.
      lo_itm->time_mod = io_nf->LastTimeChange.
      lo_itm->text_msg = io_nf->MessageTextInfor.

    ELSE.

      "----Atualiza status do cabeçalho
      READ TABLE me->gt_ncab->* REFERENCE INTO lo_cab WITH KEY docnum = io_nf->nfdocument. "#EC CI_STDSEQ

      CHECK sy-subrc IS INITIAL.

      lo_cab->status = io_nf->status.

      "Atualiza documentos gerados dos itens
      LOOP AT me->gt_nfs->* REFERENCE INTO DATA(lo_nf) WHERE nfdocument = io_nf->nfdocument. "#EC CI_STDSEQ

        READ TABLE me->gt_nitm->* REFERENCE INTO lo_itm WITH KEY docnum = lo_nf->nfdocument "#EC CI_STDSEQ
                                                                 itmnum = lo_nf->nfitem
                                                                 taxgrp = lo_nf->nftaxgrp
                                                                 taxtyp = lo_nf->nftaxtyp.

        CHECK sy-subrc IS INITIAL.

        lo_itm->bln_c_fb = lo_nf->accountingdocument.
        lo_itm->gjr_c_fb = lo_nf->accountingyear.
        lo_itm->bln_c_mr = lo_nf->mrdocument.
        lo_itm->gjr_c_mr = lo_nf->mryear.
        lo_itm->bln_s_fb = lo_nf->reversaldocument.
        lo_itm->gjr_s_fb = lo_nf->reversalyear.
        lo_itm->bln_s_mr = lo_nf->mrrevdocument.
        lo_itm->gjr_s_mr = lo_nf->mrrevyear.
        lo_itm->user_mod = lo_nf->LastUserChange.
        lo_itm->date_mod = lo_nf->LastDateChange.
        lo_itm->time_mod = lo_nf->LastTimeChange.
        lo_itm->text_msg = lo_nf->MessageTextInfor.

        "----Salva Registro
        MODIFY ztco_notas_itm FROM lo_itm->*.       "#EC CI_IMUD_NESTED

      ENDLOOP.

      "----Salva Registro
      MODIFY ztco_notas_cab FROM lo_cab->*.         "#EC CI_IMUD_NESTED

      "----Realiza Commmit dos dados
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ENDIF.

  ENDMETHOD.

  METHOD convert_currency.

    "----Conversão para moeda estrangeira
    CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
      EXPORTING
        date             = sy-datum
        foreign_currency = is_currency-waers
        local_amount     = iv_taxvalue
        local_currency   = 'BRL'
      IMPORTING
        foreign_amount   = rv_taxvalue
      EXCEPTIONS
        no_rate_found    = 1
        overflow         = 2
        no_factors_found = 3
        no_spread_found  = 4
        derived_2_times  = 5
        OTHERS           = 6.

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

  ENDMETHOD.

  METHOD execute_mr22.

    "----Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Tabelas
    DATA: lt_currency TYPE REF TO ty_t_currency,
          lt_mdc      TYPE REF TO ty_t_mdc,
          lt_return   TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_document TYPE REF TO bapi_pricechange_document.

    CHECK co_nf->execmr22 = abap_true.

    CHECK co_nf->mrdocument IS INITIAL
      AND co_nf->mryear     IS INITIAL.

    CREATE DATA lt_currency.

    "----Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = co_nf->EvaluationArea
      TABLES
        t_curtp_for_va      = lt_currency->*
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

      co_nf->status = gc_status-error_to_process.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

    "----Montagem
    CREATE DATA lt_mdc.
    CREATE DATA lt_return.
    CREATE DATA ls_document.

    DATA(lv_taxval) = COND j_1btaxval( WHEN co_nf->sign = '-' AND co_nf->taxvalue > 0 THEN co_nf->taxvalue * -1
                                       WHEN co_nf->sign = '+' AND co_nf->taxvalue < 0 THEN co_nf->taxvalue * -1
                                       ELSE co_nf->taxvalue ).

    TRY.

        lt_mdc->* = VALUE #( FOR ls_currency IN lt_currency->*
                            ( curr_type     = ls_currency-currtyp
                              currency      = ls_currency-waers
                              amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                       THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                      ELSE lv_taxval )
                              quantity_unit = 'UN' ) ).

      CATCH lcx_exception.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

        co_nf->status = gc_status-error_to_process.

        RAISE EXCEPTION TYPE lcx_exception.

    ENDTRY.

    "----Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( co_nf->material )
        valuationarea         = COND #( WHEN co_nf->direction = 2 THEN co_nf->TransferCenter
                                        ELSE co_nf->center )
        valuationtype         = co_nf->valuationtype
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = co_nf->releasedate(4)
                                                                   fisc_period = co_nf->releasedate+4(2)
                                                                   pstng_date  = co_nf->releasedate )
        ref_doc_no            = co_nf->referencekeydoc
      IMPORTING
        debitcreditdocument   = ls_document->*
      TABLES
        return                = lt_return->*
        material_debit_credit = lt_mdc->*.


    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_process.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ type = 'E' ].      "#EC CI_STDSEQ

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ELSE.

      co_nf->status           = gc_status-success_to_process.
      co_nf->mrdocument       = ls_document->ml_doc_num.
      co_nf->mryear           = ls_document->ml_doc_year.
      co_nf->lastuserchange   = sy-uname.
      co_nf->lastdatechange   = sy-datum.
      co_nf->lasttimechange   = sy-uzeit.
      co_nf->messagetextinfor = TEXT-p01."Sucesso ao processar item.

    ENDIF.

  ENDMETHOD.

  METHOD execute_fb50.

    "----Types
    TYPES: ty_t_accgl    TYPE TABLE OF bapiacgl08 WITH DEFAULT KEY,
           ty_t_currency TYPE TABLE OF bapiaccr08 WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Variáveis
    DATA: lv_obj_type TYPE awtyp,
          lv_obj_key  TYPE awkey,
          lv_obj_sys  TYPE awsys.

    "----Tabelas
    DATA: lt_accountgl      TYPE REF TO ty_t_accgl,
          lt_currencyamount TYPE REF TO ty_t_currency,
          lt_return         TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_document TYPE REF TO bapiache08.

    CHECK co_nf->execfb50 = abap_true.

    CHECK co_nf->accountingdocument IS INITIAL
      AND co_nf->accountingyear     IS INITIAL.

    "----Montagem
    CREATE DATA lt_accountgl.
    CREATE DATA lt_currencyamount.
    CREATE DATA lt_return.
    CREATE DATA ls_document.

    "----Cabeçalho
    ls_document->obj_type   = 'BKPFF'.
    ls_document->pstng_date = co_nf->releasedate.
    ls_document->doc_date   = co_nf->releasedate.
    ls_document->username   = sy-uname.
    ls_document->comp_code  = co_nf->companycode.
    ls_document->ref_doc_no = co_nf->referencekey.
    ls_document->fisc_year  = co_nf->releasedate(4).
    ls_document->fis_period = co_nf->releasedate+4(2).
    ls_document->doc_type   = co_nf->typedoc.

    "----Contas
    APPEND INITIAL LINE TO lt_accountgl->* REFERENCE INTO DATA(lo_acc).

    lo_acc->itemno_acc = 1.
    lo_acc->pstng_date = co_nf->releasedate.
    lo_acc->gl_account = co_nf->debitaccount.

    APPEND INITIAL LINE TO lt_accountgl->* REFERENCE INTO lo_acc.

    lo_acc->itemno_acc = 2.
    lo_acc->pstng_date = co_nf->releasedate.
    lo_acc->gl_account = co_nf->creditaccount.

    "----Moeda
    APPEND INITIAL LINE TO lt_currencyamount->* REFERENCE INTO DATA(lo_amt).

    lo_amt->itemno_acc = 1.
    lo_amt->curr_type  = '00'.
    lo_amt->currency   = 'BRL'.
    lo_amt->amt_doccur = COND #( WHEN co_nf->taxvalue < 0 THEN co_nf->taxvalue * -1
                                 ELSE co_nf->taxvalue ).

    APPEND INITIAL LINE TO lt_currencyamount->* REFERENCE INTO lo_amt.

    lo_amt->itemno_acc = 2.
    lo_amt->curr_type  = '00'.
    lo_amt->currency   = 'BRL'.
    lo_amt->amt_doccur = COND #( WHEN co_nf->taxvalue > 0 THEN co_nf->taxvalue * -1
                                 ELSE co_nf->taxvalue ).

    "----Lançamento
    CALL FUNCTION 'BAPI_ACC_GL_POSTING_POST'
      EXPORTING
        documentheader = ls_document->*
      IMPORTING
        obj_type       = lv_obj_type
        obj_key        = lv_obj_key
        obj_sys        = lv_obj_sys
      TABLES
        accountgl      = lt_accountgl->*
        currencyamount = lt_currencyamount->*
        return         = lt_return->*.

    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_process.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ 2 ].

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ELSE.

      co_nf->status             = gc_status-success_to_process.
      co_nf->accountingdocument = lv_obj_key(10).
      co_nf->accountingyear     = lv_obj_key+14(4).
      co_nf->lastuserchange     = sy-uname.
      co_nf->lastdatechange     = sy-datum.
      co_nf->lasttimechange     = sy-uzeit.
      co_nf->messagetextinfor   = TEXT-p01. "Sucesso ao processar item.

    ENDIF.

  ENDMETHOD.

  METHOD reverse_mr22.

    "----Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Tabelas
    DATA: lt_currency TYPE REF TO ty_t_currency,
          lt_mdc      TYPE REF TO ty_t_mdc,
          lt_return   TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_document TYPE REF TO bapi_pricechange_document.

    CHECK co_nf->execmr22 = abap_true.

    CHECK co_nf->mrdocument    IS NOT INITIAL
      AND co_nf->mryear        IS NOT INITIAL
      AND co_nf->mrrevdocument IS INITIAL
      AND co_nf->mrrevyear     IS INITIAL.

    CREATE DATA lt_currency.

    "----Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = co_nf->EvaluationArea
      TABLES
        t_curtp_for_va      = lt_currency->*
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

      co_nf->status = gc_status-error_to_process.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

    "----Montagem
    CREATE DATA lt_mdc.
    CREATE DATA lt_return.
    CREATE DATA ls_document.

    DATA(lv_taxval) = COND j_1btaxval( WHEN co_nf->sign = '-' AND co_nf->taxvalue < 0 THEN co_nf->taxvalue * -1
                                       WHEN co_nf->sign = '+' AND co_nf->taxvalue > 0 THEN co_nf->taxvalue * -1
                                       ELSE co_nf->taxvalue ).

    TRY.

        lt_mdc->* = VALUE #( FOR ls_currency IN lt_currency->*
                            ( curr_type     = ls_currency-currtyp
                              currency      = ls_currency-waers
                              amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                       THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                      ELSE lv_taxval )
                              quantity_unit = 'UN' ) ).

      CATCH lcx_exception.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

        co_nf->status = gc_status-error_to_process.

        RAISE EXCEPTION TYPE lcx_exception.

    ENDTRY.

    "----Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( co_nf->material )
        valuationarea         = COND #( WHEN co_nf->direction = 2 THEN co_nf->TransferCenter
                                        ELSE co_nf->center )
        valuationtype         = co_nf->valuationtype
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = co_nf->releasedate(4)
                                                                   fisc_period = co_nf->releasedate+4(2)
                                                                   pstng_date  = co_nf->releasedate )
        ref_doc_no            = co_nf->referencekeydoc
      IMPORTING
        debitcreditdocument   = ls_document->*
      TABLES
        return                = lt_return->*
        material_debit_credit = lt_mdc->*.


    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_reverse.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ type = 'E' ].      "#EC CI_STDSEQ

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ELSE.

      co_nf->status           = gc_status-success_to_reverse.
      co_nf->mrrevdocument    = ls_document->ml_doc_num.
      co_nf->mrrevyear        = ls_document->ml_doc_year.
      co_nf->lastuserchange   = sy-uname.
      co_nf->lastdatechange   = sy-datum.
      co_nf->lasttimechange   = sy-uzeit.
      co_nf->messagetextinfor = TEXT-p02. "Sucesso ao estornar item.

    ENDIF.

  ENDMETHOD.

  METHOD reverse_fb50.

    "----Types
    TYPES: ty_t_accgl    TYPE TABLE OF bapiacgl08 WITH DEFAULT KEY,
           ty_t_currency TYPE TABLE OF bapiaccr08 WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Variáveis
    DATA: lv_obj_type TYPE awtyp,
          lv_obj_key  TYPE awkey,
          lv_obj_sys  TYPE awsys.

    "----Tabelas
    DATA: lt_accountgl      TYPE REF TO ty_t_accgl,
          lt_currencyamount TYPE REF TO ty_t_currency,
          lt_return         TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_reversal TYPE REF TO bapiacrev.

    CHECK co_nf->execfb50 = abap_true.

    CHECK co_nf->accountingdocument IS NOT INITIAL
      AND co_nf->accountingyear     IS NOT INITIAL
      AND co_nf->reversaldocument   IS INITIAL
      AND co_nf->reversalyear       IS INITIAL.

    "----Montagem
    CREATE DATA lt_return.
    CREATE DATA ls_reversal.

    "----Dados para estorno
    ls_reversal->obj_type   = 'BKPFF'.
    ls_reversal->reason_rev = '01'.
    ls_reversal->comp_code  = co_nf->companycode.
    ls_reversal->obj_key_r  = |{ co_nf->accountingdocument }{ co_nf->companycode }{ co_nf->accountingyear }|.

    CALL FUNCTION 'BAPI_ACC_GL_POSTING_REV_POST'
      EXPORTING
        reversal = ls_reversal->*
      IMPORTING
        obj_type = lv_obj_type
        obj_key  = lv_obj_key
        obj_sys  = lv_obj_sys
      TABLES
        return   = lt_return->*.

    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_reverse.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ 2 ].

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ELSE.

      co_nf->status             = gc_status-success_to_reverse.
      co_nf->reversaldocument   = lv_obj_key(10).
      co_nf->reversalyear       = lv_obj_key+14(4).
      co_nf->lastuserchange     = sy-uname.
      co_nf->lastdatechange     = sy-datum.
      co_nf->lasttimechange     = sy-uzeit.
      co_nf->messagetextinfor   = TEXT-p02."Sucesso ao estornar item.

    ENDIF.

  ENDMETHOD.

  METHOD execute_mr22_affiliated.

    "----Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Tabelas
    DATA: lt_currency TYPE REF TO ty_t_currency,
          lt_mdc      TYPE REF TO ty_t_mdc,
          lt_return   TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_document TYPE REF TO bapi_pricechange_document.

    CHECK co_nf->execmr22     = abap_true
      AND co_nf->isaffiliated = abap_true.

    CREATE DATA lt_currency.

    "----Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = co_nf->EvaluationArea
      TABLES
        t_curtp_for_va      = lt_currency->*
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

      co_nf->status = gc_status-error_to_process.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

    "----Montagem
    CREATE DATA lt_mdc.
    CREATE DATA lt_return.
    CREATE DATA ls_document.

    DATA(lv_taxval) = COND j_1btaxval( WHEN co_nf->sign = '-' AND co_nf->taxvalue < 0 THEN co_nf->taxvalue * -1

                                       WHEN co_nf->sign = '+' AND co_nf->taxvalue > 0 THEN co_nf->taxvalue * -1
                                       ELSE co_nf->taxvalue ).

    TRY.

        lt_mdc->* = VALUE #( FOR ls_currency IN lt_currency->*
                            ( curr_type     = ls_currency-currtyp
                              currency      = ls_currency-waers
                              amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                       THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                      ELSE lv_taxval )
                              quantity_unit = 'UN' ) ).

      CATCH lcx_exception.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

        co_nf->status = gc_status-error_to_process.

        RAISE EXCEPTION TYPE lcx_exception.

    ENDTRY.

    "----Referência em caso de parceiro coligada deve ser fixo
    DATA(lv_ref) = CONV ze_elemento( 'ELEM24' ).

    "----Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( co_nf->material )
        valuationarea         = co_nf->center
        valuationtype         = co_nf->valuationtype
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = co_nf->releasedate(4)
                                                                   fisc_period = co_nf->releasedate+4(2)
                                                                   pstng_date  = co_nf->releasedate )
        ref_doc_no            = lv_ref
      IMPORTING
        debitcreditdocument   = ls_document->*
      TABLES
        return                = lt_return->*
        material_debit_credit = lt_mdc->*.


    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_process.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ type = 'E' ].      "#EC CI_STDSEQ

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

  ENDMETHOD.

  METHOD reverse_mr22_affiliated.

    "----Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "----Tabelas
    DATA: lt_currency TYPE REF TO ty_t_currency,
          lt_mdc      TYPE REF TO ty_t_mdc,
          lt_return   TYPE REF TO ty_t_return.

    "----Estruturas
    DATA: ls_document TYPE REF TO bapi_pricechange_document.

    CHECK co_nf->execmr22     = abap_true
      AND co_nf->isaffiliated = abap_true.

    CREATE DATA lt_currency.

    "----Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = co_nf->EvaluationArea
      TABLES
        t_curtp_for_va      = lt_currency->*
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

      co_nf->status = gc_status-error_to_process.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

    "----Montagem
    CREATE DATA lt_mdc.
    CREATE DATA lt_return.
    CREATE DATA ls_document.

    DATA(lv_taxval) = COND j_1btaxval( WHEN co_nf->sign = '-' AND co_nf->taxvalue > 0 THEN co_nf->taxvalue * -1
                                       WHEN co_nf->sign = '+' AND co_nf->taxvalue < 0 THEN co_nf->taxvalue * -1
                                       ELSE co_nf->taxvalue ).

    TRY.

        lt_mdc->* = VALUE #( FOR ls_currency IN lt_currency->*
                            ( curr_type     = ls_currency-currtyp
                              currency      = ls_currency-waers
                              amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                       THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                      ELSE lv_taxval )
                              quantity_unit = 'UN' ) ).

      CATCH lcx_exception.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO co_nf->messagetextinfor.

        co_nf->status = gc_status-error_to_process.

        RAISE EXCEPTION TYPE lcx_exception.

    ENDTRY.

    "----Referência em caso de parceiro coligada deve ser fixo
    DATA(lv_ref) = CONV ze_elemento( 'ELEM24' ).

    "----Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( co_nf->material )
        valuationarea         = co_nf->center
        valuationtype         = co_nf->valuationtype
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = co_nf->releasedate(4)
                                                                   fisc_period = co_nf->releasedate+4(2)
                                                                   pstng_date  = co_nf->releasedate )
        ref_doc_no            = lv_ref
      IMPORTING
        debitcreditdocument   = ls_document->*
      TABLES
        return                = lt_return->*
        material_debit_credit = lt_mdc->*.


    "----Trata erro em caso houver
    IF line_exists( lt_return->*[ type = 'E' ] ).        "#EC CI_STDSEQ

      co_nf->status         = gc_status-error_to_reverse.
      co_nf->lastuserchange = sy-uname.
      co_nf->lastdatechange = sy-datum.
      co_nf->lasttimechange = sy-uzeit.

      DATA(ls_return) = lt_return->*[ type = 'E' ].      "#EC CI_STDSEQ

      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
      WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
      INTO co_nf->messagetextinfor.

      RAISE EXCEPTION TYPE lcx_exception.

    ENDIF.

  ENDMETHOD.


  METHOD get_ranges_ivas.
    "Ranges
    DATA: lr_transferencia TYPE RANGE OF j_1bnflin-mwskz,
          lr_entrada       TYPE RANGE OF j_1bnflin-mwskz.

    SELECT * "#EC CI_NOWHERE
      FROM zi_co_determinacao_ivas
      INTO TABLE @DATA(lt_IVAs).

    LOOP AT lt_IVAs ASSIGNING FIELD-SYMBOL(<fs_s_ivas>).
      CASE <fs_s_ivas>-IsTransferIVA.
        WHEN abap_true.
          APPEND INITIAL LINE TO lr_transferencia ASSIGNING FIELD-SYMBOL(<fs_s_transferencia>).

          <fs_s_transferencia>-sign   = 'I'.
          <fs_s_transferencia>-option = 'EQ'.
          <fs_s_transferencia>-low    = <fs_s_ivas>-TaxCode.
        WHEN abap_false.
          APPEND INITIAL LINE TO lr_entrada ASSIGNING FIELD-SYMBOL(<fs_s_entrada>).

          <fs_s_entrada>-sign   = 'I'.
          <fs_s_entrada>-option = 'EQ'.
          <fs_s_entrada>-low    = <fs_s_ivas>-TaxCode.
      ENDCASE.
    ENDLOOP.

    er_entrada       = lr_entrada.
    er_transferencia = lr_transferencia.
  ENDMETHOD.

ENDCLASS.
