*"* use this source file for your ABAP unit test classes
CLASS lct_dynamic_select DEFINITION FOR TESTING
RISK LEVEL harmless
DURATION SHORT.

PRIVATE SECTION.

    DATA: o_cut TYPE REF TO zcl_dynamic_select.

    methods setup.
    METHODS select_found_data FOR TESTING
              RAISING
                cx_taan_field_not_found
                cx_mi_no_value_found.
    methods select_single_found_data FOR TESTING
              RAISING
                cx_taan_field_not_found
                cx_mi_no_value_found.


ENDCLASS.

CLASS lct_dynamic_select IMPLEMENTATION.

  METHOD setup.

    "given
    o_cut = zcl_dynamic_select=>get_instance( 'SFLIGHT' ).

  ENDMETHOD.

  METHOD select_found_data.

    DATA lt_sflight TYPE TABLE OF sflight.
    DATA: l_CARRID TYPE sflight-CARRID VALUE 'AA'.

    "when
    o_cut->add_where_cond( l_CARRID ).
    o_cut->select( IMPORTING et_select_result = lt_sflight ).

    "then
    cl_abap_unit_assert=>assert_not_initial( act = lt_sflight ).

  ENDMETHOD.

  METHOD select_single_found_data.

    DATA ls_sflight TYPE sflight.
    DATA: l_CARRID TYPE sflight-CARRID VALUE 'AA'.

    "when
    o_cut->add_where_cond( l_CARRID ).
    o_cut->select_single( IMPORTING eg_select_result = ls_sflight ).

    "then
    cl_abap_unit_assert=>assert_not_initial( act = ls_sflight ).

  ENDMETHOD.

ENDCLASS.
