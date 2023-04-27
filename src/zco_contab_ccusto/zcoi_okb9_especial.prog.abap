*&---------------------------------------------------------------------*
*& Include          ZCOI_OKB9_ESPECIAL
*&---------------------------------------------------------------------*

DATA lv_count TYPE i.
DATA c_numeric TYPE string VALUE ' .,0123456789'.


IF cobl-hkont IS NOT INITIAL.

  IF cobl-kostl IS INITIAL AND
     cobl-bukrs IS NOT INITIAL AND
     cobl-gsber IS NOT INITIAL AND
     cobl-prctr IS NOT INITIAL AND
     cobl-kokrs IS NOT INITIAL.

    SELECT COUNT(*)
    INTO lv_count
    FROM
       cskb
    WHERE
         kokrs EQ cobl-kokrs
    AND  kstar EQ cobl-hkont
    AND  datbi GE cobl-budat
    AND  datab LE cobl-budat.

    IF lv_count GT 0.
      SELECT COUNT(*)
      INTO lv_count
      FROM
         tka3a
      WHERE
          bukrs EQ cobl-bukrs
      AND kstar EQ cobl-hkont
      AND kokrs EQ cobl-kokrs.

      IF lv_count EQ 0.
        SELECT SINGLE
          kostl INTO cobl-kostl
        FROM
          ztco_okb9
        WHERE
            bukrs EQ cobl-bukrs
        AND kstar EQ cobl-hkont
        AND gsber EQ cobl-gsber
        AND prctr EQ cobl-prctr.

        IF sy-subrc EQ 0.
          IF cobl-kostl CN c_numeric.
          ELSE.
            UNPACK cobl-kostl TO cobl-kostl.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDIF.
