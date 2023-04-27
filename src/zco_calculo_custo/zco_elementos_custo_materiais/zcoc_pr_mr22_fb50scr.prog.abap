*&---------------------------------------------------------------------*
*& Include zcoc_pr_mr22_fb50scr
*&---------------------------------------------------------------------*

SELECTION-SCREEN: BEGIN OF BLOCK b1.

  "----Parâmetros para execução periódica
  SELECT-OPTIONS: s_compc FOR j_1bnfdoc-bukrs,
                  s_month FOR marv-lfmon.

  PARAMETERS: p_year  TYPE gjahr.

  "----Parâmetros para execução por monitor
  PARAMETERS: p_moni  TYPE abap_bool NO-DISPLAY,
              p_actvt TYPE char2     NO-DISPLAY,
              p_nf    TYPE zi_co_pr_mr22_fb50-NFDocument NO-DISPLAY.

SELECTION-SCREEN: END OF BLOCK b1.
