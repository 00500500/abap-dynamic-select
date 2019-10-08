# dynamic-select
ABAP Class for dynamic selects

First you have to instantiate an object of class  `zcl_ca_dynamic_select`.

Now you can add multiple where conditions to your select-object. For that you can use `add_where_cond` or `add_where_cond_key_to_key`.

You should only use `add_where_cond_key_to_key` if you want to match key fields of different names/types/lengths over two different tables, because the mapping less sharp.

For example → `vbak-vbeln = nast-objkey`

You can also chain multiple where conditions. To create where conditions you can use the class `zcl_where_cond`.

After you added your where conditions you can use `SELECT` or `SELECT_SINGLE` to access select your data.

It's also possible to do a `SELECT FOR ALL ENTRIES` but this only works for very simple cases, but only for very simple taks.

## Example

Take a look at the method `fill_internal_tables` in the [archiving engine repository](https://github.com/00500500/abap-archiving-engine/blob/master/src/zcl_are_database_session.clas.abap).
