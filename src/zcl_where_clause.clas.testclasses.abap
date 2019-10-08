*"* use this source file for your ABAP unit test classes
class lct_where_clause definition final for testing
  duration short
  risk level harmless.

  private section.

    methods:
      create_as_eq for testing raising cx_static_check,
      create_as_ne FOR TESTING RAISING cx_static_check,
      create_as_like FOR TESTING RAISING cx_static_check,
      add_and_eq FOR TESTING RAISING cx_static_check,
      add_and_ne FOR TESTING RAISING cx_static_check,
      add_and_like FOR TESTING RAISING cx_static_check,
      add_or_eq FOR TESTING RAISING cx_static_check,
      add_or_ne FOR TESTING RAISING cx_static_check,
      add_or_like FOR TESTING RAISING cx_static_check,
      multiple_chainings FOR TESTING RAISING cx_static_check.
endclass.


class lct_where_clause implementation.

  method create_as_eq.

    cl_abap_unit_assert=>assert_equals( act = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                                         i_value = 'AA' )->get( )
                                        exp = |CARRID EQ 'AA'| ).
  endmethod.

  method create_as_ne.
    cl_abap_unit_assert=>assert_equals( act = zcl_where_clause=>create_as_ne( i_fieldname = 'CARRID'
                                                                                         i_value = 'AA' )->get( )
                                        exp = |CARRID NE 'AA'| ).
  endmethod.

  method create_as_like.
    cl_abap_unit_assert=>assert_equals( act = zcl_where_clause=>create_as_like( i_fieldname = 'CARRID'
                                                                                           i_value = 'A' )->get( )
                                        exp = |CARRID LIKE 'A%'| ).
  endmethod.

  method add_and_eq.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_and_eq( i_fieldname = 'CONNID'
                                 i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' AND CONNID EQ '17'| ).
  endmethod.

  method add_and_ne.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_and_ne( i_fieldname = 'CONNID'
                                 i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' AND CONNID NE '17'| ).
  endmethod.

  method add_and_like.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_and_like( i_fieldname = 'CONNID'
                                   i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' AND CONNID LIKE '17%'| ).
  endmethod.

  method add_or_eq.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_or_eq( i_fieldname = 'CONNID'
                                i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' OR CONNID EQ '17'| ).
  endmethod.

  method add_or_ne.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_or_ne( i_fieldname = 'CONNID'
                                i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' OR CONNID NE '17'| ).
  endmethod.

  method add_or_like.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_or_like( i_fieldname = 'CONNID'
                                  i_value = '17' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' OR CONNID LIKE '17%'| ).
  endmethod.

  method multiple_chainings.

    DATA(lo_where_clause) = zcl_where_clause=>create_as_eq( i_fieldname = 'CARRID'
                                                                       i_value = 'AA' ).

    lo_where_clause->add_or_like( i_fieldname = 'CONNID'
                                  i_value = '17' ).

    lo_where_clause->add_and_eq( i_fieldname = 'CURRENCY'
                                 i_value = 'USD' ).

    cl_abap_unit_assert=>assert_equals( act = lo_where_clause->get( )
                                        exp = |CARRID EQ 'AA' OR CONNID LIKE '17%' AND CURRENCY EQ 'USD'| ).
  endmethod.
endclass.
