/*
 *  Copyright (c) Business Thinking Ltd. 2019-2022
 *  This software includes code developed by the dbtvault Team at Business Thinking Ltd. Trading as Datavault
 */

{%- macro print_list(list_to_print=none, indent=4, columns_to_escape=none) -%}

    {%- for col_name in list_to_print -%}
        {%- if col_name | lower in columns_to_escape | map('lower') | list -%}
            {{- dbtvault.escape_column_name(col_name) | indent(indent) -}}{{ ",\n    " if not loop.last }}
        {%- else -%}
            {{- col_name | indent(indent) -}}{{ ",\n    " if not loop.last }}
        {%- endif -%}
    {%- endfor -%}

{%- endmacro -%}