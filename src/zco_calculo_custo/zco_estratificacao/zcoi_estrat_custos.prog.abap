*&---------------------------------------------------------------------*
*& Include          ZCOI_ESTRAT_CUSTOS
*&---------------------------------------------------------------------*

    DATA: lv_vp       TYPE char2 VALUE 'VP',
          lv_zu       TYPE char2 VALUE 'ZU',
          lv_rmrp     TYPE awtyp VALUE 'RMRP',
          lv_wbrk     TYPE awtyp VALUE 'WBRK',
          lv_mkpf     TYPE awtyp VALUE 'MKPF',
          lv_101      TYPE bwart VALUE '101',
          lv_102      TYPE bwart VALUE '102',
          lv_122      TYPE bwart VALUE '122',
          lv_123      TYPE bwart VALUE '123',
          lv_861      TYPE bwart VALUE '861',
          lv_862      TYPE bwart VALUE '862',
          lv_863      TYPE bwart VALUE '863',
          lv_864      TYPE bwart VALUE '864',
          lv_prchg    TYPE awtyp VALUE 'PRCHG',
          lv_blart    TYPE blart VALUE 'PR',
          lv_elem11   TYPE accit-xblnr VALUE 'ELEM11',
          lv_elem13   TYPE accit-xblnr VALUE 'ELEM13',
          lv_elem14   TYPE accit-xblnr VALUE 'ELEM14',
          lv_elem15   TYPE accit-xblnr VALUE 'ELEM15',
          lv_elem16   TYPE accit-xblnr VALUE 'ELEM16',
          lv_elem17   TYPE accit-xblnr VALUE 'ELEM17',
          lv_elem18   TYPE accit-xblnr VALUE 'ELEM18',
          lv_elem19   TYPE accit-xblnr VALUE 'ELEM19',
          lv_elem20   TYPE accit-xblnr VALUE 'ELEM20',
          lv_elem21   TYPE accit-xblnr VALUE 'ELEM21',
          lv_elem22   TYPE accit-xblnr VALUE 'ELEM22',
          lv_elem23   TYPE accit-xblnr VALUE 'ELEM23',
          lv_elem24   TYPE accit-xblnr VALUE 'ELEM24',
          lv_elem25   TYPE accit-xblnr VALUE 'ELEM25',
          lv_a07      TYPE char3 VALUE 'A07',
          lv_a08      TYPE char3 VALUE 'A08',
          lv_a27      TYPE char3 VALUE 'A27',
          lv_a13      TYPE char3 VALUE 'A13',
          lv_no       TYPE char2 VALUE 'NO',
          lv_yes      TYPE char3 VALUE 'YES',
          lv_000      TYPE char3 VALUE '000',
          lv_s        TYPE c     VALUE 'S',
          lv_h        TYPE c     VALUE 'H',
          lv_k        TYPE c     VALUE 'K',
          lv_v        TYPE c     VALUE 'V',
          lv_hawa     TYPE mara-mtart  VALUE 'HAWA',
          lv_fert     TYPE mara-mtart  VALUE 'FERT',
          lv_ztre     TYPE mara-mtart  VALUE 'ZTRE',
          lv_fdgrv    TYPE lfb1-fdgrv,
          lv_lifnr    TYPE lfa1-lifnr,
          lv_m        TYPE c           VALUE 'M',
          lv_kappl    TYPE a003-kappl  VALUE 'TX',
          lv_zipi     TYPE konv-kschl  VALUE 'ZIPI',
          lv_zftf     TYPE konv-kschl  VALUE 'ZFTF',
          lv_ipi1     TYPE a003-kschl  VALUE 'IPI1',
          lv_br       TYPE a003-aland  VALUE 'BR',
          lv_0002     TYPE but000-bpkind    VALUE '0002',
          lv_apju     TYPE but000-bu_group  VALUE 'APJU',
          lv_co       TYPE char2  VALUE 'CO',
          lv_chave1   TYPE char12  VALUE 'ESTRATCUSTOS',
          lv_chave2   TYPE char20  VALUE 'PARC.-EMPRESA-CENTRO',
          lv_012      TYPE ckmlprkeph-poper  VALUE '012',
          lv_70       TYPE ckmlpp-status  VALUE 70,
          lv_x        TYPE ml4h_xclose  VALUE 'X',
          lv_negative TYPE char1,
          lv_mwskz    TYPE ekpo-mwskz.

    DATA: lt_accit TYPE STANDARD TABLE OF accit,
          ls_accit TYPE accit.

    DATA: lv_bwtar    TYPE ckmlhd-bwtar,
          lv_total    TYPE ckmlkeph-kst001,
          lv_ultimo   TYPE d,
          lv_primeiro TYPE d,
          lv_menge    TYPE ekpo-menge,
          lv_value    TYPE ckmlkeph-kst001,
          lv_value1   TYPE ckmlkeph-kst001,
          lv_conver   TYPE accit-kursk.

    DATA: lt_param_data     TYPE TABLE OF ty_split WITH KEY partner,
          ls_param_data_map TYPE ty_split.

    DATA: lv_bukrs TYPE bukrs,
          lv_werks TYPE werks_d.

    FIELD-SYMBOLS: <fs_accit> TYPE STANDARD TABLE.

    TRANSLATE is_accit-xblnr TO UPPER CASE.

