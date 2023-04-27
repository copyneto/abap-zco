function zfmco_pr_mr22_fb50.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_ACTVT) TYPE  CHAR2
*"     VALUE(IV_NF) TYPE  J_1BDOCNUM
*"----------------------------------------------------------------------
  "----Report do processamento
  SUBMIT zcoc_pr_mr22_fb50
   WITH p_moni  = abap_true
   WITH p_actvt = iv_actvt
   WITH p_nf    = iv_nf
   AND RETURN.

ENDFUNCTION.
