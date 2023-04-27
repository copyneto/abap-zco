class ZCL_ZCO_UPLOAD_DPC_EXT definition
  public
  inheriting from ZCL_ZCO_UPLOAD_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZCO_UPLOAD_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM.

    DATA: lo_message   TYPE REF TO /iwbep/if_message_container,
          lo_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

* ----------------------------------------------------------------------
* Realiza carga do arquivo
* ----------------------------------------------------------------------
    DATA(lr_upload) = NEW zclco_upload( ).

    lr_upload->upload( EXPORTING iv_excel     = abap_true
                                 iv_filename  = iv_slug
                                 is_media     = is_media_resource
                                 iv_entity_set_name = iv_entity_set_name
                       IMPORTING et_return    = DATA(lt_return) ).

* ----------------------------------------------------------------------
* Ativa exceção em casos de erro
* ----------------------------------------------------------------------
    IF lt_return[] IS NOT INITIAL.
      lo_message = mo_context->get_message_container( ).
      lo_message->add_messages_from_bapi( it_bapi_messages = lt_return ).
      CREATE OBJECT lo_exception EXPORTING message_container = lo_message.
      RAISE EXCEPTION lo_exception.
    ELSE.

      TRY.
          DATA(ls_dados) = zclco_upload=>gt_okb9[ 1 ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      copy_data_to_ref( EXPORTING is_data = ls_dados
                         CHANGING cr_data = er_entity ).

    ENDIF.

  endmethod.
ENDCLASS.
