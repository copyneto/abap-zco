class ZCLCO_UPLOAD definition
  public
  final
  create public .

public section.

  types TY_OKB9 type ZTCO_OKB9 .
  types TY_UNMD type ZTCO_COPA_UNMEDG .
  types:
    ty_t_okb9 TYPE TABLE OF ztco_okb9 .
  types:
    ty_t_unmd TYPE TABLE OF ztco_copa_unmedg .
  types:
    BEGIN OF ty_file_okb9,
        bukrs TYPE bukrs,
        kstar TYPE kstar,
        gsber TYPE gsber,
        prctr TYPE prctr,
        kostl TYPE kostl,
      END OF ty_file_okb9 .
  types:
    BEGIN OF ty_file_unmd,
        wwmt1    TYPE ztco_copa_unmedg-wwmt1,
        vv030_me TYPE ztco_copa_unmedg-vv030_me,
        vv031_me TYPE ztco_copa_unmedg-vv031_me,
        vv032_me TYPE ztco_copa_unmedg-vv032_me,
      END OF ty_file_unmd .
  types:
    ty_t_file_okb9 TYPE STANDARD TABLE OF ty_file_okb9 .
  types:
    ty_t_file_unmd TYPE STANDARD TABLE OF ty_file_unmd .

  class-data GT_OKB9 type TY_T_OKB9 .
  class-data GV_ENTITY_SET_NAME type STRING .
  class-data GT_UNMD type TY_T_UNMD .

    "! Realiza carga de arquivo
    "! @parameter iv_filename | Nome do arquivo
    "! @parameter is_media | Arquivo enviado
    "! @parameter et_return | Mensagens de retorno
  methods UPLOAD
    importing
      !IV_EXCEL type FLAG optional
      !IV_FILENAME type STRING
      !IS_MEDIA type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MEDIA_RESOURCE
      !IV_ENTITY_SET_NAME type STRING
    exporting
      !ET_RETURN type BAPIRET2_T .
  methods UPLOAD_CREATE
    importing
      !IT_FILE type ANY TABLE
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Salva registro
    "! @parameter et_return | Mensagens de retorno
  methods UPLOAD_SAVE
    exporting
      !ET_RETURN type BAPIRET2_T .
  methods PROCESS_FILE
    importing
      !IV_EXCEL type FLAG optional
      !IT_FILE type ANY TABLE
    exporting
      !ET_RETURN type BAPIRET2_T .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCLCO_UPLOAD IMPLEMENTATION.


  METHOD PROCESS_FILE.

* ---------------------------------------------------------------------------
* Valida dados do arquivo de carga
* ---------------------------------------------------------------------------
*    me->validate_data( EXPORTING it_file   = it_file[]
*                       IMPORTING et_return = DATA(lt_return) ).

*    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
*    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Monta dados
* ---------------------------------------------------------------------------
    me->upload_create(  EXPORTING it_file     = it_file[]
                        IMPORTING et_return   = data(lt_return) ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Salva registros
* ---------------------------------------------------------------------------
    me->upload_save( IMPORTING et_return = lt_return[] ).

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

  ENDMETHOD.


  METHOD upload.

    DATA: lt_file_okb9 TYPE zclco_upload=>ty_t_file_okb9,
          lt_file_unmd TYPE zclco_upload=>ty_t_file_unmd,
          lv_mimetype  TYPE w3conttype.

    FREE: et_return.

    " Nome do EntitySet na variável global
    gv_entity_set_name = iv_entity_set_name.

* ---------------------------------------------------------------------------
* Valida tipo de arquivo
* ---------------------------------------------------------------------------
    CALL FUNCTION 'SDOK_MIMETYPE_GET'
      EXPORTING
        extension = 'XLSX'
      IMPORTING
        mimetype  = lv_mimetype.

    IF is_media-mime_type NE lv_mimetype.
      " Formato de arquivo não suportado. Realizar nova carga com formato "xlsx".
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZCO_OKB9' number = '008' ) ).
    ENDIF.

* ---------------------------------------------------------------------------
* Converte arquivo excel para tabela
* ---------------------------------------------------------------------------
    DATA(lo_excel) = NEW zclca_excel( iv_filename = iv_filename
                                      iv_file     = is_media-value ).

    CASE gv_entity_set_name .

      WHEN 'uploadSet'.

        lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return)
                             CHANGING  ct_table  = lt_file_okb9 ).

        et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
        CHECK NOT line_exists( et_return[ type = 'E' ] ). "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Processa dados do arquivo
* ---------------------------------------------------------------------------
        me->process_file( EXPORTING iv_excel  = iv_excel
                                    it_file   = lt_file_okb9[]
                          IMPORTING et_return = lt_return[] ).

      WHEN 'uploadSetUnmedg'.

        lo_excel->get_sheet( IMPORTING et_return = DATA(lt_return2)
                             CHANGING  ct_table  = lt_file_unmd ).

        et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return2 ( ls_return ) ).
        CHECK NOT line_exists( et_return[ type = 'E' ] ). "#EC CI_STDSEQ

