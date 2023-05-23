*&---------------------------------------------------------------------*
*& Include ZCOI_ESTRAT_CUSTOS_RE
*&---------------------------------------------------------------------*

*** (Tratamento 3) - Extratificação com Base Ultimo Custo Real da Origem
    lv_ultimo = is_accit-budat.
    "primeiro dia da data de lançamento
    lv_ultimo+6(2) = '01'.
    "último dia do mês anterior da data de lançamento
    lv_ultimo = lv_ultimo - 1.
    lv_primeiro = lv_ultimo.
    "primeiro dia do mês anterior
    lv_primeiro+6(2) = '01'.

** 1ª regra: Estratificação do custo real da origem
    IF  id_categ EQ lv_zu
      AND is_accit-awtyp EQ lv_mkpf
      AND (  is_accit-bwart EQ lv_101
        OR   is_accit-bwart EQ lv_102
        OR   is_accit-bwart EQ lv_122
        OR   is_accit-bwart EQ lv_123 )
      AND is_accit-lifnr IS NOT INITIAL.

      CLEAR: lv_kalnr.
      CLEAR: ls_ckmlprkeph.
      CLEAR: lv_losgr.
      CLEAR: lv_knumv.

      IF id_storno EQ lv_yes.
        lv_negative = 'X'.
      ENDIF.

      SELECT SINGLE partner
      FROM but000
      INTO @DATA(lv_partner)
      WHERE partner EQ @is_accit-lifnr
      AND bpkind EQ @lv_0002
      AND bu_group EQ @lv_apju.

      IF sy-subrc EQ 0.

        SELECT low
        INTO TABLE @DATA(lt_param)
        FROM ztca_param_val
        WHERE modulo = @lv_co
        AND chave1 = @lv_chave1
        AND chave2 = @lv_chave2.

        IF sy-subrc = 0 AND lt_param[] IS NOT INITIAL.
          LOOP AT lt_param INTO DATA(ls_param).
            CLEAR: ls_param_data_map.
            SPLIT ls_param-low AT '-' INTO: ls_param_data_map-partner ls_param_data_map-bukrs ls_param_data_map-werks.
            INSERT ls_param_data_map INTO TABLE lt_param_data.
          ENDLOOP.

          READ TABLE lt_param_data[] WITH TABLE KEY partner = lv_partner INTO DATA(ls_param_data).

        ENDIF.

        CHECK ls_param_data IS NOT INITIAL.

        lv_bukrs = ls_param_data-bukrs.
        lv_werks = ls_param_data-werks.

        "Se a empresa produtora for a mesma  empresa fornecedora
        IF lv_bukrs EQ is_accit-bwtar(4).
          CONCATENATE is_accit-bwtar(8) 'IN' INTO lv_bwtar.
        ELSE.
          CONCATENATE is_accit-bwtar(8) 'EX' INTO lv_bwtar.
        ENDIF.

        "Selecionar número do cálculo de custos do material no outro centro
        SELECT SINGLE kalnr
        FROM ckmlhd
        "INTO @DATA(lv_kalnr)
        INTO @lv_kalnr
        WHERE bwkey = @lv_werks
        AND matnr = @is_accit-matnr
        AND bwtar = @lv_bwtar.

        "Verificar se o período é janeiro (001)
        IF id_poper = '001'.

          DATA(lv_bdatj) = id_bdatj - 1.

          "Buscar custo médio do mês anterior para o mês 12 do ano anterior no centro de origem
          SELECT SINGLE *
          FROM ckmlprkeph
          INTO @ls_ckmlprkeph
          WHERE kalnr = @lv_kalnr
          AND bdatj = @lv_bdatj
          AND poper = @lv_012
          AND untper = @lv_000
          AND keart = @lv_h
          AND prtyp = @lv_v
          AND kkzst = @space
          AND curtp = @id_curtp.

          SELECT SINGLE losgr
          FROM ckmlprkeko
          INTO @lv_losgr
          WHERE kalnr = @lv_kalnr
          AND bdatj = @lv_bdatj
          AND poper = @lv_012
          AND untper = @lv_000
          AND prtyp = @lv_v
          AND curtp = @id_curtp.

        ELSE.
          "Caso o período não seja janeiro (001) / O período é o mês anterior do mesmo ano
          DATA(lv_poper) = id_poper - 1.

          "Buscar custo médio do mês anterior do mesmo ano no centro de origem
          SELECT SINGLE * FROM ckmlprkeph
          INTO @ls_ckmlprkeph
          WHERE kalnr = @lv_kalnr
          AND bdatj = @id_bdatj
          AND poper = @lv_poper
          AND untper = @lv_000
          AND keart = @lv_h
          AND prtyp = @lv_v
          AND kkzst = @space
          AND curtp = @id_curtp.

        ENDIF.

        "Buscar tamanho do lote do cálculo de custos
        SELECT SINGLE losgr
        FROM ckmlprkeko
        INTO @lv_losgr
        WHERE kalnr = @lv_kalnr
        AND bdatj = @id_bdatj
        AND poper = @lv_poper
        AND untper = @lv_000
        AND prtyp = @lv_v
        AND curtp = @id_curtp.

        "Calcular total do médio do mês anterior do centro de origem
        lv_total = calc_tot( EXPORTING
                              is_ckmlprkeph = ls_ckmlprkeph
                              iv_losgr      = lv_losgr
                              iv_menge      = is_accit-menge
                              iv_negative   = lv_negative ).

        "Verificar se houve movimentação do material antes do mês anterior
