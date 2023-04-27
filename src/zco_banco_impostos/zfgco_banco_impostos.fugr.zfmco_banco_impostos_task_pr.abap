FUNCTION zfmco_banco_impostos_task_pr.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_QNAME) TYPE  TRFCQOUT-QNAME
*"     VALUE(IV_SHEET_GUID) TYPE  SYSUUID_X16 OPTIONAL
*"     VALUE(IV_REVERSE) TYPE  FLAG OPTIONAL
*"     VALUE(IS_DATA) TYPE  ZSCO_BANCO_IMPOSTOS_DATA OPTIONAL
*"----------------------------------------------------------------------
  "----Cria Fila do processo
  CALL FUNCTION 'TRFC_SET_QUEUE_NAME'
    EXPORTING
      qname = iv_qname.

  "---Processando os dados
  CALL FUNCTION 'ZFMCO_BANCO_IMPOSTOS'
    IN BACKGROUND TASK
    EXPORTING
      iv_sheet_guid = iv_sheet_guid
      iv_reverse    = iv_reverse
      is_data       = is_data.

  COMMIT WORK.

ENDFUNCTION.
