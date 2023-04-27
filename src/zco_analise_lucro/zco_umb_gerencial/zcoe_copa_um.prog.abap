*&---------------------------------------------------------------------*
*& Include          ZCOE_COPA_UM
*&---------------------------------------------------------------------*

CONSTANTS: gc_modulo    TYPE ztca_param_par-modulo VALUE 'CO',
           gc_copa      TYPE ztca_param_par-chave1 VALUE 'COPA',
           gc_operation	TYPE ztca_param_par-chave2 VALUE 'OPERATION',
           gc_step_id	  TYPE ztca_param_par-chave2 VALUE 'STEP_ID'.

DATA: ls_ar3c LIKE ce0ar3c .
DATA: lv_prctr LIKE cepc-prctr,
      lv_wwmt1 TYPE ztco_copa_unmedg-wwmt1,
      lv_error TYPE boolean.

DATA: lr_oper    TYPE RANGE OF tkeb-erkrs,
      lr_step_id TYPE RANGE OF tkedrs-stepid.

******************************************************************************
**** Selecionar Parametros
TRY.
    NEW zclca_tabela_parametros( )->m_get_range( EXPORTING iv_modulo = gc_modulo
                                                           iv_chave1 = gc_copa
                                                           iv_chave2 = gc_operation
                                                 IMPORTING et_range  = lr_oper ).
  CATCH zcxca_tabela_parametros INTO DATA(lo_erro).
    lv_error = abap_true.
ENDTRY.


TRY.
    NEW zclca_tabela_parametros( )->m_get_range( EXPORTING iv_modulo = gc_modulo
                                                           iv_chave1 = gc_copa
                                                           iv_chave2 = gc_step_id
                                                 IMPORTING et_range  = lr_step_id ).
  CATCH zcxca_tabela_parametros INTO DATA(lo_erro2).
    lv_error = abap_true.
ENDTRY.

IF lv_error = abap_false.

  IF i_operating_concern IN lr_oper.

    IF i_step_id IN lr_step_id.

      e_exit_is_active = 'X'.
      ls_ar3c = i_copa_item.

******************************************************************************
**** Selecionar centro de lucro no mestre de materiais
      SELECT SINGLE prctr INTO @lv_prctr FROM marc
         WHERE matnr = @ls_ar3c-artnr
           AND werks = @ls_ar3c-werks.
**** Selecionar família do centro de lucro
      lv_wwmt1 = lv_prctr(2).

***** Selecionar unidade de medida geral pela família de produto *************
      SELECT SINGLE * INTO @DATA(ls_copa) FROM ztco_copa_unmedg
              WHERE wwmt1 = @lv_wwmt1.
      IF sy-subrc = 0.
        ls_ar3c-vv030_me = ls_copa-vv030_me.
        ls_ar3c-vv031_me = ls_copa-vv031_me.
        ls_ar3c-vv032_me = ls_copa-vv032_me.
*** Mover para a variável de tela dados selecionados
        e_copa_item = ls_ar3c.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
