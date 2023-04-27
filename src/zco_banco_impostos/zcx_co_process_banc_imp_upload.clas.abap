CLASS zcx_co_process_banc_imp_upload DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF gc_standard,
        msgid TYPE symsgid VALUE 'ZCO_BANCO_IMPOSTOS',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE 'GV_MSGV3',
        attr4 TYPE scx_attrname VALUE 'GV_MSGV4',
      END OF gc_standard .

    CONSTANTS:
      BEGIN OF gc_bc_blocked,
        msgid TYPE symsgid VALUE 'ZCO_BANCO_IMPOSTOS',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_bc_blocked .

    CONSTANTS:
      BEGIN OF gc_not_found,
        msgid TYPE symsgid VALUE 'ZCO_BANCO_IMPOSTOS',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_not_found .

    CONSTANTS:
      BEGIN OF gc_configs_not_found,
        msgid TYPE symsgid VALUE 'ZCO_BANCO_IMPOSTOS',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_configs_not_found .

    CONSTANTS:
      BEGIN OF gc_config_not_found,
        msgid TYPE symsgid VALUE 'ZCO_BANCO_IMPOSTOS',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE 'GV_MSGV3',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_config_not_found .

    METHODS constructor
      IMPORTING
        iv_textid   LIKE if_t100_message=>t100key OPTIONAL
        io_previous TYPE REF TO cx_root OPTIONAL
        iv_msgv1    TYPE msgv1 OPTIONAL
        iv_msgv2    TYPE msgv2 OPTIONAL
        iv_msgv3    TYPE msgv3 OPTIONAL
        iv_msgv4    TYPE msgv4 OPTIONAL.

    DATA gv_msgv1   TYPE msgv1 READ-ONLY.
    DATA gv_msgv2   TYPE msgv2 READ-ONLY.
    DATA gv_msgv3   TYPE msgv3 READ-ONLY.
    DATA gv_msgv4   TYPE msgv4 READ-ONLY.

    METHODS get_bapi_return
      RETURNING
        VALUE(rt_return) TYPE bapiret2_t.

ENDCLASS.



CLASS zcx_co_process_banc_imp_upload IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF iv_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = iv_textid.
    ENDIF.

    me->gv_msgv1 = iv_msgv1.
    me->gv_msgv2 = iv_msgv2.
    me->gv_msgv3 = iv_msgv3.
    me->gv_msgv4 = iv_msgv4.

  ENDMETHOD.

  METHOD get_bapi_return.

    DATA: ls_message LIKE LINE OF rt_return.

    ls_message-type        = 'E'.
    ls_message-id          = if_t100_message~t100key-msgid.
    ls_message-number      = if_t100_message~t100key-msgno.
    IF gv_msgv1 IS NOT INITIAL.
      ls_message-message_v1 = gv_msgv1.
    ELSE.
      ls_message-message_v1 = if_t100_message~t100key-attr1.
      IF ls_message-message_v1 CA 'MSG'.
        CLEAR ls_message-message_v1.
      ENDIF.
    ENDIF.
    IF gv_msgv2 IS NOT INITIAL.
      ls_message-message_v2 = gv_msgv2.
    ELSE.
      ls_message-message_v2 = if_t100_message~t100key-attr2.
      IF ls_message-message_v2 CA 'MSG'.
        CLEAR ls_message-message_v2.
      ENDIF.
    ENDIF.
    IF gv_msgv3 IS NOT INITIAL.
      ls_message-message_v3 = gv_msgv3.
    ELSE.
      ls_message-message_v3 = if_t100_message~t100key-attr3.
      IF ls_message-message_v3 CA 'MSG'.
        CLEAR ls_message-message_v3.
      ENDIF.
    ENDIF.
    IF gv_msgv4 IS NOT INITIAL.
      ls_message-message_v4 = gv_msgv4.
    ELSE.
      ls_message-message_v4 = if_t100_message~t100key-attr4.
      IF ls_message-message_v4 CA 'MSG'.
        CLEAR ls_message-message_v4.
      ENDIF.
    ENDIF.

    APPEND ls_message TO rt_return.
    CLEAR ls_message.

  ENDMETHOD.

ENDCLASS.
