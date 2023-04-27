class ZCL_ZCO_UPLOAD_MPC_EXT definition
  public
  inheriting from ZCL_ZCO_UPLOAD_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZCO_UPLOAD_MPC_EXT IMPLEMENTATION.


  METHOD define.
    super->define( ).

    DATA:
      lo_entity        TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
      lo_property      TYPE REF TO /iwbep/if_mgw_odata_property,
      lo_entity_unmedg TYPE REF TO /iwbep/if_mgw_odata_entity_typ.


    lo_entity = model->get_entity_type( iv_entity_name = 'upload' ).
    lo_entity_unmedg = model->get_entity_type( iv_entity_name = 'uploadUnmedg' ).

    IF lo_entity IS BOUND.
      lo_property = lo_entity->get_property( iv_property_name = 'MimeType' ).
      lo_property->set_as_content_type( ).
    ENDIF.

    IF lo_entity_unmedg IS BOUND.
      lo_property = lo_entity_unmedg->get_property( iv_property_name = 'MimeType' ).
      lo_property->set_as_content_type( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
