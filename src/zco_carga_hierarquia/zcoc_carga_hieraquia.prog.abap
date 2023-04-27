*&---------------------------------------------------------------------*
*& Report ZCOCARGA_HIERAQUIA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcoc_carga_hieraquia.

*======================================================================*
* Types                                                                *
*======================================================================*
TYPE-POOLS: abap, slis.                                     "#EC *

TYPES: BEGIN OF ty_saida,
         line TYPE string.
TYPES: END OF ty_saida.

*======================================================================*
* Tabelas internas                                                     *
*======================================================================*
DATA:
  lt_saida           TYPE TABLE OF ty_saida,
  lt_saida2          TYPE TABLE OF ty_saida,
  lt_fcat_lvc        TYPE slis_t_fieldcat_alv,
  lt_fcat_lvc2       TYPE slis_t_fieldcat_alv,
  ls_fcat_lvc        TYPE slis_fieldcat_alv,                "#EC NEEDED
  lt_table           TYPE REF TO data,
  lt_table2          TYPE REF TO data,
  ls_table           TYPE REF TO data,
  ls_table2          TYPE REF TO data,
  lt_dd03l           TYPE TABLE OF dd03l,
  lt_dd03l2          TYPE TABLE OF dd03l,
  lt_bapi            TYPE TABLE OF bapiset_hier,
  lt_centro          TYPE TABLE OF zsco_cargacc,
  lt_hierarchyvalues TYPE TABLE OF bapi1116_values.



*======================================================================*
* Work Areas                                                           *
*======================================================================*
DATA:
      ls_dd03l TYPE dd03l.

*======================================================================*
* Variáveis                                                            *
*======================================================================*
DATA: lv_tabname TYPE dd02l-tabname,
      lv_arq     TYPE string.                               "#EC NEEDED

FIELD-SYMBOLS:
  <fs_data>    TYPE ANY TABLE,
  <fs_data2>   TYPE ANY TABLE,
  <fs_wadata>  TYPE any,
  <fs_wadata2> TYPE any,
  <fs_field>   TYPE any.
*======================================================================*
* Classes                                                              *
*======================================================================*

*======================================================================*
* Tela de execução                                                     *
*======================================================================*
SELECTION-SCREEN BEGIN OF BLOCK b001  WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_table  TYPE dd02l-tabname DEFAULT 'BAPISET_HIER' NO-DISPLAY,
              p_table2 TYPE dd02l-tabname DEFAULT 'ZEE_CARGACC' NO-DISPLAY,

              p_arq    TYPE rlgrap-filename DEFAULT 'c:\' OBLIGATORY,
              p_arq2   TYPE rlgrap-filename DEFAULT 'c:\' OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b001.

*======================================================================*
* AT SELECTION-SCREEN                                                  *
*======================================================================*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arq.

  lv_arq = p_table.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = sy-repid
      dynpro_number = sy-dynnr
      field_name    = p_arq
      static        = ' '
      mask          = '*.csv'
    CHANGING
      file_name     = p_arq
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
*    MESSAGE e001(00) WITH 'Arquivo não encontrado'.
    MESSAGE TEXT-e01 TYPE 'E'.
  ENDIF.


*======================================================================*
* AT SELECTION-SCREEN                                                  *
*======================================================================*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arq2.

  lv_arq = p_table.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = sy-repid
      dynpro_number = sy-dynnr
      field_name    = p_arq2
      static        = ' '
      mask          = '*.csv'
    CHANGING
      file_name     = p_arq2
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
*    MESSAGE e001(00) WITH 'Arquivo não encontrado'.
    MESSAGE TEXT-e01 TYPE 'E'.

  ENDIF.

*======================================================================*
* START-OF-SELECTION                                                   *
*======================================================================*
START-OF-SELECTION.

* Monta estrutura de tabela.
  PERFORM f_monta_tabela.

  PERFORM f_monta_tabela2.

* Busca registros da tabela dinâmica.
  PERFORM f_busca_dados.

* Busca registros da tabela dinâmica.
  PERFORM f_busca_dados2.

* lê o arquivo para upload
  PERFORM f_leitura_local.

* lê o arquivo para upload
  PERFORM f_leitura_local2.

* Grava dados
  PERFORM f_grava_dados.

