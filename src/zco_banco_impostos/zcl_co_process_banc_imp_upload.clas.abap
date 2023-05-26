CLASS zcl_co_process_banc_imp_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor IMPORTING iv_sheet_guid TYPE sysuuid_x16
                                  is_data       TYPE zsco_banco_impostos_data
                        RAISING   zcx_co_process_banc_imp_upload.

    METHODS process RAISING zcx_co_process_banc_imp_upload.

    METHODS reverse RAISING zcx_co_process_banc_imp_upload.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_s_nota_pc_copa,
             docnum TYPE j_1bnflin-docnum,
             matnr  TYPE j_1bnflin-matnr,
             bwtar  TYPE j_1bnflin-bwtar,
             refkey TYPE j_1bnflin-refkey,
           END OF ty_s_nota_pc_copa,

           BEGIN OF ty_s_infor_pc_copa,
             nota        TYPE TABLE OF ty_s_nota_pc_copa WITH DEFAULT KEY,
             with_ref    TYPE TABLE OF ce1ar3c WITH DEFAULT KEY, "---Processo com referência
             without_ref TYPE TABLE OF ce1ar3c WITH DEFAULT KEY, "---Processo sem referência
           END OF ty_s_infor_pc_copa,

           BEGIN OF ty_s_bkpf_rv_fb50,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF ty_s_bkpf_rv_fb50,

           BEGIN OF ty_s_infor_rv_fb50,
             bkpf TYPE TABLE OF ty_s_bkpf_rv_fb50 WITH DEFAULT KEY,
           END OF ty_s_infor_rv_fb50,

           BEGIN OF ty_s_mlhd_rv_mr22,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             bldat TYPE bldat,
             matnr TYPE matnr,
             bwkey TYPE bwkey,
             bwtar TYPE bwtar_d,
           END OF ty_s_mlhd_rv_mr22,

           BEGIN OF ty_s_bkpf_rv_mr22,
             awkey TYPE awkey,
             xblnr TYPE xblnr,
             dmbtr TYPE dmbtr,
             shkzg TYPE shkzg,
           END OF ty_s_bkpf_rv_mr22,

           BEGIN OF ty_s_infor_rv_mr22,
             mlhd TYPE TABLE OF ty_s_mlhd_rv_mr22 WITH DEFAULT KEY,
             bkpf TYPE TABLE OF ty_s_bkpf_rv_mr22 WITH DEFAULT KEY,
           END OF ty_s_infor_rv_mr22,

           BEGIN OF ty_s_infor_rv_copa,
             ce1ar3c TYPE TABLE OF ce1ar3c WITH DEFAULT KEY,
           END OF ty_s_infor_rv_copa,

           "---Tipos de tabelas
           ty_t_log TYPE TABLE OF ztco_banc_imp_lg WITH DEFAULT KEY,
           ty_t_cfg TYPE TABLE OF ztco_banco_imp   WITH DEFAULT KEY.

    "---Objetos
    DATA: go_lock TYPE REF TO if_abap_lock_object.

    "---Tabelas
    DATA: gt_log TYPE ty_t_log,
          gt_cfg TYPE ty_t_cfg.

    "---Estruturas
    DATA: gs_data        TYPE zsco_banco_impostos_data,

          "---Estruturas de processamento/estorno
          gs_inf_pc_copa TYPE ty_s_infor_pc_copa,
          gs_inf_rv_fb50 TYPE ty_s_infor_rv_fb50,
          gs_inf_rv_mr22 TYPE ty_s_infor_rv_mr22,
          gs_inf_rv_copa TYPE ty_s_infor_rv_copa,

          "---Estruturas de configuração do processamento
          gs_icms        TYPE ztco_banco_imp,
          gs_icmsst      TYPE ztco_banco_imp,
          gs_ipi         TYPE ztco_banco_imp.

    "---Variáveis globais
    DATA: gv_sheet_guid TYPE sysuuid_x16,
          gv_times      TYPE timestamp,
          gv_error      TYPE abap_bool,
          gv_save       TYPE abap_bool.

    CONSTANTS:
      BEGIN OF gc_bc_status,
        succs_pc TYPE numc2 VALUE '01', " Processado
        succs_pr TYPE numc2 VALUE '02', " Estornado
        error_pc TYPE numc2 VALUE '03', " Erro ao Processar
        error_rv TYPE numc2 VALUE '04', " Erro ao Estornar
        in_procs TYPE numc2 VALUE '05', " Em processamento
        in_rever TYPE numc2 VALUE '06', " Em estorno
      END OF gc_bc_status.

    CONSTANTS:
      BEGIN OF gc_bc_pc_status,
        itm_ok TYPE numc2  VALUE '01', " Item Ok
        itm_nk TYPE numc2  VALUE '02', " Item com Erro
        itm_ip TYPE numc2  VALUE '03', " Item em Processamento
        itm_np TYPE numc2  VALUE '04', " Item não processado
      END OF gc_bc_pc_status.

    CONSTANTS:
      BEGIN OF gc_bc_log_type,
        error VALUE 'E', " Erro
        sucss VALUE 'S', " Sucesso
        warng VALUE 'W', " Aviso
        infor VALUE 'I', " Informação
      END OF gc_bc_log_type.

    CONSTANTS:
      BEGIN OF gc_bc_lancs,
        icms   TYPE char50  VALUE 'ICMS', " Elemento de custo para icms
        icmsst TYPE char50  VALUE 'ICMS ST', " Elemento de custo para icms st
        ipi    TYPE char50  VALUE 'IPI', " Elemento de custo para ipi
      END OF gc_bc_lancs.

    CONSTANTS:
      BEGIN OF gc_bc_elem_cust,
        icms1   TYPE xblnr  VALUE 'ELEM15', " Elemento de custo para icms
        icms2   TYPE xblnr  VALUE 'ELEM22', " Elemento de custo para icms
        icms3   TYPE xblnr  VALUE 'ELEM13', " Elemento de custo para icms
        icmsst1 TYPE xblnr  VALUE 'ELEM14', " Elemento de custo para icms st
        icmsst2 TYPE xblnr  VALUE 'ELEM23', " Elemento de custo para icms st
        ipi     TYPE xblnr  VALUE 'ELEM21', " Elemento de custo para ipi
      END OF gc_bc_elem_cust.

    METHODS get_data IMPORTING iv_sheet_guid  TYPE sysuuid_x16
                     RETURNING VALUE(rs_data) TYPE zsco_banco_impostos_data
                     RAISING   zcx_co_process_banc_imp_upload.

    METHODS get_scenarios_process_config RAISING   zcx_co_process_banc_imp_upload.

    METHODS get_infor_process_copa  RAISING zcx_co_process_banc_imp_upload.

    METHODS get_infor_reverse_mr22  RAISING zcx_co_process_banc_imp_upload.

    METHODS get_infor_reverse_copa  RAISING zcx_co_process_banc_imp_upload.

    METHODS enqueue_bc   RAISING zcx_co_process_banc_imp_upload.

    METHODS dequeue_bc   RAISING zcx_co_process_banc_imp_upload.

    METHODS convert_currency IMPORTING is_currency        TYPE cki_ml_cty
                                       iv_taxvalue        TYPE j_1btaxval
                             RETURNING VALUE(rv_taxvalue) TYPE j_1btaxval
                             RAISING   zcx_co_process_banc_imp_upload.

    METHODS change_data      IMPORTING iv_process      TYPE abap_bool OPTIONAL
                                       iv_mod_sts_item TYPE abap_bool OPTIONAL
                                       iv_error        TYPE abap_bool OPTIONAL
                                       iv_error_header TYPE abap_bool OPTIONAL
                                       iv_sts_header   TYPE numc2     OPTIONAL
                                       iv_sts_item     TYPE numc2     OPTIONAL
                                       iv_message      TYPE string    OPTIONAL
                             RAISING   zcx_co_process_banc_imp_upload.

    METHODS save_data    RAISING zcx_co_process_banc_imp_upload.

    METHODS execute_fb50 IMPORTING is_config TYPE ztco_banco_imp
                                   iv_value  TYPE netpr
                         CHANGING  cs_item   TYPE zsco_banco_impostos_item
                                   cv_doc    TYPE belnr_d
                                   cv_year   TYPE gjahr
                         RAISING   zcx_co_process_banc_imp_upload.

    METHODS execute_mr22 IMPORTING is_config TYPE ztco_banco_imp
                                   iv_value  TYPE netpr
                         CHANGING  cs_item   TYPE zsco_banco_impostos_item
                                   cv_doc    TYPE belnr_d
                                   cv_year   TYPE gjahr
                         RAISING   zcx_co_process_banc_imp_upload.

    METHODS execute_copa CHANGING cs_item TYPE zsco_banco_impostos_item
                         RAISING  zcx_co_process_banc_imp_upload.

    METHODS reverse_fb50 IMPORTING iv_doc      TYPE belnr_d
                                   iv_year     TYPE gjahr
                         CHANGING  cs_item     TYPE zsco_banco_impostos_item
                                   cv_doc_rev  TYPE belnr_d
                                   cv_year_rev TYPE gjahr
                         RAISING   zcx_co_process_banc_imp_upload.

    METHODS reverse_mr22 IMPORTING iv_doc      TYPE belnr_d
                                   iv_year     TYPE gjahr
                         CHANGING  cs_item     TYPE zsco_banco_impostos_item
                                   cv_doc_rev  TYPE belnr_d
                                   cv_year_rev TYPE gjahr
                         RAISING   zcx_co_process_banc_imp_upload.

    METHODS reverse_copa CHANGING cs_item TYPE zsco_banco_impostos_item
                         RAISING  zcx_co_process_banc_imp_upload.

    METHODS check_process_config CHANGING cs_item TYPE zsco_banco_impostos_item
                                 RAISING  zcx_co_process_banc_imp_upload.

    METHODS insert_log   IMPORTING is_item    TYPE zsco_banco_impostos_item
                                   iv_type    TYPE c            OPTIONAL
                                   iv_message TYPE string       OPTIONAL
                                   it_bapiret TYPE bapiret2_tab OPTIONAL
                         RAISING   zcx_co_process_banc_imp_upload.

    METHODS handle_error IMPORTING io_cx TYPE REF TO zcx_co_process_banc_imp_upload.

ENDCLASS.

