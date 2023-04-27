FUNCTION zfgco_pr_task_pr.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_QNAME) TYPE  TRFCQOUT-QNAME
*"     VALUE(IV_ACTVT) TYPE  CHAR2
*"     VALUE(IV_NF) TYPE  J_1BDOCNUM
*"----------------------------------------------------------------------
  "----Cria Fila do processo
  CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
    EXPORTING
      qname = iv_qname.

  "---Executar Report de processamento
  CALL FUNCTION 'ZFMCO_PR_MR22_FB50' IN BACKGROUND TASK
    EXPORTING
      iv_actvt = iv_actvt
      iv_nf    = iv_nf.

  COMMIT WORK.

ENDFUNCTION.
