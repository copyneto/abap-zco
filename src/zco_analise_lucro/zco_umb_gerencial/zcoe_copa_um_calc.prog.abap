*&---------------------------------------------------------------------*
*& Include          ZCOE_COPA_UM_CALC
*&---------------------------------------------------------------------*

CONSTANTS gc_u01 TYPE exit_nr VALUE 'U01'.
CONSTANTS gc_absmg TYPE fieldname VALUE 'ABSMG'.

**********************************************************************

DATA ls_ar3c TYPE ce1ar3c.
DATA ls_ar3c2 TYPE ce1ar3c.

ls_ar3c = ep_source.
ls_ar3c2 = ep_source_bukrs.

IF exit_nr = gc_u01 .

  IF ls_ar3c-absmg_me NE ls_ar3c-kwsvme_me.
    SELECT SINGLE umrez , umren
       FROM marm
       INTO @DATA(ls_marm)
       WHERE matnr = @ls_ar3c-artnr
       AND meinh = @ls_ar3c-absmg_me.
*** Caso encontre a correspondência de unidades de medida *******************************************************************************
    IF sy-subrc = 0.
*** Calcular o valor da quantidade de UM base *******************************************************************************************
      ls_ar3c-kwsvme = ls_ar3c-absmg * ( ls_marm-umrez / ls_marm-umren ).
      ls_ar3c2-kwsvme = ls_ar3c2-absmg * ( ls_marm-umrez / ls_marm-umren ).
*Caso não encontre a correspondência de moedas , emitir mensagem de erro ****************************************************************
    ELSE.
      SELECT COUNT(*) FROM tkeva10
              WHERE erkrs = erkrs
                AND fkart = ls_ar3c-fkart
                AND wertkomp = gc_absmg
                AND wdele = abap_true.
      IF sy-subrc <> 0.
        "Falta fator de conversão da unidade de medida &1 para &2 o material &3.
        MESSAGE e001(zco_copa) WITH ls_ar3c-absmg_me ls_ar3c-kwsvme_me ls_ar3c-artnr .
      ENDIF.
    ENDIF.
  ENDIF.

*****************************************************************************************************************************************
** Verificar se a unidade de medida de medida de vendas é igual a unidade de medida geral
** Se a unidade de medida de medida de vendas é diferente da unidade de medida base, buscar conversão no mestre de materiais e calcular qtde
  IF  ls_ar3c-vv030_me IS NOT INITIAL.
    IF ls_ar3c-absmg_me NE ls_ar3c-vv030_me.
      SELECT SINGLE umrez , umren FROM marm
         INTO @DATA(ls_marm2)
         WHERE matnr = @ls_ar3c-artnr
         AND meinh = @ls_ar3c-vv030_me.
*** Caso encontre a correspondência de unidades de medida *******************************************************************************
      IF sy-subrc = 0.
*** Calcular o valor da quantidade de UM base *******************************************************************************************
        ls_ar3c-vv030 = ls_ar3c-kwsvme * ( ls_marm2-umren / ls_marm2-umrez  ).
        ls_ar3c2-vv030 = ls_ar3c-kwsvme * ( ls_marm2-umren / ls_marm2-umrez  ).
*Caso não encontre a correspondência de moedas , emitir mensagem de erro ****************************************************************
      ELSE.
        SELECT COUNT(*) FROM tkeva10
                WHERE erkrs = erkrs
                  AND fkart = ls_ar3c-fkart
                  AND wertkomp = gc_absmg
                  AND wdele = abap_true.
        IF sy-subrc <> 0.
          MESSAGE e001(zco_copa) WITH ls_ar3c-absmg_me ls_ar3c-vv030_me ls_ar3c-artnr .
        ENDIF.
      ENDIF.
    ELSE.
** Verificar se a unidade de medida de medida de vendas é igual a unidade de medida geral
      ls_ar3c-vv030 = ls_ar3c-absmg.
      ls_ar3c2-vv030 = ls_ar3c2-absmg.
*******************************************************************************************************************************************
    ENDIF.
  ENDIF.

  IF  ls_ar3c-vv031_me IS NOT INITIAL.
    IF ls_ar3c-absmg_me NE ls_ar3c-vv031_me.
      SELECT SINGLE umrez , umren FROM marm
         INTO @DATA(ls_marm3)
         WHERE matnr = @ls_ar3c-artnr
         AND meinh = @ls_ar3c-vv031_me.
*** Caso encontre a correspondência de unidades de medida *******************************************************************************
      IF sy-subrc = 0.
*** Calcular o valor da quantidade de UM base *******************************************************************************************
        ls_ar3c-vv031 = ls_ar3c-kwsvme * ( ls_marm3-umren / ls_marm3-umrez  ).
        ls_ar3c2-vv031 = ls_ar3c-kwsvme * ( ls_marm3-umren / ls_marm3-umrez  ).
*Caso não encontre a correspondência de moedas , emitir mensagem de erro ****************************************************************
      ELSE.
        SELECT COUNT(*) FROM tkeva10
                WHERE erkrs = erkrs
                  AND fkart = ls_ar3c-fkart
                  AND wertkomp = gc_absmg
                  AND wdele = abap_true.
        IF sy-subrc <> 0.
          MESSAGE e001(zco_copa) WITH ls_ar3c-absmg_me ls_ar3c-vv031_me ls_ar3c-artnr .
        ENDIF.
      ENDIF.
    ELSE.
** Verificar se a unidade de medida de medida de vendas é igual a unidade de medida geral
      ls_ar3c-vv031 = ls_ar3c-absmg.
      ls_ar3c2-vv031 = ls_ar3c2-absmg.
*******************************************************************************************************************************************
    ENDIF.
  ENDIF.

  IF  ls_ar3c-vv032_me IS NOT INITIAL.
    IF ls_ar3c-absmg_me NE ls_ar3c-vv032_me.
      SELECT SINGLE umrez , umren FROM marm
         INTO @DATA(ls_marm4)
         WHERE matnr = @ls_ar3c-artnr
         AND meinh = @ls_ar3c-vv032_me.
*** Caso encontre a correspondência de unidades de medida *******************************************************************************
      IF sy-subrc = 0.
*** Calcular o valor da quantidade de UM base *******************************************************************************************
        ls_ar3c-vv032 = ls_ar3c-kwsvme * ( ls_marm4-umren / ls_marm4-umrez  ).
        ls_ar3c2-vv032 = ls_ar3c-kwsvme * ( ls_marm4-umren / ls_marm4-umrez  ).
*Caso não encontre a correspondência de moedas , emitir mensagem de erro ****************************************************************
      ELSE.
        SELECT COUNT(*) FROM tkeva10
                WHERE erkrs = erkrs
                  AND fkart = ls_ar3c-fkart
                  AND wertkomp = gc_absmg
                  AND wdele = abap_true.
        IF sy-subrc <> 0.
          MESSAGE e001(zco_copa) WITH ls_ar3c-absmg_me ls_ar3c-vv032_me ls_ar3c-artnr .
        ENDIF.
      ENDIF.
    ELSE.
** Verificar se a unidade de medida de medida de vendas é igual a unidade de medida geral
      ls_ar3c-vv032 = ls_ar3c-absmg.
      ls_ar3c2-vv032 = ls_ar3c2-absmg.
*******************************************************************************************************************************************
    ENDIF.
  ENDIF.

  ep_target = ls_ar3c .
  ep_target_bukrs = ls_ar3c2 .
  e_bukrs_processed = abap_true.

ENDIF.
