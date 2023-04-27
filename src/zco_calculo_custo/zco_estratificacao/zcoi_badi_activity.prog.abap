*&---------------------------------------------------------------------*
*& Include          ZCOI_BADI_ACTIVITY
*&---------------------------------------------------------------------*

  DATA: lv_vp TYPE char2 VALUE 'VP',
        lv_zu TYPE char2 VALUE 'ZU'.

  IF id_categ EQ lv_vp
  OR id_categ EQ lv_zu.
    ed_activity = 2.
  ENDIF.