*** (Tratamento 1) - lançamento manual MR22
*** 1º regra: ICMS ST
    IF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem14.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst027.
      es_result = abap_true.
*** 2ª regra: ESTORNO DE CRÉDITO
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem15.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst029.
      es_result = abap_true.
*** 3ª regra: RESSARCIMENTO ICMS ST
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem16.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst031.
      es_result = abap_true.
*** 4ª regra: FRETE CD
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem17.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst033.
      es_result = abap_true.
*** 5ª regra: ROYALTES
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem18.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst035.
      es_result = abap_true.
*** 6ª regra: LUCRO ENTRE COLIGADAS TEMPORÁRIOS
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem24.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst047.
      es_result = abap_true.
*** 7ª regra: CREDITO PIS COFINS
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem20.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst039.
      es_result = abap_true.
*** 8ª regra: IPI COLIGADAS
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem21.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst041.
      es_result = abap_true.
*** 9ª regra: INCENTIVO FISCAL UM
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem22.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst043.
      es_result = abap_true.
*** 10ª regra: INCENTIVO FISCAL DOIS
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem23.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst045.
      es_result = abap_true.
*** 11ª regra: Outros Custos
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem25.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst049.
      es_result = abap_true.
*** 12ª regra: ICMS ST ORIGEM
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem11.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst021.
      es_result = abap_true.
*** 13ª regra: FRETE
    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND is_accit-xblnr EQ lv_elem13.

      CLEAR: es_keph.
      MOVE id_value TO es_keph-kst025.
      es_result = abap_true.

    ELSEIF  id_categ EQ lv_vp
    AND is_accit-awtyp EQ lv_prchg
    AND is_accit-blart EQ lv_blart
    AND ( is_accit-xblnr NE lv_elem11
    AND   is_accit-xblnr NE lv_elem13
    AND   is_accit-xblnr NE lv_elem14
    AND   is_accit-xblnr NE lv_elem15
    AND   is_accit-xblnr NE lv_elem16
    AND   is_accit-xblnr NE lv_elem17
    AND   is_accit-xblnr NE lv_elem18
    "AND   is_accit-xblnr NE lv_elem19
    AND   is_accit-xblnr NE lv_elem20
    AND   is_accit-xblnr NE lv_elem21
    AND   is_accit-xblnr NE lv_elem22
    AND   is_accit-xblnr NE lv_elem23
    AND   is_accit-xblnr NE lv_elem24
    AND   is_accit-xblnr NE lv_elem25 ).

      EXIT.

    ENDIF.

