class Table extends Selection
    config:
        max_rows: 20
        iloc: 0
        show_id: yes
        index: Baobab.monkey ['.','max_rows'],['.','iloc'],['index'], (rows, iloc, index)->
            d3.range iloc, iloc+rows
                .map (iloc)=> index[iloc]
        columns:
            index: ['index','species']
            exclude: []
            order: Baobab.monkey ['.','index'],['.','exclude'],['columns'], (index,exclude,columns)->
                [
                    index
                    columns.filter (c)=> c not in index
                        .filter (c)=> c not in exclude
                ]
            values: Baobab.monkey ['ColumnDataSource'],['..','index'],['.','order'], (cds, index, order)->
                v = d3.merge order
                    .map (column)=>
                        index.map (i)=> cds[column]['data'][i]
                d3.zip v...
    constructor: (selection,name,tree)->
        super selection, name, tree, @config
        @build()
    build: ->
        table_cursor = @tree.select 'table'
        table = @update @selection, 'table', [1]
        order = table_cursor.get 'columns','order'
        [left_heading, right_heading] = order
        heading = @update table, 'tr.heading', [order], 'up'
        _t = @

        heading.each (columns)->
            _t.update d3.select(@), 'th.index', left_heading,'left'
                .text (d)-> d
            _t.update d3.select(@), 'th.value', right_heading,'right'
                .text (d)-> d
        values = @update table, 'tr.values', table_cursor.get('columns','values'), 'down'
        values.each (row_values)->
            _t.update d3.select(@), 'th.index', left_heading,'left'
            _t.update d3.select(@), 'td.value', right_heading,'right'
            d3.select(@).selectAll 'th.index,td.value'
                .data row_values
                .text (d)-> d
