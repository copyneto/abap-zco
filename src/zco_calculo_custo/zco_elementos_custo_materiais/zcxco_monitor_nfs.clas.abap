CLASS zcxco_monitor_nfs DEFINITION
PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message.

    CONSTANTS:
      BEGIN OF gc_unauthorized,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_unauthorized .

    CONSTANTS:
      BEGIN OF gc_error_in_process,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_error_in_process .

    CONSTANTS:
      BEGIN OF gc_period_not_permited,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_period_not_permited .

    CONSTANTS:
      BEGIN OF gc_nf_in_action_pc,
        msgid TYPE symsgid VALUE 'ZCO_MONITOR_NFS',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_nf_in_action_pc.

    METHODS constructor
      IMPORTING
        iv_severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcxco_monitor_nfs IMPLEMENTATION.


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

    me->if_abap_behv_message~m_severity = iv_severity.

    me->gv_msgv1 = iv_msgv1.
    me->gv_msgv2 = iv_msgv2.
    me->gv_msgv3 = iv_msgv3.
    me->gv_msgv4 = iv_msgv4.

  ENDMETHOD.
ENDCLASS.
