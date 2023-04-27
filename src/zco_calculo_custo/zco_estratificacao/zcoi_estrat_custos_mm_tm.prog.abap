*&---------------------------------------------------------------------*
*& Include ZCOI_ESTRAT_CUSTOS_MM_TM
*&---------------------------------------------------------------------*

*** (Tratamento 2) - Entrada por Modulo de MM
** 1ª regra: Alocar o Frete referente à aquisição de insumos e mercadorias no elemento Frete
    IF id_categ EQ lv_zu
    AND is_accit-awtyp EQ lv_rmrp.

      ASSIGN ('(SAPLMRMP)XACCIT[]') TO <fs_accit>.
      IF <fs_accit> IS ASSIGNED.

        lt_accit[] = <fs_accit>.

        READ TABLE lt_accit INTO ls_accit WITH KEY koart = lv_k.
        IF sy-subrc EQ 0.
          lv_lifnr = ls_accit-lifnr.
        ENDIF.

        SELECT SINGLE fdgrv
        FROM lfb1
        INTO lv_fdgrv
        WHERE lifnr EQ lv_lifnr
        AND bukrs EQ is_accit-bukrs.

        IF ( lv_fdgrv EQ lv_a07 OR lv_fdgrv EQ lv_a08 )
          AND ( is_accit-mtart NE lv_hawa
          AND   is_accit-mtart NE lv_fert
          AND   is_accit-mtart NE lv_ztre ).

          CLEAR: es_keph.
          MOVE id_value TO es_keph-kst025.
          es_result = abap_true.

** 2ª regra: Alocar o Frete referente à aquisição de insumos e mercadorias no elemento Frete CD
        ELSEIF  ( lv_fdgrv EQ lv_a07
          OR    lv_fdgrv EQ lv_a08 )
          AND ( is_accit-mtart EQ lv_hawa
          OR    is_accit-mtart EQ lv_fert
          OR    is_accit-mtart EQ lv_ztre ).

          CLEAR: es_keph.
          MOVE id_value TO es_keph-kst033.
          es_result = abap_true.
*        ENDIF.

** Regra 4 Débito Posterior
        ELSEIF  lv_fdgrv EQ lv_a13
          AND ( is_accit-mtart EQ lv_hawa
          OR    is_accit-mtart EQ lv_fert
          OR    is_accit-mtart EQ lv_ztre ).

          CLEAR: es_keph.
          MOVE id_value TO es_keph-kst027.
          es_result = abap_true.

** Regra 5 Lucro entre Coligadas
        ELSEIF  lv_fdgrv EQ lv_a27
          AND ( is_accit-mtart EQ lv_hawa
          OR    is_accit-mtart EQ lv_fert
          OR    is_accit-mtart EQ lv_ztre ).

          CLEAR: es_keph.
          MOVE id_value TO es_keph-kst047.
          es_result = abap_true.
        ENDIF.


      ENDIF.
    ENDIF.

** 3ª regra: Alocar o valor do Frete referente às operações de transferência entre Centros, no elemento Frete CD
    IF  id_categ EQ lv_zu
      AND is_accit-awtyp EQ lv_mkpf
      AND (  is_accit-bwart EQ lv_861
        OR   is_accit-bwart EQ lv_862
        OR   is_accit-bwart EQ lv_863
        OR   is_accit-bwart EQ lv_864 )
      AND ( id_storno EQ lv_no OR id_storno EQ lv_yes ).

      CLEAR: es_keph.
      "CLEAR: lv_kalnr.
      "CLEAR: lv_losgr.
      "CLEAR: lv_knumv.
      "CLEAR: lv_kwert.

      IF id_storno EQ lv_yes.
        lv_negative = 'X'.
      ENDIF.

      SELECT SINGLE kalnr
      FROM ckmlhd
      INTO @DATA(lv_kalnr)
      "INTO @lv_kalnr
      WHERE matnr = @is_accit-matnr
      AND bwkey = @is_accit-umwrk
      AND bwtar = @is_accit-bwtar.

      SELECT SINGLE *
      FROM ckmlprkeph
      INTO @DATA(ls_ckmlprkeph)
      WHERE kalnr EQ @lv_kalnr
      AND bdatj EQ @id_bdatj
      AND poper EQ @id_poper
      AND untper EQ @lv_000
      AND keart  EQ @lv_h
      AND prtyp  EQ @space
*        AND prtyp  EQ 'S'
      AND curtp  EQ @id_curtp.

      SELECT SINGLE losgr
      FROM ckmlprkeko
      INTO @DATA(lv_losgr)
      "INTO @lv_losgr
      WHERE kalnr EQ @lv_kalnr
      AND bdatj EQ @id_bdatj
      AND poper EQ @id_poper
      AND untper EQ @lv_000
      AND prtyp  EQ @lv_s
      AND curtp  EQ @id_curtp.

      MOVE-CORRESPONDING is_keph TO es_keph.

      calc1( EXPORTING
              is_ckmlprkeph = ls_ckmlprkeph
              iv_losgr      = lv_losgr
              iv_menge      = is_accit-menge
              iv_negative   = lv_negative
            CHANGING
              cs_keph       = es_keph ).


      SELECT SINGLE knumv
      FROM ekko
      INTO @DATA(lv_knumv)
      "INTO @lv_knumv
      WHERE ebeln EQ @is_accit-ebeln
      AND bukrs EQ @is_accit-bukrs.

      IF sy-subrc EQ 0.

        SELECT SINGLE kwert
        FROM prcd_elements
        INTO @DATA(lv_kwert)
        "INTO @lv_kwert
        WHERE knumv EQ @lv_knumv
        AND kposn EQ @is_accit-ebelp
        AND kappl EQ @lv_m
        AND kschl EQ @lv_zftf.

        IF sy-subrc EQ 0.
          es_keph-kst033 = lv_kwert.
        ENDIF.

      ENDIF.
      es_result = abap_true.
    ENDIF.