CLASS zcl_co_process_banc_imp_upload IMPLEMENTATION.

  METHOD constructor.

    TRY.

        me->gs_data = COND #( WHEN is_data IS NOT INITIAL
                                THEN is_data
                              ELSE me->get_data( iv_sheet_guid ) ).

        me->gv_sheet_guid = me->gs_data-header-guid.

        GET TIME STAMP FIELD me->gv_times.

        me->gv_error = abap_false.

        me->gv_save  = abap_false.

      CATCH zcx_co_process_banc_imp_upload INTO DATA(lo_cx).

        me->change_data(
          EXPORTING
            iv_error_header = abap_true
            iv_message      = lo_cx->get_longtext( )
            iv_sts_header   = gc_bc_status-in_rever
        ).

        save_data( ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
          EXPORTING
            iv_textid = lo_cx->if_t100_message~t100key
            iv_msgv1  = lo_cx->gv_msgv1
            iv_msgv2  = lo_cx->gv_msgv2
            iv_msgv3  = lo_cx->gv_msgv3
            iv_msgv4  = lo_cx->gv_msgv4.

    ENDTRY.

  ENDMETHOD.

  METHOD process.

    TRY.

        TRY.

            "---Recupera configuração
            me->get_scenarios_process_config( ).

            "---Recupera
            me->get_infor_process_copa( ).

          CATCH zcx_co_process_banc_imp_upload INTO DATA(lo_cx).

            "---Modifica dados
            me->change_data( iv_error_header = abap_true
                             iv_message      = lo_cx->get_longtext( )
                             iv_sts_header   = gc_bc_status-error_pc
                             iv_sts_item     = gc_bc_pc_status-itm_nk ).

            RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
              EXPORTING
                iv_textid = lo_cx->if_t100_message~t100key
                iv_msgv1  = lo_cx->gv_msgv1
                iv_msgv2  = lo_cx->gv_msgv2
                iv_msgv3  = lo_cx->gv_msgv3
                iv_msgv4  = lo_cx->gv_msgv4.

        ENDTRY.

        TRY.

            "---Ajusta status dos itens
            me->change_data(
              EXPORTING
                iv_mod_sts_item = abap_true
                iv_sts_item     = gc_bc_pc_status-itm_np
            ).

          CATCH cx_root.

        ENDTRY.

        TRY.

            LOOP AT me->gs_data-item ASSIGNING FIELD-SYMBOL(<fs_item>).

              TRY.

                  "---Checa se configuração existe
                  me->check_process_config( CHANGING cs_item = <fs_item>  ).

                  IF <fs_item>-valoricms IS NOT INITIAL.

                    me->execute_fb50(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_icms
                        iv_value  = <fs_item>-valoricms
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_fb
                        cv_year   = <fs_item>-gjr_c_fb
                    ).

                    me->execute_mr22(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_icms
                        iv_value  = <fs_item>-valoricms
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_mr
                        cv_year   = <fs_item>-gjr_c_mr
                    ).

                  ENDIF.

                  IF <fs_item>-valoricmsst IS NOT INITIAL.

                    me->execute_fb50(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_icmsst
                        iv_value  = <fs_item>-valoricmsst
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_fb2
                        cv_year   = <fs_item>-gjr_c_fb2
                    ).

                    me->execute_mr22(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_icmsst
                        iv_value  = <fs_item>-valoricmsst
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_mr2
                        cv_year   = <fs_item>-gjr_c_mr2
                    ).

                  ENDIF.

                  IF <fs_item>-valoripi IS NOT INITIAL.

                    me->execute_fb50(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_ipi
                        iv_value  = <fs_item>-valoripi
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_fb3
                        cv_year   = <fs_item>-gjr_c_fb3
                    ).

                    me->execute_mr22(                "#EC CI_SEL_NESTED
                      EXPORTING
                        is_config = me->gs_ipi
                        iv_value  = <fs_item>-valoripi
                      CHANGING
                        cs_item   = <fs_item>
                        cv_doc    = <fs_item>-bln_c_mr3
                        cv_year   = <fs_item>-gjr_c_mr3
                    ).

                  ENDIF.

                  "---Execução CO/PA
                  me->execute_copa(
                      CHANGING
                        cs_item   = <fs_item>
                  ).

                  "---Erro em caso de configuração não encontrada ou retorno de erro em bapi
                CATCH zcx_co_process_banc_imp_upload.
              ENDTRY.

            ENDLOOP.

            "---Modifica dados
            IF me->gv_error = abap_true.

              me->change_data( iv_process = abap_true
                               iv_error   = abap_true ).

            ELSE.

              me->change_data( iv_process = abap_true ).

            ENDIF.

            "---Salva dados com erro ou sucesso do processamento
            me->save_data( ).

          CATCH cx_root INTO DATA(lo_root).

            "---Altera status
            <fs_item>-status = gc_bc_pc_status-itm_nk.

            insert_log(
              EXPORTING
                is_item    = <fs_item>
                iv_type    = gc_bc_log_type-error
                iv_message = |{ lo_root->get_longtext( ) }|
            ).

            me->change_data(
              EXPORTING
                iv_process      = abap_true
                iv_error        = abap_true
            ).

            "---Salva dados com erro não reconhecido
            me->save_data( ).

        ENDTRY.

      CATCH zcx_co_process_banc_imp_upload INTO lo_cx.

        "---Salva dados com erro previsto
        me->save_data( ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
          EXPORTING
            iv_textid = lo_cx->if_t100_message~t100key
            iv_msgv1  = lo_cx->gv_msgv1
            iv_msgv2  = lo_cx->gv_msgv2
            iv_msgv3  = lo_cx->gv_msgv3
            iv_msgv4  = lo_cx->gv_msgv4.

      CATCH cx_root INTO lo_root.

        "---Modifica dados
        me->change_data( iv_error_header = abap_true
                         iv_message      = lo_root->get_longtext( )
                         iv_sts_header   = gc_bc_status-error_pc
                         iv_sts_item     = gc_bc_pc_status-itm_nk ).

        "---Salva dados com erro previsto
        me->save_data( ).

    ENDTRY.

  ENDMETHOD.

  METHOD reverse.

    TRY.

        TRY.

            "---Bloqueia tabela
            me->enqueue_bc( ).

            "---Recupera configurações/dados adicionais
            me->get_infor_reverse_mr22( ).

            me->get_infor_reverse_copa( ).

          CATCH zcx_co_process_banc_imp_upload INTO DATA(lo_cx).

            "---Modifica dados
            me->change_data( iv_error_header = abap_true
                             iv_message      = lo_cx->get_longtext( )
                             iv_sts_header   = gc_bc_status-error_rv
                             iv_sts_item     = gc_bc_pc_status-itm_nk ).

            RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
              EXPORTING
                iv_textid = lo_cx->if_t100_message~t100key
                iv_msgv1  = lo_cx->gv_msgv1
                iv_msgv2  = lo_cx->gv_msgv2
                iv_msgv3  = lo_cx->gv_msgv3
                iv_msgv4  = lo_cx->gv_msgv4.

        ENDTRY.

        TRY.

            "---Ajusta status dos itens
            me->change_data(
              EXPORTING
                iv_mod_sts_item = abap_true
                iv_sts_item     = gc_bc_pc_status-itm_np
            ).

          CATCH cx_root.

        ENDTRY.

        TRY.

            LOOP AT me->gs_data-item ASSIGNING FIELD-SYMBOL(<fs_item>).

              TRY.

                  "---Estorno FB50 ICMS em caso de cenário gerado
                  me->reverse_fb50(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_fb
                      iv_year     = <fs_item>-gjr_c_fb
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_fb
                      cv_year_rev = <fs_item>-gjr_r_fb
                  ).

                  me->reverse_mr22(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_mr
                      iv_year     = <fs_item>-gjr_c_mr
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_mr
                      cv_year_rev = <fs_item>-gjr_r_mr
                  ).

                  "---ICMS ST em caso de cenário gerado
                  me->reverse_fb50(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_fb2
                      iv_year     = <fs_item>-gjr_c_fb2
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_fb2
                      cv_year_rev = <fs_item>-gjr_r_fb2
                  ).

                  me->reverse_mr22(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_mr2
                      iv_year     = <fs_item>-gjr_c_mr2
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_mr2
                      cv_year_rev = <fs_item>-gjr_r_mr2
                  ).

                  "---Ipi em caso de cenário gerado
                  me->reverse_fb50(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_fb3
                      iv_year     = <fs_item>-gjr_c_fb3
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_fb3
                      cv_year_rev = <fs_item>-gjr_r_fb3
                  ).

                  me->reverse_mr22(
                    EXPORTING
                      iv_doc      = <fs_item>-bln_c_mr3
                      iv_year     = <fs_item>-gjr_c_mr3
                    CHANGING
                      cs_item     = <fs_item>
                      cv_doc_rev  = <fs_item>-bln_r_mr3
                      cv_year_rev = <fs_item>-gjr_r_mr3
                  ).

                  "---Estorno CO/PA
                  me->reverse_copa(
                    CHANGING
                      cs_item = <fs_item>
                  ).

                  "---Erro em caso de configuração não encontrada ou retorno de erro em bapi
                CATCH zcx_co_process_banc_imp_upload.
              ENDTRY.

            ENDLOOP.

            IF me->gv_save = abap_true.

              "---Modifica dados
              IF me->gv_error = abap_true.

                me->change_data( iv_process = abap_false
                                 iv_error   = abap_true ).

              ELSE.

                me->change_data( iv_process = abap_false ).

              ENDIF.

              "---Salva dados com erro ou sucesso do processamento
              me->save_data( ).

            ENDIF.

            "---Desbloqueia tabela
            me->dequeue_bc( ).

          CATCH cx_root INTO DATA(lo_root).

            IF me->gv_save = abap_true.

              "---Altera status
              <fs_item>-status = gc_bc_pc_status-itm_nk.

              insert_log(
                EXPORTING
                  is_item    = <fs_item>
                  iv_type    = gc_bc_log_type-error
                  iv_message = |{ lo_root->get_longtext( ) }|
              ).

              me->change_data(
                EXPORTING
                  iv_process      = abap_false
                  iv_error        = abap_true
              ).

              "---Salva dados com erro não reconhecido
              me->save_data( ).

            ENDIF.

            "---Desbloqueia tabela
            me->dequeue_bc( ).

        ENDTRY.

      CATCH zcx_co_process_banc_imp_upload INTO lo_cx.

        "---Salva dados com erro previsto
        me->save_data( ).

        "---Desbloqueia tabela
        me->dequeue_bc( ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
          EXPORTING
            iv_textid = lo_cx->if_t100_message~t100key
            iv_msgv1  = lo_cx->gv_msgv1
            iv_msgv2  = lo_cx->gv_msgv2
            iv_msgv3  = lo_cx->gv_msgv3
            iv_msgv4  = lo_cx->gv_msgv4.

      CATCH cx_root INTO lo_root.

        "---Modifica dados
        me->change_data( iv_error_header = abap_true
                         iv_message      = lo_root->get_longtext( )
                         iv_sts_header   = gc_bc_status-error_rv
                         iv_sts_item     = gc_bc_pc_status-itm_nk ).

        "---Salva dados com erro previsto
        me->save_data( ).

        "---Desbloqueia tabela
        me->dequeue_bc( ).

    ENDTRY.

  ENDMETHOD.

  METHOD get_data.

    "---Seleciona os dados - Cabeçalho
    SELECT SINGLE FROM ztco_banc_imp_up
      FIELDS guid,
             filedirectory,
             status,
             created_by,
             created_at,
             last_changed_by,
             last_changed_at
     WHERE guid = @iv_sheet_guid
     INTO CORRESPONDING FIELDS OF @rs_data-header.

    IF rs_data-header IS NOT INITIAL.

      "---Itens
      SELECT FROM ztco_banc_imp_pc
       FIELDS guid,
              guiditem,
              bukrs,
              gsber,
              line,
              status,
              bln_c_fb,
              gjr_c_fb,
              bln_c_fb2,
              gjr_c_fb2,
              bln_c_fb3,
              gjr_c_fb3,
              bln_r_fb,
              gjr_r_fb,
              bln_r_fb2,
              gjr_r_fb2,
              bln_r_fb3,
              gjr_r_fb3,
              bln_c_mr,
              gjr_c_mr,
              bln_c_mr2,
              gjr_c_mr2,
              bln_c_mr3,
              gjr_c_mr3,
              bln_r_mr,
              gjr_r_mr,
              bln_r_mr2,
              gjr_r_mr2,
              bln_r_mr3,
              gjr_r_mr3,
              bln_c_cp,
              gjr_c_cp,
              bln_r_cp,
              gjr_r_cp
      WHERE guid = @iv_sheet_guid
      INTO CORRESPONDING FIELDS OF TABLE @rs_data-item.

    ENDIF.

    IF rs_data-item IS NOT INITIAL.

      "---Co/Pa
      SELECT FROM ztco_banc_imp_cp
       FIELDS guid,
              guiditem,
              guidcp,
              bln_c_cp,
              gjr_c_cp,
              bln_r_cp,
              gjr_r_cp
      WHERE guid = @iv_sheet_guid
      INTO CORRESPONDING FIELDS OF TABLE @rs_data-copa.

    ENDIF.

  ENDMETHOD.

  METHOD get_scenarios_process_config.

    DATA: lr_codigo TYPE RANGE OF ztco_banco_imp-codigo.

    lr_codigo = VALUE #( FOR ls_item IN me->gs_data-item
                          ( option = 'EQ'
                            sign   = 'I'
                            low    = ls_item-codigocenario ) ).

    SORT lr_codigo BY low.

    DELETE ADJACENT DUPLICATES FROM lr_codigo COMPARING low.
    DELETE lr_codigo WHERE low IS INITIAL.               "#EC CI_STDSEQ

    IF lr_codigo IS NOT INITIAL.

      "---Seleciona as configurações
      SELECT FROM ztco_banco_imp
       FIELDS codigo,
              elem_custo,
              mr22,
              sinal,
              fb50,
              debito,
              credito,
              tipo_documento,
              co_pa
      WHERE codigo IN @lr_codigo
      INTO CORRESPONDING FIELDS OF TABLE @me->gt_cfg.

    ELSE.

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
        EXPORTING
          iv_textid = zcx_co_process_banc_imp_upload=>gc_not_found.

    ENDIF.

    IF me->gt_cfg IS INITIAL.

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
        EXPORTING
          iv_textid = zcx_co_process_banc_imp_upload=>gc_configs_not_found.

    ENDIF.


  ENDMETHOD.

  METHOD get_infor_process_copa.

    "---Variáveis
    DATA: lr_docnum TYPE RANGE OF j_1bnflin-docnum,
          lr_matnr  TYPE RANGE OF j_1bnflin-matnr,
          lr_bwtar  TYPE RANGE OF j_1bnflin-bwtar,
          lr_rbeln  TYPE RANGE OF ce1ar3c-rbeln,
          lr_werks  TYPE RANGE OF ce1ar3c-werks,
          lr_gsber  TYPE RANGE OF ce1ar3c-gsber,
          lr_perio  TYPE RANGE OF ce1ar3c-perio.

    "---Busca dados adicionais para lançamento de co/pa com referência
    lr_docnum = VALUE #( FOR ls_item IN me->gs_data-item
                           FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                         AND   co_pa  = abap_true )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-notafiscal ) ).

    SORT lr_docnum BY low.

    DELETE ADJACENT DUPLICATES FROM lr_docnum COMPARING low.
    DELETE lr_docnum WHERE low IS INITIAL.               "#EC CI_STDSEQ

    lr_matnr = VALUE #( FOR ls_item IN me->gs_data-item
                          FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                        AND   co_pa  = abap_true )
                           ( option = 'EQ'
                             sign   = 'I'
                             low    = ls_item-material ) ).

    SORT lr_matnr BY low.

    DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.
    DELETE lr_matnr WHERE low IS INITIAL.                "#EC CI_STDSEQ

    lr_bwtar = VALUE #( FOR ls_item IN me->gs_data-item
                          FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                        AND   co_pa  = abap_true )
                           ( option = 'EQ'
                             sign   = 'I'
                             low    = ls_item-tipoavaliacao ) ).

    SORT lr_bwtar BY low.

    DELETE ADJACENT DUPLICATES FROM lr_bwtar COMPARING low.
    DELETE lr_bwtar WHERE low IS INITIAL.                "#EC CI_STDSEQ

    IF lr_docnum[] IS NOT INITIAL.

      "---Seleciona informações para preenchimento de bapi
      SELECT FROM j_1bnflin                             "#EC CI_SEL_DEL
        FIELDS docnum,
               matnr,
               bwtar,
               refkey
        WHERE docnum IN @lr_docnum
          AND matnr  IN @lr_matnr
          AND bwtar  IN @lr_bwtar
        INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_pc_copa-nota.

      SORT me->gs_inf_pc_copa-nota BY docnum
                                      matnr
                                      bwtar.

      DELETE ADJACENT DUPLICATES FROM me->gs_inf_pc_copa-nota COMPARING docnum
                                                                        matnr
                                                                        bwtar.

      DELETE me->gs_inf_pc_copa-nota WHERE refkey IS INITIAL. "#EC CI_STDSEQ

      lr_rbeln = VALUE #( FOR ls_nota IN me->gs_inf_pc_copa-nota
                             ( option = 'EQ'
                               sign   = 'I'
                               low    = ls_nota-refkey(10) ) ).

      SORT lr_rbeln BY low.

      DELETE ADJACENT DUPLICATES FROM lr_rbeln COMPARING low.
      DELETE lr_rbeln WHERE low IS INITIAL.              "#EC CI_STDSEQ

      IF lr_rbeln[] IS NOT INITIAL.

        SELECT FROM ce1ar3c                             "#EC CI_NOFIELD
                                                        "#EC CI_SEL_DEL
         FIELDS rbeln,
                rposn,
                paledger,
                vrgar,
                perio,
                artnr,
                bwtar,
                fkart,
                werks,
                gsber,
                brsch,
                bzirk,
                kdgrp,
                kmkdgr,
                kmmakl,
                kmvkbu,
                kmvkgr,
                kmvtnr,
                matkl,
                prodh,
                vkbur,
                vkgrp,
                wwmt1,
                wwrps,
                wwtpc,
                wwmt2,
                wwmt3,
                wwmt4,
                wwmt5,
                wwrep,
                kunre,
                partner,
                kunwe,
                wwm10,
                wwm11,
                wwmt9,
                vtweg,
                kaufn,
                segment,
                vkorg,
                erlos
         WHERE rbeln IN @lr_rbeln
           AND artnr IN @lr_matnr

         INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_pc_copa-with_ref.

        SORT me->gs_inf_pc_copa-with_ref BY rbeln
                                           artnr.

        DELETE ADJACENT DUPLICATES FROM me->gs_inf_pc_copa-with_ref COMPARING rbeln
                                                                             artnr.

      ENDIF.

      "---Busca dados adicionais para lançamento de co/pa sem referência
      lr_perio = VALUE #( FOR ls_item IN me->gs_data-item
                             FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                           AND   co_pa  = abap_true )
                              ( option = 'EQ'
                                sign   = 'I'
                                low    = |{ ls_item-data(4) }0{ ls_item-data+4(2) }| ) ).

      SORT lr_perio BY low.

      DELETE ADJACENT DUPLICATES FROM lr_perio COMPARING low.
      DELETE lr_perio WHERE low IS INITIAL.              "#EC CI_STDSEQ

      "---Busca dados adicionais para lançamento de co/pa sem referência
      lr_werks = VALUE #( FOR ls_item IN me->gs_data-item
                             FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                           AND   co_pa  = abap_true )
                              ( option = 'EQ'
                                sign   = 'I'
                                low    = ls_item-centro ) ).

      SORT lr_werks BY low.

      DELETE ADJACENT DUPLICATES FROM lr_werks COMPARING low.
      DELETE lr_werks WHERE low IS INITIAL.              "#EC CI_STDSEQ

      "---Busca dados adicionais para lançamento de co/pa sem referência
      lr_gsber = VALUE #( FOR ls_item IN me->gs_data-item
                             FOR ls_config IN me->gt_cfg WHERE ( codigo = ls_item-codigocenario "#EC CI_STDSEQ
                                                           AND   co_pa  = abap_true )
                              ( option = 'EQ'
                                sign   = 'I'
                                low    = ls_item-divisao ) ).

      SORT lr_gsber BY low.

      DELETE ADJACENT DUPLICATES FROM lr_gsber COMPARING low.
      DELETE lr_gsber WHERE low IS INITIAL.              "#EC CI_STDSEQ

      SELECT FROM ce1ar3c                               "#EC CI_NOFIELD
                                                        "#EC CI_SEL_DEL
         FIELDS rbeln,
                rposn,
                paledger,
                vrgar,
                perio,
                artnr,
                bwtar,
                fkart,
                werks,
                gsber,
                brsch,
                bzirk,
                kdgrp,
                kmkdgr,
                kmmakl,
                kmvkbu,
                kmvkgr,
                kmvtnr,
                matkl,
                prodh,
                vkbur,
                vkgrp,
                wwmt1,
                wwrps,
                wwtpc,
                wwmt2,
                wwmt3,
                wwmt4,
                wwmt5,
                wwrep,
                kunre,
                partner,
                kunwe,
                wwm10,
                wwm11,
                wwmt9,
                vtweg,
                kaufn,
                segment,
                vkorg,
                erlos
         WHERE paledger  = '10'
           AND vrgar     = 'F'
           AND sto_belnr = ''
           AND perio IN @lr_perio
           AND artnr IN @lr_matnr
           AND fkart IN ('Z001', 'Z002', 'Z003', 'Z004', 'Z005',
                         'Z007', 'Z008', 'Z009', 'Z010', 'Z014',
                         'Z015', 'Z018', 'Z019', 'Z020', 'Z021',
                         'Z025', 'Z026', 'Z099' )
           AND bwtar IN @lr_bwtar
           AND werks IN @lr_werks
           AND gsber IN @lr_gsber

         INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_pc_copa-without_ref.

    ENDIF.

  ENDMETHOD.

  METHOD get_infor_reverse_mr22.

    "---Variáveis
    DATA: lr_belnr TYPE RANGE OF belnr_D,
          lr_gjahr TYPE RANGE OF gjahr,
          lr_awkey TYPE RANGE OF awkey.

    "---Ranger do documento
    lr_belnr = VALUE #( FOR ls_item IN me->gs_data-item WHERE ( bln_c_mr  IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  bln_c_mr2 IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  bln_c_mr3 IS NOT INITIAL ) "#EC CI_STDSEQ
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-bln_c_mr )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-bln_c_mr2 )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-bln_c_mr3 ) ).

    SORT lr_belnr BY low.

    DELETE ADJACENT DUPLICATES FROM lr_belnr COMPARING low.
    DELETE lr_belnr WHERE low IS INITIAL.                "#EC CI_STDSEQ

    "---Ranger de ano do documento
    lr_gjahr = VALUE #( FOR ls_item IN me->gs_data-item WHERE ( gjr_c_mr  IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  gjr_c_mr2 IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  gjr_c_mr3 IS NOT INITIAL ) "#EC CI_STDSEQ
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-gjr_c_mr )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-gjr_c_mr2 )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = ls_item-gjr_c_mr3 ) ).

    SORT lr_gjahr BY low.

    DELETE ADJACENT DUPLICATES FROM lr_gjahr COMPARING low.
    DELETE lr_gjahr WHERE low IS INITIAL.                "#EC CI_STDSEQ

    "---Ranger de referência
    lr_awkey = VALUE #( FOR ls_item IN me->gs_data-item WHERE ( bln_c_mr  IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  bln_c_mr2 IS NOT INITIAL "#EC CI_STDSEQ
                                                            OR  bln_c_mr3 IS NOT INITIAL ) "#EC CI_STDSEQ
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = |{ ls_item-bln_c_mr }{ ls_item-gjr_c_mr }| )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = |{ ls_item-bln_c_mr2 }{ ls_item-gjr_c_mr2 }| )
                            ( option = 'EQ'
                              sign   = 'I'
                              low    = |{ ls_item-bln_c_mr3 }{ ls_item-gjr_c_mr3 }| ) ).

    SORT lr_awkey BY low.

    DELETE ADJACENT DUPLICATES FROM lr_awkey COMPARING low.
    DELETE lr_awkey WHERE low IS INITIAL.                "#EC CI_STDSEQ

    CHECK lr_belnr[] IS NOT INITIAL
      AND lr_gjahr[] IS NOT INITIAL.

    "---Informações da mr22
    SELECT FROM mlhd AS hd
      INNER JOIN mlit AS it ON
         ( it~belnr = hd~belnr
       AND it~kjahr = hd~kjahr )
      FIELDS hd~belnr,
             hd~kjahr AS gjahr,
             hd~bldat,
             it~matnr,
             it~bwkey,
             it~bwtar
    WHERE hd~belnr IN @lr_belnr
      AND hd~kjahr IN @lr_gjahr
    INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_rv_mr22-mlhd.

    "---Informação de valores
    SELECT FROM bkpf AS hd
      INNER JOIN bseg AS it ON
         ( it~bukrs = hd~bukrs
       AND it~belnr = hd~belnr
       AND it~gjahr = hd~gjahr
       AND it~hkont IN ('4520000001', '4520000005') )
      FIELDS hd~awkey,
             hd~xblnr,
             it~dmbtr,
             it~shkzg
    WHERE hd~awkey IN @lr_awkey
    INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_rv_mr22-bkpf.

  ENDMETHOD.

  METHOD get_infor_reverse_copa.

    "---Variáveis
    DATA: lr_belnr TYPE RANGE OF belnr_D,
          lr_gjahr TYPE RANGE OF gjahr,
          lr_awkey TYPE RANGE OF awkey.

    "---Ranger do documento
    lr_belnr = VALUE #( FOR <fs_item> IN me->gs_data-copa WHERE ( bln_c_cp  IS NOT INITIAL ) "#EC CI_STDSEQ
                            ( option = 'EQ'              "#EC CI_STDSEQ
                              sign   = 'I'               "#EC CI_STDSEQ
                              low    = <fs_item>-bln_c_cp ) ). "#EC CI_STDSEQ

    SORT lr_belnr BY low.

    DELETE ADJACENT DUPLICATES FROM lr_belnr COMPARING low.
    DELETE lr_belnr WHERE low IS INITIAL.                "#EC CI_STDSEQ

    "---Ranger de ano do documento
    lr_gjahr = VALUE #( FOR <fs_item> IN me->gs_data-copa WHERE ( gjr_c_cp  IS NOT INITIAL ) "#EC CI_STDSEQ
                            ( option = 'EQ'              "#EC CI_STDSEQ
                              sign   = 'I'               "#EC CI_STDSEQ
                              low    = <fs_item>-gjr_c_cp ) ). "#EC CI_STDSEQ

    SORT lr_gjahr BY low.

    DELETE ADJACENT DUPLICATES FROM lr_gjahr COMPARING low.
    DELETE lr_gjahr WHERE low IS INITIAL.                "#EC CI_STDSEQ

    CHECK lr_belnr[] IS NOT INITIAL
      AND lr_gjahr[] IS NOT INITIAL.

    "---Seleciona dados adicionais
    SELECT FROM ce1ar3c "#EC CI_SEL_DEL                           "#EC CI_NOFIELD
     FIELDS belnr,
            gjahr,
            kokrs,
            vrgar,
            budat,
            bukrs,
            werks,
            gsber,
            artnr,
            brsch,
            bzirk,
            kdgrp,
            kmkdgr,
            kmmakl,
            kmvkbu,
            kmvkgr,
            kmvtnr,
            matkl,
            prodh,
            vkbur,
            vkgrp,
            wwmt1,
            wwrps,
            wwtpc,
            wwmt2,
            wwmt3,
            wwmt4,
            wwmt5,
            wwrep,
            kunre,
            partner,
            kunwe,
            wwm10,
            wwm11,
            wwmt9,
            bwtar,
            fkart,
            vtweg,
            kaufn,
            segment,
            vkorg
     WHERE belnr IN @lr_belnr
       AND gjahr IN @lr_gjahr
     INTO CORRESPONDING FIELDS OF TABLE @me->gs_inf_rv_copa-ce1ar3c.

    SORT me->gs_inf_rv_copa-ce1ar3c BY belnr
                                       gjahr.

    DELETE ADJACENT DUPLICATES FROM me->gs_inf_rv_copa-ce1ar3c COMPARING belnr
                                                                         gjahr.

  ENDMETHOD.

  METHOD enqueue_bc.

    TYPES: ty_t_seq TYPE TABLE OF seqg3 WITH DEFAULT KEY.

    DATA: lt_seq TYPE ty_t_seq.

    "---Recupera classe de bloqueio da tabela
    TRY.
        go_lock = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZTCO_BANC_IM_UP' ).
      CATCH cx_abap_lock_failure.
        "handle exception
    ENDTRY.

    "---Verifica bloqueio para não colidir lançamento simultâneo
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gclient = sy-mandt
        gname   = CONV seqg3-gname( |ZTCO_BANC_IMP_UP| )
        garg    = CONV seqg3-garg( |{ sy-mandt }{ me->gv_sheet_guid }| )
        guname  = '*'
      TABLES
        enq     = lt_seq
                  EXCEPTIONS
                  communication_failure
                  system_failure.

    IF  lt_seq IS INITIAL
    AND sy-subrc  IS INITIAL.

      TRY.

          "Realiza Bloqueio
          TRY.

              go_lock->enqueue(
              it_parameter = VALUE #( ( name = 'MANDT' value = REF #( sy-mandt ) )
                                      ( name = 'GUID'  value = REF #( me->gv_sheet_guid ) ) )
              ).

            CATCH cx_abap_lock_failure INTO DATA(lo_exce).

              "---Objeto Bloqueado
              RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
                EXPORTING
                  iv_textid = zcx_co_process_banc_imp_upload=>gc_bc_blocked.

          ENDTRY.

          "---Indica que objeto está bloqueado
        CATCH cx_abap_foreign_lock INTO DATA(lo_foreign_lock).

          "---Objeto Bloqueado
          RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
            EXPORTING
              iv_textid = zcx_co_process_banc_imp_upload=>gc_bc_blocked.

      ENDTRY.

    ELSE.

      IF NOT line_exists( lt_seq[ guname = sy-uname ] ). "#EC CI_STDSEQ

        "---Objeto Bloqueado
        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload
          EXPORTING
            iv_textid = zcx_co_process_banc_imp_upload=>gc_bc_blocked.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD dequeue_bc.

    "---Executa desbloqueio
    TRY.
        go_lock->dequeue( it_parameter = VALUE #( ( name = 'MANDT' value = REF #( sy-mandt ) )
                                                  ( name = 'GUID'  value = REF #( me->gv_sheet_guid ) ) ) ).
      CATCH cx_abap_lock_failure.
        "handle exception
    ENDTRY.

  ENDMETHOD.

  METHOD convert_currency.

    "---Conversão para moeda estrangeira
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

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDIF.

  ENDMETHOD.

  METHOD change_data.

    "---Variáveis
    DATA: ls_item LIKE LINE OF me->gs_data-item.
    DATA: ls_copa LIKE LINE OF me->gs_data-copa.

    "---Modifica status para item não processado antes do processamento.
    IF iv_mod_sts_item = abap_true.

      ASSIGN me->gs_data-item[ 1 ] TO FIELD-SYMBOL(<fs_item>).

      <fs_item>-status = iv_sts_item.

      "---Adiciona status
      MODIFY me->gs_data-item FROM <fs_item> TRANSPORTING status WHERE guid = me->gs_data-header-guid. "#EC CI_STDSEQ

      "---Erro antes do processamento
    ELSEIF iv_error_header = abap_true.

      IF me->gs_data-header IS NOT INITIAL.

        me->gs_data-header-last_changed_at = me->gv_times.
        me->gs_data-header-last_changed_by = sy-uname.
        me->gs_data-header-status          = iv_sts_header.

        LOOP AT me->gs_data-item ASSIGNING <fs_item>.

          <fs_item>-status = iv_sts_item.

          me->insert_log(
            EXPORTING
              is_item    = <fs_item>
              iv_type    = gc_bc_log_type-error
              iv_message = iv_message
          ).

        ENDLOOP.

      ENDIF.

    ELSEIF iv_error = abap_true.

      "---Rowback dos processos
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      "---Retira dados dos documentos dos itens e modifica status header
      IF iv_process = abap_true.

        me->gs_data-header-status = gc_bc_status-error_pc."Processado com Erro

        MODIFY me->gs_data-item FROM ls_item TRANSPORTING bln_c_fb
                                                          gjr_c_fb
                                                          bln_c_fb2
                                                          gjr_c_fb2
                                                          bln_c_fb3
                                                          gjr_c_fb3
                                                          bln_c_mr
                                                          gjr_c_mr
                                                          bln_c_mr2
                                                          gjr_c_mr2
                                                          bln_c_mr3
                                                          gjr_c_mr3
                                                          bln_c_cp
                                                          gjr_c_cp
                                              WHERE guid = me->gv_sheet_guid. "#EC CI_STDSEQ

        "---Limpa CO/PAs
        CLEAR me->gs_data-copa.

      ELSE.

        me->gs_data-header-status = gc_bc_status-error_rv."Estornado com Erro

        "---Limpa documentos gerados
        MODIFY me->gs_data-item FROM ls_item TRANSPORTING bln_r_fb
                                                          gjr_r_fb
                                                          bln_r_fb2
                                                          gjr_r_fb2
                                                          bln_r_fb3
                                                          gjr_r_fb3
                                                          bln_r_mr
                                                          gjr_r_mr
                                                          bln_r_mr2
                                                          gjr_r_mr2
                                                          bln_r_mr3
                                                          gjr_r_mr3
                                                          bln_r_cp
                                                          gjr_r_cp
                                             WHERE guid = me->gv_sheet_guid. "#EC CI_STDSEQ

        MODIFY me->gs_data-copa FROM ls_copa TRANSPORTING bln_r_cp
                                                          gjr_r_cp
                                             WHERE guid = me->gv_sheet_guid. "#EC CI_STDSEQ

      ENDIF.

    ELSE.

      "---Atualiza status header
      IF iv_process = abap_true.

        me->gs_data-header-status = gc_bc_status-succs_pc."Processado

      ELSE.

        me->gs_data-header-status = gc_bc_status-succs_pr."Estornado

      ENDIF.

      "---Insere log de sucesso
      LOOP AT me->gs_data-item ASSIGNING <fs_item>.      "#EC CI_STDSEQ

        me->insert_log(
          EXPORTING
            is_item    = <fs_item>
            iv_type    = gc_bc_log_type-sucss
            iv_message = COND #( WHEN iv_process = abap_true
                                  THEN TEXT-p01   "Sucesso ao processar linha.
                                  ELSE TEXT-r01 ) "Sucesso ao estornar linha.
        ).

      ENDLOOP.


      "---Salva Registros
      MODIFY ztco_banc_imp_up FROM me->gs_data-header. "#EC CI_IMUD_NESTED

      MODIFY ztco_banc_imp_pc FROM TABLE me->gs_data-item. "#EC CI_IMUD_NESTED

      MODIFY ztco_banc_imp_cp FROM TABLE me->gs_data-copa. "#EC CI_IMUD_NESTED

      MODIFY ztco_banc_imp_lg FROM TABLE me->gt_log. "#EC CI_IMUD_NESTED

      "---Realiza Commmit dos dados
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

    ENDIF.

  ENDMETHOD.

  METHOD save_data.

    IF gs_data-header IS NOT INITIAL.

      MODIFY ztco_banc_imp_up FROM me->gs_data-header.

    ENDIF.

    IF me->gs_data-item IS NOT INITIAL.

      MODIFY ztco_banc_imp_pc FROM TABLE me->gs_data-item.

    ENDIF.

    IF me->gt_log IS NOT INITIAL.

      MODIFY ztco_banc_imp_lg FROM TABLE me->gt_log.

    ENDIF.

    IF me->gs_data-copa IS NOT INITIAL.

      MODIFY ztco_banc_imp_cp FROM TABLE me->gs_data-copa.

    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD execute_fb50.

    "---Types
    TYPES: ty_t_accgl    TYPE TABLE OF bapiacgl08 WITH DEFAULT KEY,
           ty_t_currency TYPE TABLE OF bapiaccr08 WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Variáveis
    DATA: lv_obj_type TYPE awtyp,
          lv_obj_key  TYPE awkey,
          lv_obj_sys  TYPE awsys.

    "---Tabelas
    DATA: lt_accountgl      TYPE ty_t_accgl,
          lt_currencyamount TYPE ty_t_currency,
          lt_return         TYPE ty_t_return.

    "---Estruturas
    DATA: ls_document TYPE bapiache08.

    CHECK is_config-fb50 = abap_true.

    "---Cabeçalho
    ls_document-obj_type   = 'BKPFF'.
    ls_document-obj_key    = '1'.
    ls_document-pstng_date = cs_item-data.
    ls_document-doc_date   = cs_item-data.
    ls_document-username   = sy-uname.
    ls_document-comp_code  = cs_item-empresa.
    ls_document-ref_doc_no = cs_item-notafiscal.
    ls_document-fisc_year  = cs_item-data(4).
    ls_document-fis_period = cs_item-data+4(2).
    ls_document-doc_type   = is_config-tipo_documento.

    "---Contas
    APPEND INITIAL LINE TO lt_accountgl ASSIGNING FIELD-SYMBOL(<fs_acc>).

    <fs_acc>-itemno_acc = 1.
    <fs_acc>-pstng_date = cs_item-data.
    <fs_acc>-bus_area   = cs_item-divisao.
    <fs_acc>-gl_account = is_config-debito.

    APPEND INITIAL LINE TO lt_accountgl ASSIGNING <fs_acc>.

    <fs_acc>-itemno_acc = 2.
    <fs_acc>-pstng_date = cs_item-data.
    <fs_acc>-bus_area   = cs_item-divisao.
    <fs_acc>-gl_account = is_config-credito.

    "---Moeda
    APPEND INITIAL LINE TO lt_currencyamount ASSIGNING FIELD-SYMBOL(<fs_amt>).

    <fs_amt>-itemno_acc = 1.
    <fs_amt>-curr_type  = '00'.
    <fs_amt>-currency   = 'BRL'.
    <fs_amt>-amt_doccur = COND #( WHEN iv_value < 0 THEN iv_value * -1
                                 ELSE iv_value ).

    APPEND INITIAL LINE TO lt_currencyamount ASSIGNING <fs_amt>.

    <fs_amt>-itemno_acc = 2.
    <fs_amt>-curr_type  = '00'.
    <fs_amt>-currency   = 'BRL'.
    <fs_amt>-amt_doccur = COND #( WHEN iv_value > 0 THEN iv_value * -1
                                 ELSE iv_value ).

    "---Lançamento
    CALL FUNCTION 'BAPI_ACC_GL_POSTING_POST'
      EXPORTING
        documentheader = ls_document
      IMPORTING
        obj_type       = lv_obj_type
        obj_key        = lv_obj_key
        obj_sys        = lv_obj_sys
      TABLES
        accountgl      = lt_accountgl
        currencyamount = lt_currencyamount
        return         = lt_return.

    "---Trata erro se caso houver
    IF line_exists( lt_return[ type = 'E' ] ).           "#EC CI_STDSEQ

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = me->gc_bc_pc_status-itm_nk. "Item com erro

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

      APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

      "---Erro ao lançar FB50
      <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
      <fs_ret>-number = |007|.
      <fs_ret>-type   = gc_bc_log_type-warng.

      SORT lt_return DESCENDING BY type.

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          it_bapiret = lt_return
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ELSE.

      "---Item
      cs_item-status             = gc_bc_pc_status-itm_ok.
      cv_doc                     = lv_obj_key(10).
      cv_year                    = lv_obj_key+14(4).

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

    ENDIF.


  ENDMETHOD.

  METHOD execute_mr22.

    "---Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Tabelas
    DATA: lt_currency TYPE ty_t_currency,
          lt_mdc      TYPE ty_t_mdc,
          lt_return   TYPE ty_t_return.

    "---Estruturas
    DATA: ls_document TYPE bapi_pricechange_document.

    CHECK is_config-mr22 = abap_true.

    "---Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = cs_item-centro
      TABLES
        t_curtp_for_va      = lt_currency
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = gc_bc_pc_status-itm_nk.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_message_error).

      "---Erro ao lançar MR22
      MESSAGE e008(zco_banco_impostos) INTO DATA(lv_message).

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-warng
          iv_message = lv_message
      ).

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-error
          iv_message = lv_message_error
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDIF.

    "---Montagem
    DATA(lv_taxval) = COND j_1btaxval( WHEN is_config-sinal = '-' AND iv_value > 0 THEN iv_value * -1
                                       WHEN is_config-sinal = '+' AND iv_value < 0 THEN iv_value * -1
                                       ELSE iv_value ).

    TRY.

        lt_mdc = VALUE #( FOR ls_currency IN lt_currency
                             ( curr_type     = ls_currency-currtyp
                               currency      = ls_currency-waers
                               amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                        THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                        ELSE lv_taxval )
                               quantity_unit = 'UN' ) ).

      CATCH zcx_co_process_banc_imp_upload.

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message_error.

        "---Erro ao lançar MR22
        MESSAGE e008(zco_banco_impostos) INTO lv_message.

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-warng
            iv_message = lv_message
        ).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-error
            iv_message = lv_message_error
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDTRY.

    "---Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( cs_item-material )
        valuationarea         = cs_item-centro
        valuationtype         = cs_item-tipoavaliacao
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = cs_item-data(4)
                                                                   fisc_period = cs_item-data+4(2)
                                                                   pstng_date  = cs_item-data )
        ref_doc_no            = is_config-elem_custo
      IMPORTING
        debitcreditdocument   = ls_document
      TABLES
        return                = lt_return
        material_debit_credit = lt_mdc.


    "---Trata erro se caso houver
    IF line_exists( lt_return[ type = 'E' ] ).           "#EC CI_STDSEQ

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = gc_bc_pc_status-itm_nk.

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

      APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

      "---Erro ao lançar MR22
      <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
      <fs_ret>-number = |008|.
      <fs_ret>-type   = gc_bc_log_type-warng.

      SORT lt_return DESCENDING BY type.

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          it_bapiret = lt_return
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ELSE.

      cs_item-status           = gc_bc_pc_status-itm_ok.
      cv_doc                   = ls_document-ml_doc_num.
      cv_year                  = ls_document-ml_doc_year.

    ENDIF.

  ENDMETHOD.

  METHOD execute_copa.

    "---Types
    TYPES: BEGIN OF ty_s_doc,
             belnr TYPE belnr_D,
             gjahr TYPE gjahr,
           END OF ty_s_doc,

           ty_t_inputdata TYPE TABLE OF bapi_copa_data WITH DEFAULT KEY,
           ty_t_fieldlist TYPE TABLE OF bapi_copa_field WITH DEFAULT KEY,
           ty_t_return    TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Tabelas
    DATA: lt_inputdata TYPE ty_t_inputdata,
          lt_fieldlist TYPE ty_t_fieldlist,
          lt_return    TYPE ty_t_return,
          lt_copa      TYPE me->ty_s_infor_pc_copa-without_ref.

    "---Estruturas
    DATA: ls_document TYPE bapi_pricechange_document,
          ls_copa     TYPE ty_s_doc.

    "---Variáveis
    DATA: lv_operatingconcern TYPE bapi0017-op_concern,
          lv_testrun          TYPE bapi0017-testrun,
          lv_program          TYPE char2 VALUE 'BC'. "---Banco de impostos

    "---Field-Symbols
    FIELD-SYMBOLS: <fs_field> LIKE LINE OF lt_fieldlist,
                   <fs_input> LIKE LINE OF lt_inputdata.

    CHECK me->gs_icms-co_pa   = abap_true
       OR me->gs_icmsst-co_pa = abap_true
       OR me->gs_ipi-co_pa    = abap_true.

    "---Inserção dos campos e dados CO/PA
    DEFINE insert_data.

      APPEND INITIAL LINE TO lt_fieldlist ASSIGNING <fs_field>.

      APPEND INITIAL LINE TO lt_inputdata ASSIGNING <fs_input>.

      <fs_input>-record_id = &1.
      <fs_field>-fieldname = &2.
      <fs_input>-fieldname = &2.
      <fs_input>-value     = &3.
      <fs_input>-currency  = 'BRL'.

    END-OF-DEFINITION.

    "---Montagem dos dados
    lv_operatingconcern = |AR3C|.

    "---Realiza busca de CO/PA por referência da nota
    ASSIGN me->gs_inf_pc_copa-nota[ docnum = cs_item-notafiscal "#EC CI_STDSEQ
                                    matnr  = cs_item-material
                                    bwtar  = cs_item-tipoavaliacao ] TO FIELD-SYMBOL(<fs_nota>).

    IF <fs_nota> IS ASSIGNED.

      "---Busca dados CO/PA
      ASSIGN me->gs_inf_pc_copa-with_ref[ rbeln  = <fs_nota>-refkey "#EC CI_STDSEQ
                                          artnr  = <fs_nota>-matnr  ] TO FIELD-SYMBOL(<fs_copa>).

    ENDIF.

    "---Busca dados CO/PA sem referência em caso de icms, caso não encontre nas buscas anteriores.
    IF <fs_copa> IS NOT ASSIGNED.

      DATA(lv_without_ref) = abap_true.

      lt_copa = me->gs_inf_pc_copa-without_ref.

      DELETE lt_copa WHERE perio <> |{ cs_item-data(4) }0{ cs_item-data+4(2) }|
                        OR artnr <> cs_item-material     "#EC CI_STDSEQ
                        OR bwtar <> cs_item-tipoavaliacao
                        OR werks <> cs_item-centro
                        OR gsber <> cs_item-divisao.

      IF lt_copa IS INITIAL
      OR me->gs_icms-co_pa <> abap_true.

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        "---Erro ao lançar CO/PA
        MESSAGE e009(zco_banco_impostos) INTO DATA(lv_message).

        "---Dados CO/PA não encontrados para lançamento.
        MESSAGE e006(zco_banco_impostos) INTO DATA(lv_message_error).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-warng
            iv_message = lv_message
        ).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-error
            iv_message = lv_message_error
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

      ELSE.

        "---Cálcula valor para rateio
        DATA(lv_val_tot_rateio) = REDUCE rke2_erlos( INIT lv_vl TYPE rke2_erlos FOR <fs_cp> IN lt_copa NEXT lv_vl = lv_vl + <fs_cp>-erlos ).

      ENDIF.

    ELSE.

      APPEND <fs_copa> TO lt_copa.

    ENDIF.

    LOOP AT lt_copa ASSIGNING <fs_copa>.

      CLEAR: lt_fieldlist,
             lt_inputdata.

      DATA(lv_count) = 1.

      "---FieldList
      insert_data lv_count 'KOKRS'   'AC3C'.
      insert_data lv_count 'VRGAR'   'Z'.
      insert_data lv_count 'BUDAT'   cs_item-data.
      insert_data lv_count 'BUKRS'   cs_item-empresa.
      insert_data lv_count 'WERKS'   cs_item-centro.
      insert_data lv_count 'GSBER'   cs_item-divisao.

      IF  me->gs_icms-co_pa = abap_true.

        IF lv_without_ref = abap_true.

          "---Porcentagem
          DATA(lv_percent) = CONV p10_perct( <fs_copa>-erlos / lv_val_tot_rateio ).

          "---Valor
          DATA(lv_icms) = CONV netpr( cs_item-valoricms * lv_percent ).

          insert_data lv_count 'VV019' lv_icms.

        ELSE.

          insert_data lv_count 'VV019' cs_item-valoricms.

        ENDIF.

      ENDIF.

      IF me->gs_icmsst-co_pa = abap_true.

        insert_data lv_count 'VV018' cs_item-valoricmsst.

      ENDIF.

      IF me->gs_ipi-co_pa = abap_true.

        insert_data lv_count 'VV026' cs_item-valoripi.

      ENDIF.

      insert_data lv_count 'ARTNR'     cs_item-material.
      insert_data lv_count 'BRSCH'     <fs_copa>-brsch.
      insert_data lv_count 'BZIRK'     <fs_copa>-bzirk.
      insert_data lv_count 'KDGRP'     <fs_copa>-kdgrp.
      insert_data lv_count 'KMKDGR'    <fs_copa>-kmkdgr.
      insert_data lv_count 'KMMAKL'    <fs_copa>-kmmakl.
      insert_data lv_count 'KMVKBU'    <fs_copa>-kmvkbu.
      insert_data lv_count 'KMVKGR'    <fs_copa>-kmvkgr.
      insert_data lv_count 'KMVTNR'    <fs_copa>-kmvtnr.
      insert_data lv_count 'MATKL'     <fs_copa>-matkl.
      insert_data lv_count 'PRODH'     <fs_copa>-prodh.
      insert_data lv_count 'VKBUR'     <fs_copa>-vkbur.
      insert_data lv_count 'VKGRP'     <fs_copa>-vkgrp.
      insert_data lv_count 'WWMT1'     <fs_copa>-wwmt1.
      insert_data lv_count 'WWRPS'     <fs_copa>-wwrps.
      insert_data lv_count 'WWTPC'     <fs_copa>-wwtpc.
      insert_data lv_count 'WWMT2'     <fs_copa>-wwmt2.
      insert_data lv_count 'WWMT3'     <fs_copa>-wwmt3.
      insert_data lv_count 'WWMT4'     <fs_copa>-wwmt4.
      insert_data lv_count 'WWMT5'     <fs_copa>-wwmt5.
      insert_data lv_count 'WWREP'     <fs_copa>-wwrep.
      insert_data lv_count 'KUNRE'     <fs_copa>-kunre.
      insert_data lv_count 'PARTNER'   <fs_copa>-partner.
      insert_data lv_count 'KUNWE'     <fs_copa>-kunwe.
      insert_data lv_count 'WWM10'     <fs_copa>-wwm10.
      insert_data lv_count 'WWM11'     <fs_copa>-wwm11.
      insert_data lv_count 'WWMT9'     <fs_copa>-wwmt9.
      insert_data lv_count 'BWTAR'     <fs_copa>-bwtar.
      insert_data lv_count 'FKART'     <fs_copa>-fkart.
      insert_data lv_count 'VTWEG'     <fs_copa>-vtweg.
      insert_data lv_count 'KAUFN'     <fs_copa>-kaufn.
      insert_data lv_count 'SEGMENT'   <fs_copa>-segment.
      insert_data lv_count 'VKORG'     <fs_copa>-vkorg.

      "---Exporta variável para identificar se será puxado o documento
      EXPORT lv_program = lv_program TO MEMORY ID 'ZBANC_IMP'.

      CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
        EXPORTING
          operatingconcern = lv_operatingconcern
          testrun          = lv_testrun
        TABLES
          inputdata        = lt_inputdata
          fieldlist        = lt_fieldlist
          return           = lt_return.

      "---Trata erro se caso houver
      IF line_exists( lt_return[ type = 'E' ] ).         "#EC CI_STDSEQ

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        "---Cabeçalho
        me->gs_data-header-last_changed_by = sy-uname.
        me->gs_data-header-last_changed_at = me->gv_times.

        APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

        "---Erro ao lançar CO/PA
        <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
        <fs_ret>-number = |009|.
        <fs_ret>-type   = gc_bc_log_type-warng.

        SORT lt_return DESCENDING BY type.             "#EC CI_SORTLOOP

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            it_bapiret = lt_return
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

      ELSE.

        IMPORT ls_copa = ls_copa FROM MEMORY ID 'ZBANC_IMP_COPA'.

        IF sy-subrc IS INITIAL.

          APPEND INITIAL LINE TO me->gs_data-copa ASSIGNING FIELD-SYMBOL(<fs_doc_copa>).

          TRY.
              <fs_doc_copa>-guid     = cs_item-guid.
              <fs_doc_copa>-guiditem = cs_item-guiditem.
              <fs_doc_copa>-guidcp  = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
            CATCH cx_uuid_error.
          ENDTRY.

          cs_item-status           = gc_bc_pc_status-itm_ok.
          <fs_doc_copa>-bln_c_cp   = ls_copa-belnr.
          <fs_doc_copa>-gjr_c_cp   = ls_copa-gjahr.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD reverse_fb50.

    "---Types
    TYPES: ty_t_accgl    TYPE TABLE OF bapiacgl08 WITH DEFAULT KEY,
           ty_t_currency TYPE TABLE OF bapiaccr08 WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Variáveis
    DATA: lv_obj_type TYPE awtyp,
          lv_obj_key  TYPE awkey,
          lv_obj_sys  TYPE awsys.

    "---Tabelas
    DATA: lt_accountgl      TYPE ty_t_accgl,
          lt_currencyamount TYPE ty_t_currency,
          lt_return         TYPE ty_t_return.

    "---Estruturas
    DATA: ls_reversal TYPE bapiacrev.

    CHECK iv_doc      IS NOT INITIAL
      AND iv_year     IS NOT INITIAL
      AND cv_doc_rev  IS INITIAL
      AND cv_year_rev IS INITIAL.

    "---Marca flag para salvar
    me->gv_save = abap_true.

    "---Dados para estorno
    ls_reversal-obj_type   = 'BKPFF'.
    ls_reversal-reason_rev = '01'.
    ls_reversal-comp_code  = cs_item-bukrs.
    ls_reversal-obj_key_r  = |{ iv_doc }{ cs_item-bukrs }{ iv_year }|.

    CALL FUNCTION 'BAPI_ACC_GL_POSTING_REV_POST'
      EXPORTING
        reversal = ls_reversal
      IMPORTING
        obj_type = lv_obj_type
        obj_key  = lv_obj_key
        obj_sys  = lv_obj_sys
      TABLES
        return   = lt_return.

    "---Trata erro em caso houver
    IF line_exists( lt_return[ type = 'E' ] ).           "#EC CI_STDSEQ

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = me->gc_bc_pc_status-itm_nk. "Item com erro

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

      APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

      "---Erro ao estornar FB50
      <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
      <fs_ret>-number = |010|.
      <fs_ret>-type   = gc_bc_log_type-warng.

      SORT lt_return DESCENDING BY type.

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          it_bapiret = lt_return
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ELSE.

      "---Item
      cs_item-status             = gc_bc_pc_status-itm_ok.
      cv_doc_rev                 = lv_obj_key(10).
      cv_year_rev                = lv_obj_key+14(4).

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

    ENDIF.

  ENDMETHOD.

  METHOD reverse_mr22.

    "---Types
    TYPES: ty_t_currency TYPE TABLE OF cki_ml_cty WITH DEFAULT KEY,
           ty_t_mdc      TYPE TABLE OF bapi_material_debit_credit_amt WITH DEFAULT KEY,
           ty_t_return   TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Tabelas
    DATA: lt_currency TYPE ty_t_currency,
          lt_mdc      TYPE ty_t_mdc,
          lt_return   TYPE ty_t_return.

    "---Estruturas
    DATA: ls_document TYPE bapi_pricechange_document.

    CHECK iv_doc      IS NOT INITIAL
      AND iv_year     IS NOT INITIAL
      AND cv_doc_rev  IS INITIAL
      AND cv_year_rev IS INITIAL.

    "---Marca flag para salvar
    me->gv_save = abap_true.

    "---Informações adicionais
    ASSIGN me->gs_inf_rv_mr22-mlhd[ belnr = iv_doc       "#EC CI_STDSEQ
                                    gjahr = iv_year ] TO FIELD-SYMBOL(<fs_hd>).

    ASSIGN me->gs_inf_rv_mr22-bkpf[ awkey = |{ iv_doc }{ iv_year }| ] TO FIELD-SYMBOL(<fs_bk>). "#EC CI_STDSEQ

    IF <fs_hd> IS NOT ASSIGNED
    OR <fs_bk> IS NOT ASSIGNED.

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = gc_bc_pc_status-itm_nk.

      "---Dados para execução de estorno com documento &1 e ano &2 não encontrados.
      MESSAGE e013(zco_banco_impostos) INTO DATA(lv_message_error) WITH iv_doc iv_year.

      "---Erro ao estornar MR22
      MESSAGE e011(zco_banco_impostos) INTO DATA(lv_message).

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-warng
          iv_message = lv_message
      ).

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-error
          iv_message = lv_message_error
      ).

      cs_item-status = gc_bc_pc_status-itm_nk.

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDIF.

    "---Pega moedas da nota
    CALL FUNCTION 'GET_BWKEY_CURRENCY_INFO'
      EXPORTING
        bwkey               = <fs_hd>-bwkey
      TABLES
        t_curtp_for_va      = lt_currency
      EXCEPTIONS
        bwkey_not_found     = 1
        bwkey_not_active    = 2
        matled_not_found    = 3
        internal_error      = 4
        more_than_3_curtp   = 5
        customizing_changed = 6
        OTHERS              = 7.

    IF sy-subrc <> 0.

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = gc_bc_pc_status-itm_nk.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message_error.

      "---Erro ao estornar MR22
      MESSAGE e011(zco_banco_impostos) INTO lv_message.

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-warng
          iv_message = lv_message
      ).

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          iv_type    = gc_bc_log_type-error
          iv_message = lv_message_error
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDIF.

    "---Montagem dos valores
    DATA(lv_taxval) = COND j_1btaxval( WHEN <fs_bk>-shkzg = 'H' THEN <fs_bk>-dmbtr
                                       WHEN <fs_bk>-shkzg = 'S' THEN <fs_bk>-dmbtr * -1
                                       ELSE <fs_bk>-dmbtr ).

    TRY.

        lt_mdc = VALUE #( FOR ls_currency IN lt_currency
                          ( curr_type     = ls_currency-currtyp
                            currency      = ls_currency-waers
                            amount        = COND #( WHEN ls_currency-waers <> 'BRL'
                                                     THEN convert_currency( is_currency = ls_currency iv_taxvalue = lv_taxval )
                                                    ELSE lv_taxval )
                            quantity_unit = 'UN' ) ).

      CATCH zcx_co_process_banc_imp_upload.

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message_error.

        "---Erro ao estornar MR22
        MESSAGE e011(zco_banco_impostos) INTO lv_message.

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-warng
            iv_message = lv_message
        ).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-error
            iv_message = lv_message_error
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ENDTRY.

    "---Lançamento
    CALL FUNCTION 'BAPI_MATVAL_DEBIT_CREDIT'
      EXPORTING
        material              = CONV matnr18( <fs_hd>-matnr )
        valuationarea         = <fs_hd>-bwkey
        valuationtype         = <fs_hd>-bwtar
        posting_date          = VALUE bapi_matval_debi_credi_date( fisc_year   = <fs_hd>-bldat(4)
                                                                   fisc_period = <fs_hd>-bldat+4(2)
                                                                   pstng_date  = <fs_hd>-bldat )
        ref_doc_no            = <fs_bk>-xblnr
      IMPORTING
        debitcreditdocument   = ls_document
      TABLES
        return                = lt_return
        material_debit_credit = lt_mdc.


    "---Trata erro em caso houver
    IF line_exists( lt_return[ type = 'E' ] ).           "#EC CI_STDSEQ

      "---Marca como erro
      me->gv_error = abap_true.

      "---Item
      cs_item-status         = gc_bc_pc_status-itm_nk.

      "---Cabeçalho
      me->gs_data-header-last_changed_by = sy-uname.
      me->gs_data-header-last_changed_at = me->gv_times.

      APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

      "---Erro ao lançar MR22
      <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
      <fs_ret>-number = |011|.
      <fs_ret>-type   = gc_bc_log_type-warng.

      SORT lt_return DESCENDING BY type.

      me->insert_log(
        EXPORTING
          is_item    = cs_item
          it_bapiret = lt_return
      ).

      RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

    ELSE.

      cs_item-status           = gc_bc_pc_status-itm_ok.
      cv_doc_rev               = ls_document-ml_doc_num.
      cv_year_rev              = ls_document-ml_doc_year.

    ENDIF.

  ENDMETHOD.

  METHOD reverse_copa.

    "---Types
    TYPES: BEGIN OF ty_s_doc,
             belnr TYPE belnr_D,
             gjahr TYPE gjahr,
           END OF ty_s_doc,

           ty_t_inputdata TYPE TABLE OF bapi_copa_data WITH DEFAULT KEY,
           ty_t_fieldlist TYPE TABLE OF bapi_copa_field WITH DEFAULT KEY,
           ty_t_return    TYPE TABLE OF bapiret2 WITH DEFAULT KEY.

    "---Tabelas
    DATA: lt_inputdata TYPE ty_t_inputdata,
          lt_fieldlist TYPE ty_t_fieldlist,
          lt_return    TYPE ty_t_return.

    "---Estruturas
    DATA: ls_document TYPE bapi_pricechange_document,
          ls_copa     TYPE ty_s_doc.

    "---Variáveis
    DATA: lv_operatingconcern TYPE bapi0017-op_concern,
          lv_testrun          TYPE bapi0017-testrun,
          lv_program          TYPE char2 VALUE 'BC'. "---Banco de impostos

    "---Field-Symbols
    FIELD-SYMBOLS: <fs_field> LIKE LINE OF lt_fieldlist,
                   <fs_input> LIKE LINE OF lt_inputdata.

    CHECK line_exists( me->gs_data-copa[ guid     = cs_item-guid
                                         guiditem = cs_item-guiditem ] ).

    "---Inserção dos campos e dados CO/PA
    DEFINE insert_data.

      APPEND INITIAL LINE TO lt_fieldlist ASSIGNING <fs_field>.

      APPEND INITIAL LINE TO lt_inputdata ASSIGNING <fs_input>.

      <fs_input>-record_id = &1.
      <fs_field>-fieldname = &2.
      <fs_input>-fieldname = &2.
      <fs_input>-value     = &3.
      <fs_input>-currency  = 'BRL'.

    END-OF-DEFINITION.

    "---Montagem dos dados
    lv_operatingconcern = |AR3C|.

    LOOP AT me->gs_data-copa ASSIGNING FIELD-SYMBOL(<fs_doc_copa>) WHERE guid = cs_item-guid
                                                                     AND guiditem = cs_item-guiditem.

      CHECK <fs_doc_copa>-bln_c_cp IS NOT INITIAL
        AND <fs_doc_copa>-gjr_c_cp IS NOT INITIAL
        AND <fs_doc_copa>-bln_r_cp IS INITIAL
        AND <fs_doc_copa>-gjr_r_cp IS INITIAL.

      "---Marca flag para salvar
      me->gv_save = abap_true.

      "---Busca dados CO/PA
      ASSIGN me->gs_inf_rv_copa-ce1ar3c[ belnr = <fs_doc_copa>-bln_c_cp "#EC CI_STDSEQ
                                         gjahr = <fs_doc_copa>-gjr_c_cp ] TO FIELD-SYMBOL(<fs_copa>).


      IF <fs_copa> IS NOT ASSIGNED.

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        "---Erro ao estornar CO/PA, documento: &1, ano: &2.
        MESSAGE e012(zco_banco_impostos) INTO DATA(lv_message) WITH <fs_doc_copa>-bln_c_cp
                                                                    <fs_doc_copa>-gjr_c_cp.

        "---Dados CO/PA não encontrados com docnumento &1, ano &2.
        MESSAGE e014(zco_banco_impostos) WITH <fs_doc_copa>-bln_c_cp <fs_doc_copa>-gjr_c_cp
                                         INTO DATA(lv_message_error).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-warng
            iv_message = lv_message
        ).

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-error
            iv_message = lv_message_error
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

      ENDIF.

      CLEAR: lt_fieldlist,
             lt_inputdata.

      DATA(lv_count) = 1.

      "---Valores
      DATA(lv_icms)   = <fs_copa>-vv019.
      lv_icms   = lv_icms * -1.
      DATA(lv_icmsst) = <fs_copa>-vv018.
      lv_icmsst = lv_icmsst * -1.
      DATA(lv_ipi)    = <fs_copa>-vv026.
      lv_ipi    = lv_ipi * -1.

      "---FieldList
      insert_data lv_count 'KOKRS'   <fs_copa>-kokrs.
      insert_data lv_count 'VRGAR'   <fs_copa>-vrgar.
      insert_data lv_count 'BUDAT'   <fs_copa>-budat.
      insert_data lv_count 'BUKRS'   <fs_copa>-bukrs.
      insert_data lv_count 'WERKS'   <fs_copa>-werks.
      insert_data lv_count 'GSBER'   <fs_copa>-gsber.

      IF lv_icms IS NOT INITIAL.

        insert_data lv_count 'VV019' lv_icms.

      ENDIF.

      IF lv_icmsst IS NOT INITIAL.

        insert_data lv_count 'VV018' lv_icmsst.

      ENDIF.

      IF lv_ipi IS NOT INITIAL.

        insert_data lv_count 'VV026' lv_ipi.

      ENDIF.

      insert_data lv_count 'ARTNR'     <fs_copa>-artnr.
      insert_data lv_count 'BRSCH'     <fs_copa>-brsch.
      insert_data lv_count 'BZIRK'     <fs_copa>-bzirk.
      insert_data lv_count 'KDGRP'     <fs_copa>-kdgrp.
      insert_data lv_count 'KMKDGR'    <fs_copa>-kmkdgr.
      insert_data lv_count 'KMMAKL'    <fs_copa>-kmmakl.
      insert_data lv_count 'KMVKBU'    <fs_copa>-kmvkbu.
      insert_data lv_count 'KMVKGR'    <fs_copa>-kmvkgr.
      insert_data lv_count 'KMVTNR'    <fs_copa>-kmvtnr.
      insert_data lv_count 'MATKL'     <fs_copa>-matkl.
      insert_data lv_count 'PRODH'     <fs_copa>-prodh.
      insert_data lv_count 'VKBUR'     <fs_copa>-vkbur.
      insert_data lv_count 'VKGRP'     <fs_copa>-vkgrp.
      insert_data lv_count 'WWMT1'     <fs_copa>-wwmt1.
      insert_data lv_count 'WWRPS'     <fs_copa>-wwrps.
      insert_data lv_count 'WWTPC'     <fs_copa>-wwtpc.
      insert_data lv_count 'WWMT2'     <fs_copa>-wwmt2.
      insert_data lv_count 'WWMT3'     <fs_copa>-wwmt3.
      insert_data lv_count 'WWMT4'     <fs_copa>-wwmt4.
      insert_data lv_count 'WWMT5'     <fs_copa>-wwmt5.
      insert_data lv_count 'WWREP'     <fs_copa>-wwrep.
      insert_data lv_count 'KUNRE'     <fs_copa>-kunre.
      insert_data lv_count 'PARTNER'   <fs_copa>-partner.
      insert_data lv_count 'KUNWE'     <fs_copa>-kunwe.
      insert_data lv_count 'WWM10'     <fs_copa>-wwm10.
      insert_data lv_count 'WWM11'     <fs_copa>-wwm11.
      insert_data lv_count 'WWMT9'     <fs_copa>-wwmt9.
      insert_data lv_count 'BWTAR'     <fs_copa>-bwtar.
      insert_data lv_count 'FKART'     <fs_copa>-fkart.
      insert_data lv_count 'VTWEG'     <fs_copa>-vtweg.
      insert_data lv_count 'KAUFN'     <fs_copa>-kaufn.
      insert_data lv_count 'SEGMENT'   <fs_copa>-segment.
      insert_data lv_count 'VKORG'     <fs_copa>-vkorg.

      "---Exporta variável para identificar se será puxado o documento
      EXPORT lv_program = lv_program TO MEMORY ID 'ZBANC_IMP'.

      CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
        EXPORTING
          operatingconcern = lv_operatingconcern
          testrun          = lv_testrun
        TABLES
          inputdata        = lt_inputdata
          fieldlist        = lt_fieldlist
          return           = lt_return.

      "---Trata erro se caso houver
      IF line_exists( lt_return[ type = 'E' ] ).         "#EC CI_STDSEQ

        "---Marca como erro
        me->gv_error = abap_true.

        "---Item
        cs_item-status         = gc_bc_pc_status-itm_nk.

        "---Cabeçalho
        me->gs_data-header-last_changed_by = sy-uname.
        me->gs_data-header-last_changed_at = me->gv_times.

        APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).

        "---Erro ao estornar CO/PA, documento: &1, ano: &2.
        <fs_ret>-id     = |ZCO_BANCO_IMPOSTOS|.
        <fs_ret>-number = |012|.
        <fs_ret>-type   = gc_bc_log_type-warng.
        <fs_ret>-message_v1 = <fs_doc_copa>-bln_c_cp.
        <fs_ret>-message_v2 = <fs_doc_copa>-gjr_c_cp.

        SORT lt_return DESCENDING BY type.

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            it_bapiret = lt_return
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

      ELSE.

        IMPORT ls_copa = ls_copa FROM MEMORY ID 'ZBANC_IMP_COPA'.

        IF sy-subrc IS INITIAL.

          cs_item-status           = gc_bc_pc_status-itm_ok.
          <fs_doc_copa>-bln_r_cp         = ls_copa-belnr.
          <fs_doc_copa>-gjr_r_cp         = ls_copa-gjahr.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD check_process_config.

    IF cs_item-valoricms IS NOT INITIAL.

      ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                         elem_custo = gc_bc_elem_cust-icms1    ] TO FIELD-SYMBOL(<fs_cfg_icms>).

      IF <fs_cfg_icms> IS NOT ASSIGNED.

        ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                           elem_custo = gc_bc_elem_cust-icms2    ] TO <fs_cfg_icms>.

        IF <fs_cfg_icms> IS NOT ASSIGNED.

          ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                           elem_custo = gc_bc_elem_cust-icms2    ] TO <fs_cfg_icms>.

          IF <fs_cfg_icms> IS NOT ASSIGNED.


            "---Marca como erro
            me->gv_error = abap_true.

            CLEAR me->gs_icms.

            "---Marca cabeçalho e item com erro
            me->gs_data-header-status = gc_bc_status-error_pc.
            cs_item-status          = gc_bc_pc_status-itm_nk.

            "---Config. não encontrada para lançamento de &1, códgo cenário &2, Ele.C &3.
            MESSAGE e004(zco_banco_impostos) WITH me->gc_bc_lancs-icms
                                               |{ cs_item-codigocenario }|
                                               |{ gc_bc_elem_cust-icms1 }, { gc_bc_elem_cust-icms2 }, { gc_bc_elem_cust-icms3 }| INTO DATA(lv_message).

            me->insert_log(
              EXPORTING
                is_item    = cs_item
                iv_type    = gc_bc_log_type-error
                iv_message = lv_message
            ).

            RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

          ENDIF.

        ENDIF.

      ENDIF.

      "---Atribui a configuração
      me->gs_icms = <fs_cfg_icms>.

    ELSE.

      CLEAR me->gs_icms.

    ENDIF.

    IF cs_item-valoricmsst IS NOT INITIAL.

      ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                         elem_custo = gc_bc_elem_cust-icmsst1 ] TO FIELD-SYMBOL(<fs_cfg_icmsst>).

      IF <fs_cfg_icmsst> IS NOT ASSIGNED.

        ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                           elem_custo = gc_bc_elem_cust-icmsst2 ] TO <fs_cfg_icmsst>.

        IF <fs_cfg_icmsst> IS NOT ASSIGNED.

          "---Marca como erro
          me->gv_error = abap_true.

          CLEAR me->gs_icmsst.

          "---Marca cabeçalho e item com erro
          me->gs_data-header-status = gc_bc_status-error_pc.
          cs_item-status            = gc_bc_pc_status-itm_nk.

          "---Config. não encontrada para lançamento de &1, códgo cenário &2, Ele.C &3.
          MESSAGE e004(zco_banco_impostos) WITH me->gc_bc_lancs-icmsst
                                             |{ cs_item-codigocenario }|
                                             |{ gc_bc_elem_cust-icmsst1 }, { gc_bc_elem_cust-icmsst2 }| INTO lv_message.

          me->insert_log(
            EXPORTING
              is_item    = cs_item
              iv_type    = gc_bc_log_type-error
              iv_message = lv_message
          ).

          RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

        ENDIF.

      ENDIF.

      "---Atribui configuração
      me->gs_icmsst = <fs_cfg_icmsst>.

    ELSE.

      CLEAR me->gs_icmsst.

    ENDIF.

    IF cs_item-valoripi IS NOT INITIAL.

      ASSIGN me->gt_cfg[ codigo     = cs_item-codigocenario "#EC CI_STDSEQ
                         elem_custo = gc_bc_elem_cust-ipi    ] TO FIELD-SYMBOL(<fs_cfg_ipi>).

      IF <fs_cfg_ipi> IS NOT ASSIGNED.

        "---Marca como erro
        me->gv_error = abap_true.

        CLEAR me->gs_ipi.

        "---Marca cabeçalho e item com erro
        me->gs_data-header-status = gc_bc_status-error_pc.
        cs_item-status          = gc_bc_pc_status-itm_nk.

        "---Config. não encontrada para lançamento de &1, códgo cenário &2, Ele.C &3.
        MESSAGE e004(zco_banco_impostos) WITH me->gc_bc_lancs-ipi
                                           |{ cs_item-codigocenario }|
                                           |{ gc_bc_elem_cust-ipi }| INTO lv_message.

        me->insert_log(
          EXPORTING
            is_item    = cs_item
            iv_type    = gc_bc_log_type-error
            iv_message = lv_message
        ).

        RAISE EXCEPTION TYPE zcx_co_process_banc_imp_upload.

      ENDIF.

      "---Atribui configuração
      me->gs_ipi = <fs_cfg_ipi>.

    ELSE.

      CLEAR me->gs_ipi.

    ENDIF.

  ENDMETHOD.

  METHOD insert_log.

    "---Insere novo log
    IF iv_message IS NOT INITIAL.

      APPEND INITIAL LINE TO me->gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).

      TRY.
          <fs_log>-guid     = is_item-guid.
          <fs_log>-guiditem = is_item-guiditem.
          <fs_log>-guidmsg  = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
        CATCH cx_uuid_error.
      ENDTRY.

      <fs_log>-message    = iv_message.
      <fs_log>-type       = iv_type.
      <fs_log>-created_at = me->gv_times.

    ELSE.

      DATA(lt_bapiret) = it_bapiret.

      SORT lt_bapiret BY id number type.

      DELETE ADJACENT DUPLICATES FROM lt_bapiret COMPARING id number type.

      SORT lt_bapiret DESCENDING BY type.

      LOOP AT lt_bapiret ASSIGNING FIELD-SYMBOL(<fs_ret>).

        APPEND INITIAL LINE TO me->gt_log ASSIGNING <fs_log>.

        TRY.
            <fs_log>-guid     = is_item-guid.
            <fs_log>-guiditem = is_item-guiditem.
            <fs_log>-guidmsg  = NEW cl_system_uuid( )->if_system_uuid~create_uuid_x16( ).
          CATCH cx_uuid_error.
        ENDTRY.

        MESSAGE ID <fs_ret>-id TYPE <fs_ret>-type NUMBER <fs_ret>-number
            WITH <fs_ret>-message_v1 <fs_ret>-message_v2 <fs_ret>-message_v3 <fs_ret>-message_v4
            INTO <fs_log>-message.

        <fs_log>-type       = <fs_ret>-type.
        <fs_log>-created_at = me->gv_times.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD handle_error.

    DATA(lt_return) = io_cx->get_bapi_return( ).

    ASSIGN lt_return[ 1 ] TO FIELD-SYMBOL(<fs_s_return>).

    CHECK sy-subrc = 0.

    MESSAGE ID     <fs_s_return>-id
            TYPE   'S'
            NUMBER <fs_s_return>-number WITH <fs_s_return>-message_v1
                                             <fs_s_return>-message_v2
                                             <fs_s_return>-message_v3
                                             <fs_s_return>-message_v4 DISPLAY LIKE 'E'.

  ENDMETHOD.

ENDCLASS.