* ---------------------------------------------------------------------------
* Processa dados do arquivo
* ---------------------------------------------------------------------------
        me->process_file( EXPORTING iv_excel  = iv_excel
                                    it_file   = lt_file_unmd[]
                          IMPORTING et_return = lt_return[] ).


    ENDCASE.

    et_return[] = VALUE #( BASE et_return FOR ls_return IN lt_return ( ls_return ) ).
    CHECK NOT line_exists( et_return[ type = 'E' ] ).    "#EC CI_STDSEQ

  ENDMETHOD.


  METHOD upload_create.

    DATA: ls_dados      TYPE ty_okb9,
          lt_okb9       TYPE ty_t_okb9,
          lt_file_okb9  TYPE ty_t_file_okb9,

          ls_dados_unmd TYPE ty_unmd,
          lt_unmd       TYPE ty_t_unmd,
          lt_file_unmd  TYPE ty_t_file_unmd.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Monta dados da planilha - para EntitySet especifica
* ---------------------------------------------------------------------------
    CASE gv_entity_set_name .

      WHEN 'uploadSet'.

        lt_file_okb9 = it_file.

        LOOP AT lt_file_okb9 REFERENCE INTO DATA(lr_file_okb9).
          CHECK lr_file_okb9->bukrs IS NOT INITIAL.

          CLEAR ls_dados.
          ls_dados-client     = sy-mandt.
          ls_dados-bukrs      = lr_file_okb9->bukrs.
          ls_dados-kstar      = lr_file_okb9->kstar.
          ls_dados-gsber      = lr_file_okb9->gsber.
          ls_dados-prctr      = lr_file_okb9->prctr.
          ls_dados-kostl      = lr_file_okb9->kostl.
          ls_dados-created_by = sy-uname.
          GET TIME STAMP FIELD ls_dados-created_at.
          ls_dados-last_changed_by = ls_dados-created_by.
          ls_dados-last_changed_at = ls_dados-created_at.
          ls_dados-local_last_changed_at = ls_dados-last_changed_at.

          APPEND ls_dados TO lt_okb9.

        ENDLOOP.

        me->gt_okb9 = lt_okb9[].


      WHEN 'uploadSetUnmedg'.

        lt_file_unmd = it_file.

        LOOP AT lt_file_unmd REFERENCE INTO DATA(lr_file_unmd).
          CHECK lr_file_unmd->wwmt1 IS NOT INITIAL.

          CLEAR ls_dados_unmd.

          ls_dados_unmd-client    = sy-mandt.
          ls_dados_unmd-wwmt1    = lr_file_unmd->wwmt1.
          ls_dados_unmd-vv030_me = lr_file_unmd->vv030_me.
          ls_dados_unmd-vv031_me = lr_file_unmd->vv031_me.
          ls_dados_unmd-vv032_me = lr_file_unmd->vv032_me.

          "Log
          ls_dados_unmd-created_by = sy-uname.
          GET TIME STAMP FIELD ls_dados_unmd-created_at.
          ls_dados_unmd-last_changed_by       = ls_dados_unmd-created_by.
          ls_dados_unmd-last_changed_at       = ls_dados_unmd-created_at.
          ls_dados_unmd-local_last_changed_at = ls_dados_unmd-last_changed_at.

          APPEND ls_dados_unmd TO lt_unmd.

        ENDLOOP.

        me->gt_unmd = lt_unmd[].

    ENDCASE.

  ENDMETHOD.


  METHOD upload_save.

    FREE: et_return.

* ---------------------------------------------------------------------------
* Qual EntitySet ?
* ---------------------------------------------------------------------------
    CASE gv_entity_set_name .

      WHEN 'uploadSet'.

        IF me->gt_okb9 IS NOT INITIAL.
*          DATA ls_sy     TYPE syst.
*          DATA(lv_value) = me->gt_okb9[ 1 ]-bukrs.
*          CALL FUNCTION 'DDUT_INPUT_CHECK'
*            EXPORTING
*              tabname       = 'ZTCO_OKB9_POC'
*              fieldname     = 'BUKRS'
*              value         = lv_value
*            IMPORTING
*              msgid         = ls_sy-msgid
*              msgty         = ls_sy-msgty
*              msgno         = ls_sy-msgno
*              msgv1         = ls_sy-msgv1
*              msgv2         = ls_sy-msgv2
*              msgv3         = ls_sy-msgv3
*              msgv4         = ls_sy-msgv4
*            EXCEPTIONS
*              no_ddic_field = 1
*              illegal_move  = 2
*              OTHERS        = 3.
*          IF sy-subrc eq 0.
*            et_return[] = VALUE #( BASE et_return ( type = ls_sy-msgty id = ls_sy-msgid number = ls_sy-msgno
*                                                    message_v1 = ls_sy-msgv1
*                                                    message_v2 = ls_sy-msgv2
*                                                    message_v3 = ls_sy-msgv3
*                                                    message_v4 = ls_sy-msgv4 ) ).
*            RETURN.
*          ENDIF.
          MODIFY ztco_okb9 FROM TABLE  me->gt_okb9.
          IF sy-subrc ne 0.
            " Falha ao salvar dados de carga.
            et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZCO_OKB9' number = '014' ) ).
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'uploadSetUnmedg' .

        IF me->gt_unmd IS NOT INITIAL.
          MODIFY ztco_copa_unmedg FROM TABLE me->gt_unmd.
          IF sy-subrc NE 0.
            " Falha ao salvar dados de carga.
            et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZCO_COPA' number = '002' ) ).
            RETURN.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