*DMANTEIGA-Início - comentado
*    SELECT SINGLE kalnr
*             FROM ckmlhd
*             INTO @DATA(lv_kalnr)
*                  WHERE matnr EQ @is_accit-matnr
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
**                    AND bwkey EQ @is_accit-umwrk
*                    AND bwkey EQ @is_accit-bwkey
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*                    AND bwtar EQ @is_accit-bwtar.
*
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
*    SELECT SINGLE kst041
*      FROM ckmlprkeph
*      INTO @DATA(lv_ckmlprkeph_kst041)
*           WHERE kalnr EQ @lv_kalnr
*             AND bdatj EQ @id_bdatj
*             AND poper EQ @id_poper
*             AND untper EQ @lv_000
*             AND keart  EQ @lv_h
**             AND prtyp  EQ @space
*             AND prtyp  EQ 'S'
*             AND curtp  EQ @id_curtp.
**    SELECT SINGLE *
**      FROM ckmlprkeph
**      INTO @DATA(ls_ckmlprkeph)
**           WHERE kalnr EQ @lv_kalnr
**             AND bdatj EQ @id_bdatj
**             AND poper EQ @id_poper
**             AND untper EQ @lv_000
**             AND keart  EQ @lv_h
**             AND prtyp  EQ 'S'
**             AND curtp  EQ @id_curtp.
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*
*    SELECT SINGLE losgr
*             FROM ckmlprkeko
*             INTO @DATA(lv_losgr)
*            WHERE kalnr EQ @lv_kalnr
*              AND bdatj EQ @id_bdatj
*                   AND poper EQ @id_poper
*                   AND untper EQ @lv_000
*                   AND prtyp  EQ @lv_s
*                   AND curtp  EQ @id_curtp.
*
****    12º regra
*    SELECT SINGLE knumv
*      FROM ekko
*      INTO @DATA(lv_knumv)
*           WHERE ebeln EQ @is_accit-ebeln
*             AND bukrs EQ @is_accit-bukrs.
*
*    IF sy-subrc EQ 0.
*
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
**      SELECT SINGLE kwert
**               FROM konv
**               INTO @DATA(lv_kwert)
**              WHERE knumv EQ @lv_knumv
**                AND kposn EQ @is_accit-ebelp
**                AND kappl EQ @lv_m
**                AND kschl EQ @lv_zipi.
*      SELECT SINGLE kwert
*               FROM prcd_elements
*               INTO @DATA(lv_kwert)
*              WHERE knumv EQ @lv_knumv
*                AND kposn EQ @is_accit-ebelp
*                AND kappl EQ @lv_m
*                AND kschl EQ @lv_zipi.
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*
*      IF sy-subrc EQ 0.
*
*        SELECT SINGLE mwskz
*                 FROM ekpo
*                 INTO @DATA(lv_mwskz)
*                WHERE ebeln EQ @is_accit-ebeln
*                  AND ebelp EQ @is_accit-ebelp.
*
*        IF sy-subrc EQ 0.
*
*          SELECT SINGLE mwskz
*                   FROM a003
*                   INTO @DATA(lv_mwskz2)
*                  WHERE kappl EQ @lv_kappl
*                    AND kschl EQ @lv_ipi1
*                    AND aland EQ @lv_br
*                    AND mwskz EQ @lv_mwskz.
*
*          IF sy-subrc EQ 0.
*            CLEAR: lv_kwert.
*          ENDIF.
*        ENDIF.
*
*        IF lv_kwert NE 0.
*
*          IF id_curtp EQ 10
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
**          OR id_curtp EQ 30
*          OR id_curtp EQ 31
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*          OR id_curtp EQ 40.
*            MOVE-CORRESPONDING is_keph TO es_keph.
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
****            es_keph-kst001 = ( ls_ckmlprkeph-kst001 / lv_losgr ) * is_accit-menge.
****            es_keph-kst002 = ( ls_ckmlprkeph-kst002 / lv_losgr ) * is_accit-menge.
****            es_keph-kst003 = ( ls_ckmlprkeph-kst003 / lv_losgr ) * is_accit-menge.
****            es_keph-kst004 = ( ls_ckmlprkeph-kst004 / lv_losgr ) * is_accit-menge.
****            es_keph-kst005 = ( ls_ckmlprkeph-kst005 / lv_losgr ) * is_accit-menge.
****            es_keph-kst006 = ( ls_ckmlprkeph-kst006 / lv_losgr ) * is_accit-menge.
****            es_keph-kst007 = ( ls_ckmlprkeph-kst007 / lv_losgr ) * is_accit-menge.
****            es_keph-kst008 = ( ls_ckmlprkeph-kst008 / lv_losgr ) * is_accit-menge.
****            es_keph-kst009 = ( ls_ckmlprkeph-kst009 / lv_losgr ) * is_accit-menge.
****            es_keph-kst010 = ( ls_ckmlprkeph-kst010 / lv_losgr ) * is_accit-menge.
****            es_keph-kst011 = ( ls_ckmlprkeph-kst011 / lv_losgr ) * is_accit-menge.
****            es_keph-kst012 = ( ls_ckmlprkeph-kst012 / lv_losgr ) * is_accit-menge.
****            es_keph-kst013 = ( ls_ckmlprkeph-kst013 / lv_losgr ) * is_accit-menge.
****            es_keph-kst014 = ( ls_ckmlprkeph-kst014 / lv_losgr ) * is_accit-menge.
****            es_keph-kst015 = ( ls_ckmlprkeph-kst015 / lv_losgr ) * is_accit-menge.
****            es_keph-kst016 = ( ls_ckmlprkeph-kst016 / lv_losgr ) * is_accit-menge.
****            es_keph-kst017 = ( ls_ckmlprkeph-kst017 / lv_losgr ) * is_accit-menge.
****            es_keph-kst018 = ( ls_ckmlprkeph-kst019 / lv_losgr ) * is_accit-menge.
****            es_keph-kst020 = ( ls_ckmlprkeph-kst020 / lv_losgr ) * is_accit-menge.
****            es_keph-kst021 = ( ls_ckmlprkeph-kst021 / lv_losgr ) * is_accit-menge.
****            es_keph-kst022 = ( ls_ckmlprkeph-kst022 / lv_losgr ) * is_accit-menge.
****            es_keph-kst023 = ( ls_ckmlprkeph-kst023 / lv_losgr ) * is_accit-menge.
****            es_keph-kst024 = ( ls_ckmlprkeph-kst024 / lv_losgr ) * is_accit-menge.
****            es_keph-kst025 = ( ls_ckmlprkeph-kst025 / lv_losgr ) * is_accit-menge.
****            es_keph-kst026 = ( ls_ckmlprkeph-kst026 / lv_losgr ) * is_accit-menge.
****            es_keph-kst027 = ( ls_ckmlprkeph-kst027 / lv_losgr ) * is_accit-menge.
****            es_keph-kst028 = ( ls_ckmlprkeph-kst028 / lv_losgr ) * is_accit-menge.
****            es_keph-kst029 = ( ls_ckmlprkeph-kst029 / lv_losgr ) * is_accit-menge.
****            es_keph-kst030 = ( ls_ckmlprkeph-kst030 / lv_losgr ) * is_accit-menge.
****            es_keph-kst031 = ( ls_ckmlprkeph-kst031 / lv_losgr ) * is_accit-menge.
****            es_keph-kst032 = ( ls_ckmlprkeph-kst032 / lv_losgr ) * is_accit-menge.
****            es_keph-kst033 = ( ls_ckmlprkeph-kst033 / lv_losgr ) * is_accit-menge.
****            es_keph-kst034 = ( ls_ckmlprkeph-kst034 / lv_losgr ) * is_accit-menge.
****            es_keph-kst035 = ( ls_ckmlprkeph-kst035 / lv_losgr ) * is_accit-menge.
****            es_keph-kst036 = ( ls_ckmlprkeph-kst036 / lv_losgr ) * is_accit-menge.
****            es_keph-kst037 = ( ls_ckmlprkeph-kst037 / lv_losgr ) * is_accit-menge.
****            es_keph-kst038 = ( ls_ckmlprkeph-kst038 / lv_losgr ) * is_accit-menge.
****            es_keph-kst039 = ( ls_ckmlprkeph-kst039 / lv_losgr ) * is_accit-menge.
****            es_keph-kst040 = ( ls_ckmlprkeph-kst040 / lv_losgr ) * is_accit-menge.
*            es_keph-kst041 = ( lv_ckmlprkeph_kst041 / lv_losgr ) * is_accit-menge + lv_kwert.
*****            es_keph-kst041 = ( ls_ckmlprkeph-kst041 / lv_losgr ) * is_accit-menge + lv_kwert.
****            es_keph-kst042 = ( ls_ckmlprkeph-kst042 / lv_losgr ) * is_accit-menge.
****            es_keph-kst043 = ( ls_ckmlprkeph-kst043 / lv_losgr ) * is_accit-menge.
****            es_keph-kst044 = ( ls_ckmlprkeph-kst044 / lv_losgr ) * is_accit-menge.
****            es_keph-kst045 = ( ls_ckmlprkeph-kst045 / lv_losgr ) * is_accit-menge.
****            es_keph-kst046 = ( ls_ckmlprkeph-kst046 / lv_losgr ) * is_accit-menge.
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*            es_result = abap_true.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
**** 13ª regra
*    IF  id_categ EQ lv_zu
*    AND is_accit-awtyp EQ lv_mkpf
*    AND ( is_accit-bwart EQ lv_861
*     OR   is_accit-bwart EQ lv_862
*     OR   is_accit-bwart EQ lv_863
*     OR   is_accit-bwart EQ lv_864 ).
*
*      CLEAR: es_keph.
*
** LSCHEPP - Ajuste estratificação - 07.07.2022 Início
**      SELECT SINGLE kwert
**               FROM konv
**               INTO @DATA(lv_kwert2)
**              WHERE knumv EQ @lv_knumv
**                AND kposn EQ @is_accit-ebelp
**                AND kappl EQ @lv_m
**                AND kschl EQ @lv_zftf.
*      SELECT SINGLE kwert
*               FROM prcd_elements
*               INTO @DATA(lv_kwert2)
*              WHERE knumv EQ @lv_knumv
*                AND kposn EQ @is_accit-ebelp
*                AND kappl EQ @lv_m
*                AND kschl EQ @lv_zftf.
** LSCHEPP - Ajuste estratificação - 07.07.2022 Fim
*
*      IF sy-subrc EQ 0.
*        es_keph-kst023 = lv_kwert2.
*      ENDIF.
*
*      es_result = abap_true.
*    ENDIF.

