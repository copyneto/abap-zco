*&---------------------------------------------------------------------*
*& Include ZCOE_REGRAS_DERIVACAO_COPA
*&---------------------------------------------------------------------*
  CONSTANTS: BEGIN OF lc_param,
               modulo    TYPE ztca_param_par-modulo VALUE 'CO',
               copa      TYPE ztca_param_par-chave1 VALUE 'COPA',
               operation TYPE ztca_param_par-chave1 VALUE 'OPERATION',
               classe    TYPE ztca_param_par-chave2 VALUE 'CL_CARACTERISTICA',
               hier_prod TYPE ztca_param_par-chave2 VALUE 'HP_CARACTERISTICA',
               tp_aval   TYPE ztca_param_par-chave2 VALUE 'TP_AVALIACAO',
             END OF lc_param.

  DATA: lv_oper      TYPE tkeb-erkrs,
        lv_classe    TYPE tkedrs-stepid,
        lv_tp_aval   TYPE tkedrs-stepid,
        lv_hier_prod TYPE tkedrs-stepid,
        ls_ar3c1     TYPE ce0ar3c.


  TRY.
      NEW zclca_tabela_parametros( )->m_get_single( EXPORTING iv_modulo = lc_param-modulo
                                                              iv_chave1 = lc_param-copa
                                                              iv_chave2 = lc_param-operation
                                                    IMPORTING ev_param = lv_oper ).
      IF i_operating_concern EQ lv_oper.

        "Exit para determinar segmentação do centro de lucro pelo material
        TRY.
            NEW zclca_tabela_parametros( )->m_get_single( EXPORTING iv_modulo = lc_param-modulo
                                                                    iv_chave1 = lc_param-copa
                                                                    iv_chave2 = lc_param-classe
                                                          IMPORTING ev_param = lv_classe ).
            IF i_step_id EQ lv_classe.

              e_exit_is_active = abap_true.
              ls_ar3c1 = i_copa_item.

              "Selecionar centro de lucro no mestre de materiais
              SELECT SINGLE prctr
                FROM marc
                INTO @DATA(lv_prctr1)
                 WHERE matnr = @ls_ar3c1-artnr
                   AND werks = @ls_ar3c1-werks.
              IF sy-subrc EQ 0.
                "Atribui família do centro de lucro
                ls_ar3c1-wwmt1 = lv_prctr1(2).
                "Atribui marca do centro de lucro no mestre de materiais
                ls_ar3c1-wwmt5 = lv_prctr1+2(2).
                "Atribui característica 1 do centro de lucro no mestre de materiais
                ls_ar3c1-wwmt2 = lv_prctr1+4(2).
                "Atribui característica 2 do centro de lucro no mestre de materiais
                ls_ar3c1-wwmt3 = lv_prctr1+6(2).
                "Atribui tipo de embalagem do centro de lucro no mestre de materiais
                ls_ar3c1-wwmt4 = lv_prctr1+8(2).
                e_copa_item = ls_ar3c1.
              ENDIF.

            ENDIF.

          CATCH zcxca_tabela_parametros.
        ENDTRY.

        "Exit para determinar hierarquias de produto
        TRY.
            NEW zclca_tabela_parametros( )->m_get_single( EXPORTING iv_modulo = lc_param-modulo
                                                                    iv_chave1 = lc_param-copa
                                                                    iv_chave2 = lc_param-hier_prod
                                                          IMPORTING ev_param = lv_hier_prod ).
            IF i_step_id EQ lv_hier_prod.

              e_exit_is_active = abap_true.
              ls_ar3c1 = i_copa_item.

              "Selecionar hierarquia de produtos no mestre de materiais
              SELECT SINGLE prdha
                FROM mara
                INTO @DATA(lv_prdha)
                 WHERE matnr = @ls_ar3c1-artnr.
              IF sy-subrc EQ 0.
                "Selecionar Familia 1
                ls_ar3c1-wwmt9 = lv_prdha(5).
                "Selecionar Característica
                ls_ar3c1-wwm10 = lv_prdha+5(5).
                "Selecionar Grupo Plano
                ls_ar3c1-wwm11 = lv_prdha+10(8).
                e_copa_item = ls_ar3c1.
              ENDIF.

            ENDIF.

          CATCH zcxca_tabela_parametros.
        ENDTRY.

        "Exit para determinar tipo de avaliação
        TRY.
            NEW zclca_tabela_parametros( )->m_get_single( EXPORTING iv_modulo = lc_param-modulo
                                                                    iv_chave1 = lc_param-copa
                                                                    iv_chave2 = lc_param-tp_aval
                                                          IMPORTING ev_param = lv_tp_aval ).
            IF i_step_id EQ lv_tp_aval.

              e_exit_is_active = abap_true.
              ls_ar3c1 = i_copa_item.

              " Selecionar no item da remessa o tipo de avaliação
              SELECT SINGLE bwtar
                FROM lips
                INTO @DATA(lv_bwtar)
                WHERE werks EQ @ls_ar3c1-werks
                  AND matnr EQ @ls_ar3c1-artnr
                  AND vgbel EQ @ls_ar3c1-kaufn
                  AND vgpos EQ @ls_ar3c1-kdpos
                  AND fkrel EQ 'A'.
              IF sy-subrc EQ 0.
                ls_ar3c1-bwtar = lv_bwtar.
                e_copa_item = ls_ar3c1.
              ENDIF.

            ENDIF.

          CATCH zcxca_tabela_parametros.
        ENDTRY.

      ENDIF.

    CATCH zcxca_tabela_parametros.
  ENDTRY.