* Grava dados
  PERFORM f_grava_dados2.

  PERFORM f_monta_centros.

  PERFORM f_chama_bapi.

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TABELA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM f_monta_tabela .
  lv_tabname = p_table.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = lv_tabname
    CHANGING
      ct_fieldcat            = lt_fcat_lvc[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.                           "#EC *


  IF lt_fcat_lvc[] IS INITIAL.
    MESSAGE TEXT-002 TYPE 'E'.
  ELSE.
    CREATE DATA lt_table  TYPE TABLE OF (p_table).
    ASSIGN lt_table->*  TO <fs_data>.

    CREATE DATA ls_table LIKE LINE OF <fs_data>.
    ASSIGN ls_table->* TO <fs_wadata>.
  ENDIF.

ENDFORM.                    " F_MONTA_TABELA

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TABELA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM f_monta_tabela2 .
  lv_tabname = p_table2.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = lv_tabname
    CHANGING
      ct_fieldcat            = lt_fcat_lvc2[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.                           "#EC *


  IF lt_fcat_lvc[] IS INITIAL.
    MESSAGE TEXT-002 TYPE 'E'.
  ELSE.
    CREATE DATA lt_table2  TYPE TABLE OF (p_table2).
    ASSIGN lt_table2->*  TO <fs_data2>.

    CREATE DATA ls_table2 LIKE LINE OF <fs_data2>.
    ASSIGN ls_table2->* TO <fs_wadata2>.
  ENDIF.

ENDFORM.                    " F_MONTA_TABELA

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_busca_dados .

*Busca informações da tabela dinâmica.
  SELECT * FROM dd03l INTO TABLE lt_dd03l
               WHERE tabname   = p_table
                 AND comptype  = 'S'
                 AND fieldname = 'MANDT'.
  IF sy-subrc EQ 0 .
*    DELETE lt_dd03l WHERE comptype = 'S'.
*    DELETE lt_dd03l WHERE fieldname = 'MANDT'.
    SORT lt_dd03l BY position ASCENDING.
  ENDIF.

ENDFORM.                    " F_BUSCA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_busca_dados2 .

*Busca informações da tabela dinâmica.
  SELECT * FROM dd03l INTO TABLE lt_dd03l2
               WHERE tabname   = p_table2
                 AND comptype  = 'S'
                 AND fieldname = 'MANDT'.
  IF sy-subrc EQ 0 .
*    DELETE lt_dd03l2 WHERE comptype = 'S'.
*    DELETE lt_dd03l2 WHERE fieldname = 'MANDT'.
    SORT lt_dd03l2 BY position ASCENDING.
  ENDIF.

ENDFORM.                    " F_BUSCA_DADOS

*&---------------------------------------------------------------------*
*&      Form F_LEITURA_LOCAL
*&---------------------------------------------------------------------*
*       Ler arquivo com diretório local (PC)
*----------------------------------------------------------------------*
FORM f_leitura_local .
  DATA lv_arq TYPE string.

  MOVE p_arq TO lv_arq.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_arq
      filetype                = 'ASC'
      codepage                = ' '
    TABLES
      data_tab                = lt_saida
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

* Verifica retorno da função
  IF NOT sy-subrc IS INITIAL.
*    MESSAGE e001(00) WITH p_arq space.
    MESSAGE p_arq TYPE 'E'.
    "Erro na abertura do arquivo &1 - &2
  ENDIF.

* Verifica arquivo vazio.
  IF lt_saida IS INITIAL.
*    MESSAGE e001(00) WITH 'Arquivo não existe' .
    MESSAGE TEXT-e01 TYPE 'E'.

  ENDIF.
ENDFORM.                    " F_LEITURA_LOCAL

*&---------------------------------------------------------------------*
*&      Form F_LEITURA_LOCAL
*&---------------------------------------------------------------------*
*       Ler arquivo com diretório local (PC)
*----------------------------------------------------------------------*
FORM f_leitura_local2 .
  DATA lv_arq TYPE string.

  MOVE p_arq2 TO lv_arq.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_arq
      filetype                = 'ASC'
      codepage                = ' '
    TABLES
      data_tab                = lt_saida2
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

* Verifica retorno da função
  IF NOT sy-subrc IS INITIAL.
*    MESSAGE e001(00) WITH p_arq space.
    MESSAGE p_arq TYPE 'E'.
    "Erro na abertura do arquivo &1 - &2
  ENDIF.

* Verifica arquivo vazio.
  IF lt_saida IS INITIAL.
*    MESSAGE e001(00) WITH 'Arquivo não existe'.
    MESSAGE TEXT-e01 TYPE 'E'.

  ENDIF.
ENDFORM.                    " F_LEITURA_LOCAL

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_grava_dados .
  DATA: ls_saida    TYPE ty_saida,
        lv_primeira TYPE i,
        lv_aux      TYPE string.

  REFRESH <fs_data>.

  IF NOT lt_saida IS INITIAL.


*    LOOP AT lt_saida INTO ls_saida.
    LOOP AT lt_saida ASSIGNING FIELD-SYMBOL(<fs_saida>).

      MOVE <fs_saida>-line TO lv_aux.

*      LOOP AT lt_dd03l INTO ls_dd03l.
      LOOP AT lt_dd03l ASSIGNING FIELD-SYMBOL(<fs_dd03l>).

        ASSIGN COMPONENT <fs_dd03l>-fieldname
            OF STRUCTURE <fs_wadata> TO <fs_field>.

        FIND FIRST OCCURRENCE OF ';' IN lv_aux MATCH OFFSET  lv_primeira.
        IF sy-subrc = 0.
          MOVE lv_aux(lv_primeira) TO <fs_field>.

          lv_primeira = lv_primeira + 1.
          lv_aux = lv_aux+lv_primeira.
        ELSE.

          MOVE lv_aux TO <fs_field>.
        ENDIF.


      ENDLOOP.
      IF <fs_wadata>  IS NOT INITIAL.
        INSERT  <fs_wadata> INTO TABLE <fs_data>.
      ENDIF.

    ENDLOOP.

*    INSERT (p_table) FROM TABLE  <fs_data>.
*    INSERT (p_table) FROM TABLE  <fs_data>.

    lt_bapi = <fs_data>.

  ENDIF.
ENDFORM.                    " F_GRAVA_DADOS


*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_grava_dados2 .
  DATA: ls_saida    TYPE ty_saida,
        lv_primeira TYPE i,
        lv_aux      TYPE string.

  REFRESH <fs_data2>.
*  unassign: <fs_wadata>,  <fs_field>.

  IF NOT lt_saida2 IS INITIAL.


*    LOOP AT lt_saida2 INTO ls_saida.
    LOOP AT lt_saida2 ASSIGNING FIELD-SYMBOL(<fs_saida>).

      MOVE <fs_saida>-line TO lv_aux.

*      LOOP AT lt_dd03l2 INTO ls_dd03l.
      LOOP AT lt_dd03l2 ASSIGNING FIELD-SYMBOL(<fs_dd03l>).

        ASSIGN COMPONENT <fs_dd03l>-fieldname
            OF STRUCTURE <fs_wadata2> TO <fs_field>.

        FIND FIRST OCCURRENCE OF ';' IN lv_aux MATCH OFFSET  lv_primeira.
        IF sy-subrc = 0.
          MOVE lv_aux(lv_primeira) TO <fs_field>.

          lv_primeira = lv_primeira + 1.
          lv_aux = lv_aux+lv_primeira.
        ELSE.

          MOVE lv_aux TO <fs_field>.
        ENDIF.


      ENDLOOP.
      IF <fs_wadata2>  IS NOT INITIAL.
        INSERT  <fs_wadata2> INTO TABLE <fs_data2>.
      ENDIF.

    ENDLOOP.

    lt_centro = <fs_data2>.

  ENDIF.
ENDFORM.                    " F_GRAVA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_CHAMA_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chama_bapi .

  DATA lt_return TYPE bapiret2.


*  CALL FUNCTION 'BAPI_PROFITCENTERGRP_CREATE'
*    EXPORTING
*      controllingareaimp = 'VS00'
**     TOPNODEONLY        = ' '
**     LANGUAGE           =
*    IMPORTING
**     CONTROLLINGAREA    =
**     GROUPNAME          =
*      return             = lt_return
*    TABLES
*      hierarchynodes     = lt_bapi
*      hierarchyvalues    = lt_hierarchyvalues.

  CALL FUNCTION 'BAPI_COSTCENTERGROUP_CREATE'
    EXPORTING
      controllingareaimp = 'VS00'
*     TOPNODEONLY        = ' '
*     LANGUAGE           =
    IMPORTING
*     CONTROLLINGAREA    =
*     GROUPNAME          =
      return             = lt_return
    TABLES
      hierarchynodes     = lt_bapi
      hierarchyvalues    = lt_hierarchyvalues.

*  BREAK-POINT.
*
*  BREAK-POINT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_CENTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_centros .

  DATA:
    lv_cont  TYPE i,
    lv_tabix TYPE sy-tabix,
    ls_hie   TYPE bapi1116_values.


  SORT lt_centro BY groupname.
  LOOP AT lt_bapi ASSIGNING FIELD-SYMBOL(<fs_bapi>).
    lv_cont  = 0.

    READ TABLE lt_centro TRANSPORTING NO FIELDS WITH KEY groupname = <fs_bapi>-groupname BINARY SEARCH.
    IF sy-subrc = 0.
      lv_tabix = sy-tabix.
*      LOOP AT lt_centro INTO DATA(ls_centro) FROM lv_tabix.
      LOOP AT lt_centro ASSIGNING FIELD-SYMBOL(<fs_centro>) FROM lv_tabix.
        IF <fs_centro>-groupname <> <fs_bapi>-groupname.
          EXIT.
        ELSE.
          lv_cont  = lv_cont  + 1.

          MOVE <fs_centro>-valfrom TO ls_hie-valfrom.
          MOVE <fs_centro>-valfrom TO ls_hie-valto  .
          APPEND ls_hie TO lt_hierarchyvalues.


        ENDIF.
      ENDLOOP.

    ENDIF.
    <fs_bapi>-valcount = lv_cont.

  ENDLOOP.

ENDFORM.



*001  Unload extração de dados de tabelas
*002  Tabela não existe no SAP
*003  Não existem dados na tabela para a geração de arquivo
*004  Arquivo gerado com sucesso
*005  Erro ao gerar arquivo
*E01  Arquivo não encontrado
*E02  Tabela selecionada não pertence ao modulo ppr
