*&---------------------------------------------------------------------*
*& Include ZCOI_OBJETO_RESULTADO
*&---------------------------------------------------------------------*
CONSTANTS: BEGIN OF lc_param,
             modulo TYPE ztca_param_par-modulo VALUE 'CO',
             chave1 TYPE ztca_param_par-chave1 VALUE 'ORDEM_VENDA_DESPESA',
             chave2 TYPE ztca_param_par-chave2 VALUE 'TIPOS_DOC',
           END OF lc_param.

DATA lr_auart TYPE fip_t_auart_range.


DATA(lo_param) = NEW zclca_tabela_parametros( ).
TRY.
    lo_param->m_get_range( EXPORTING iv_modulo = lc_param-modulo
                                     iv_chave1 = lc_param-chave1
                                     iv_chave2 = lc_param-chave2
                           IMPORTING et_range  = lr_auart ).
    IF vbak-auart IN lr_auart AND
       tka00-ergbr CA '4'.
      ch_subrc = 8.
    ENDIF.
  CATCH zcxca_tabela_parametros.
ENDTRY.