*** 15ª regra - Frete de Compra - TM

    IF id_categ EQ lv_zu AND
       is_accit-awtyp EQ lv_wbrk.

      SELECT SINGLE lifnr
        FROM ekko
        INTO @lv_lifnr
        WHERE ebeln = @is_accit-ebeln.
      IF sy-subrc EQ 0.

        SELECT SINGLE fdgrv
          FROM lfb1
          INTO @lv_fdgrv
          WHERE lifnr EQ @lv_lifnr
            AND bukrs EQ @is_accit-bukrs.
        IF sy-subrc EQ 0.

          IF lv_fdgrv EQ lv_a08 AND
             ( is_accit-mtart NE lv_hawa AND
               is_accit-mtart NE lv_fert AND
               is_accit-mtart NE lv_ztre ).
            CLEAR: es_keph.
            MOVE id_value TO es_keph-kst025.
            es_result = abap_true.
          ELSEIF lv_fdgrv EQ lv_a08 AND
           ( is_accit-mtart EQ lv_hawa OR
             is_accit-mtart EQ lv_fert OR
             is_accit-mtart EQ lv_ztre ).
            CLEAR: es_keph.
            MOVE id_value TO es_keph-kst033.
            es_result = abap_true.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.
* DMANTEIGA-FIM - comentado