*        SELECT SINGLE a~awref
*        INTO @DATA(lv_mblnr)
*        FROM ( mlhd AS a INNER JOIN mlit AS b ON a~belnr = b~belnr AND a~kjahr = b~kjahr  )
*        WHERE b~matnr = @is_accit-matnr
*        AND b~bwkey = @lv_werks
*        AND b~bwtar = @lv_bwtar
*        AND a~cpudt < @lv_primeiro.

        SELECT SINGLE materialdocument
        INTO @DATA(lv_mblnr)
        FROM i_materialdocumentitem
        WHERE material = @is_accit-matnr
        AND plant = @lv_werks
        AND inventoryvaluationtype = @lv_bwtar
        AND postingdate  < @lv_primeiro.

        "Verificar se houve movimentação do material no mês anterior
*        SELECT SINGLE a~awref
*        INTO @DATA(lv_mblnr1)
*        FROM ( mlhd AS a INNER JOIN mlit AS b ON a~belnr = b~belnr AND a~kjahr = b~kjahr  )
*        WHERE b~matnr = @is_accit-matnr
*        AND b~bwkey = @lv_werks
*        AND b~bwtar = @lv_bwtar
*        AND  ( a~cpudt >= @lv_primeiro AND a~cpudt <= @lv_ultimo ).

        SELECT SINGLE materialdocument
        INTO @DATA(lv_mblnr1)
        FROM i_materialdocumentitem
        WHERE material = @is_accit-matnr
        AND plant = @lv_werks
        AND inventoryvaluationtype = @lv_bwtar
        AND ( postingdate >= @lv_primeiro AND postingdate <= @lv_ultimo ).

        "Buscar status do fechamento no mês anterior.
*        SELECT SINGLE status
*        INTO @DATA(lv_status)
*        FROM ckmlpp
*        WHERE kalnr = @lv_kalnr
*        AND bdatj = @lv_ultimo(4)
*        AND poper = @lv_ultimo+4(2)
*        AND untper = @lv_000.
        CONCATENATE  lv_ultimo(4) '0' lv_ultimo+4(2) INTO DATA(lv_jahrper).

        SELECT SINGLE xclose
        INTO @DATA(lv_xclose)
        FROM mlrunlist
        WHERE kalnr = @lv_kalnr
        AND jahrper = @lv_jahrper.

        "Se houve movimentação antes do mês anterior ao anterior   e o médio não é ZERO ou teve movimentação no mês anterior e o lançamento de encerramento foi efetuado (Campo XCLOSE = X), usar o médio
*        IF ( lv_mblnr IS NOT INITIAL AND lv_total <> 0 ) OR ( lv_mblnr1 IS NOT INITIAL AND lv_total <> 0 AND lv_status = lv_70 ).
*        IF ( lv_mblnr IS NOT INITIAL AND lv_total <> 0 ) OR ( lv_mblnr1 IS NOT INITIAL AND lv_total <> 0 AND lv_xclose = lv_x ).
        IF ( lv_mblnr IS NOT INITIAL AND lv_total <> 0 AND lv_xclose = lv_x ) OR ( lv_mblnr1 IS NOT INITIAL AND lv_total <> 0 AND lv_xclose = lv_x ).

          CLEAR: lv_knumv.
          CLEAR: lv_kwert.

          "Selecionar no pedido o valor do IPI
          SELECT SINGLE knumv
          FROM ekko
          "INTO @DATA(lv_knumv)
          INTO @lv_knumv
          WHERE ebeln = @is_accit-ebeln
          AND bukrs = @is_accit-bukrs.

