"Name: \PR:SAPFV45P\FO:ERGEBNISOBJEKT_ANLEGEN_PRUEFEN\SE:END\EI
ENHANCEMENT 0 ZEICO_OBJETO_RESULTADO.
CONSTANTS: BEGIN OF lc_param,
             modulo TYPE ztca_param_par-modulo VALUE 'CO',
             chave1 TYPE ztca_param_par-chave1 VALUE 'ORDEM_VENDA_DESPESA',
             chave2 TYPE ztca_param_par-chave2 VALUE 'TIPOS_DOC',
           END OF lc_param.

  DATA lv_auart TYPE char01.


  DATA(lo_param) = NEW zclca_tabela_parametros( ).
  TRY.
      lo_param->m_get_single( EXPORTING iv_modulo = lc_param-modulo
                                        iv_chave1 = lc_param-chave1
                                        iv_chave2 = lc_param-chave2
                              IMPORTING ev_param  = lv_auart ).
      IF vbak-auart(1) EQ lv_auart AND
         tka00-ergbr CA '4'.
        ch_subrc = 8.
      ENDIF.
    CATCH zcxca_tabela_parametros.
  ENDTRY.
ENDENHANCEMENT.