*          SELECT SINGLE kwert
*          FROM konv
*          INTO @lv_kwert
*          WHERE knumv = @lv_knumv
*          AND kposn = @is_accit-ebelp
*          AND kappl = @lv_m
*          AND kschl = @lv_zipi.

          SELECT SINGLE kwert
          FROM prcd_elements
          "INTO @DATA(lv_kwert)
          INTO @lv_kwert
          WHERE knumv EQ @lv_knumv
          AND kposn EQ @is_accit-ebelp
          AND kappl EQ @lv_m
          AND kschl EQ @lv_zipi.

          IF sy-subrc EQ 0.

            SELECT SINGLE mwskz, menge
            FROM ekpo INTO ( @lv_mwskz, @lv_menge )
            WHERE ebeln = @is_accit-ebeln
            AND ebelp = @is_accit-ebelp.

            IF sy-subrc EQ 0.
              IF lv_menge NE is_accit-menge AND lv_menge > 0.
                lv_kwert = lv_kwert / lv_menge.
                lv_kwert = lv_kwert * is_accit-erfmg.
              ENDIF.

              SELECT SINGLE mwskz
              FROM a003
              "INTO @DATA(lv_mwskz)
              INTO @lv_mwskz
              WHERE kappl = @lv_kappl
              AND kschl = @lv_ipi1
              AND aland = @lv_br
              AND mwskz = @lv_mwskz.

              IF sy-subrc EQ 0.
                CLEAR lv_kwert.
              ENDIF.
            ENDIF.
          ENDIF.

          "Se a condição de IPI não for ZERO, verificar a moeda
          IF lv_kwert <> 0.

            "Se for a moeda da empresa, calcular os elementos, ZERAR os elementos de ST e transferir para ST Origem e IPI
            IF ( id_curtp = 10 OR
                 id_curtp = 30 OR
                 id_curtp = 31 ) .

              MOVE-CORRESPONDING is_keph TO es_keph.

              calc2( EXPORTING
                      is_ckmlprkeph = ls_ckmlprkeph
                      iv_losgr      = lv_losgr
                      iv_menge      = is_accit-menge
                      iv_kwert      = lv_kwert
                      iv_value      = id_value
                      iv_total      = lv_total
                      iv_negative   = lv_negative
                    CHANGING
                      cs_keph       = es_keph ).

              es_result = 'X'.
              IF id_curtp = 10.
                lv_value = id_value.
*              EXPORT v_value FROM lv_value TO MEMORY ID 'VALORBRL'.
                EXPORT lv_value FROM lv_value TO MEMORY ID 'VALORBRL'.
                else.
                IMPORT lv_value TO lv_value1 FROM MEMORY ID 'VALORBRL'.

                EXPORT lv_value1 FROM lv_value1 TO MEMORY ID 'VALORBRL'.

              ENDIF.

            ELSE.

              "Se a moeda não for a da empresa, calcular os elementos por conversão, ZERAR os elementos de ST e transferir para ST Origem
              IMPORT lv_value1 TO lv_value1 FROM MEMORY ID 'VALORBRL'.
              IF lv_value1 IS NOT INITIAL.
                lv_conver = ( id_value / lv_value1 ).
              ENDIF.

              MOVE-CORRESPONDING is_keph TO es_keph.

              calc3( EXPORTING
                      is_ckmlprkeph = ls_ckmlprkeph
                      iv_losgr      = lv_losgr
                      iv_menge      = is_accit-menge
                      iv_kwert      = lv_kwert
                      iv_value      = id_value
                      iv_total      = lv_total
                      iv_conver     = lv_conver
                      iv_negative   = lv_negative
                    CHANGING
                      cs_keph       = es_keph ).

              es_result = 'X'.

            ENDIF.

          ELSE.

            "Se a condição de IPI for ZERO, calcular valor dos elementos
            MOVE-CORRESPONDING is_keph TO es_keph.

            calc4( EXPORTING
                    is_ckmlprkeph = ls_ckmlprkeph
                    iv_losgr      = lv_losgr
                    iv_menge      = is_accit-menge
                    iv_value      = id_value
                    iv_total      = lv_total
                    iv_negative   = lv_negative
                  CHANGING
                    cs_keph       = es_keph ).

            es_result = 'X'.


          ENDIF.

        ELSE.
          "Caso o material não tenha sido movimentado ou tenha sido movimentado no mês anterior mas o lançamento de encerramento ainda não tenha sido efetuado.
          CLEAR lv_total.
          CLEAR : lv_losgr.
          CLEAR: ls_ckmlprkeph.
          CLEAR: lv_knumv.
          CLEAR: lv_kwert.
          CLEAR: lv_mwskz.
          CLEAR: lv_menge.

          "Buscar custo standard do mês do próprio material
          SELECT SINGLE *
          FROM ckmlprkeph
          INTO @ls_ckmlprkeph
          WHERE kalnr = @id_kalnr
          AND bdatj = @id_bdatj
          AND poper = @id_poper
          AND untper = @lv_000
          AND keart = @lv_h
          AND prtyp = @lv_s
          AND kkzst = @space
          AND curtp = @id_curtp.

          "Buscar tamanho do lote do cálculo de custo
          SELECT SINGLE losgr
          FROM ckmlprkeko
          INTO @lv_losgr
          WHERE kalnr = @id_kalnr
          AND bdatj = @id_bdatj
          AND poper = @id_poper
          AND untper = @lv_000
          AND prtyp = @lv_s
          AND curtp = @id_curtp.

          "Calcular o total do custo a ser considerado
          lv_total = calc_tot( EXPORTING
                                is_ckmlprkeph = ls_ckmlprkeph
                                iv_losgr      = lv_losgr
                                iv_menge      = is_accit-menge
                                iv_negative   = lv_negative ).

          "Selecionar no pedido o valor do IPI
          SELECT SINGLE knumv
          FROM ekko
          INTO @lv_knumv
          WHERE ebeln = @is_accit-ebeln
          AND bukrs = @is_accit-bukrs.

          SELECT SINGLE kwert
          FROM prcd_elements
          "INTO @DATA(lv_kwert)
          INTO @lv_kwert
          WHERE knumv EQ @lv_knumv
          AND kposn EQ @is_accit-ebelp
          AND kappl EQ @lv_m
          AND kschl EQ @lv_zipi.

          IF sy-subrc EQ 0.

            SELECT SINGLE mwskz
            FROM ekpo INTO @lv_mwskz
            WHERE ebeln = @is_accit-ebeln
            AND ebelp = @is_accit-ebelp.

            IF sy-subrc EQ 0.

*              IF lv_menge NE is_accit-menge AND lv_menge > 0.
*                lv_kwert = lv_kwert / lv_menge.
*                lv_kwert = lv_kwert * is_accit-erfmg.
*              ENDIF.

              SELECT SINGLE mwskz
              FROM a003
              INTO @lv_mwskz
              WHERE kappl = @lv_kappl
              AND kschl = @lv_ipi1
              AND aland = @lv_br
              AND mwskz = @lv_mwskz.

              IF sy-subrc EQ 0.
                CLEAR lv_kwert.
              ENDIF.
            ENDIF.
          ENDIF.

          "Se o IPI for diferente de ZERO
          IF lv_kwert <> 0.

            IF ( id_curtp = 10 OR
                 id_curtp = 30 OR
                 id_curtp = 31 ) .

              MOVE-CORRESPONDING is_keph TO es_keph.

              calc2( EXPORTING
                      is_ckmlprkeph = ls_ckmlprkeph
                      iv_losgr      = lv_losgr
                      iv_menge      = is_accit-menge
                      iv_kwert      = lv_kwert
                      iv_value      = id_value
                      iv_total      = lv_total
                      iv_negative   = lv_negative
                    CHANGING
                      cs_keph       = es_keph ).

              es_result = 'X'.
              lv_value = id_value.
              EXPORT v_value FROM lv_value TO MEMORY ID 'VALORBRL'.
            ELSE.

              "Se a moeda não for a moeda da empresa, calcular o fator de conversão e determinar os elementos
              IMPORT lv_value TO lv_value1 FROM MEMORY ID 'VALORBRL'.
              IF lv_value1 IS NOT INITIAL.
                lv_conver = ( id_value / lv_value1 ).
              ENDIF.

              MOVE-CORRESPONDING is_keph TO es_keph.

              calc3( EXPORTING
                      is_ckmlprkeph = ls_ckmlprkeph
                      iv_losgr      = lv_losgr
                      iv_menge      = is_accit-menge
                      iv_kwert      = lv_kwert
                      iv_value      = id_value
                      iv_total      = lv_total
                      iv_conver     = lv_conver
                      iv_negative   = lv_negative
                    CHANGING
                      cs_keph       = es_keph ).

              es_result = 'X'.

            ENDIF.
          ELSE.
            "Se a condição do IPI for ZERO
            MOVE-CORRESPONDING is_keph TO es_keph.
            "Se a condição de IPI for ZERO, calcular valor dos elementos
            calc4( EXPORTING
                    is_ckmlprkeph = ls_ckmlprkeph
                    iv_losgr      = lv_losgr
                    iv_menge      = is_accit-menge
                    iv_value      = id_value
                    iv_total      = lv_total
                    iv_negative   = lv_negative
                  CHANGING
                    cs_keph       = es_keph ).

            es_result = 'X'.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.
