class DataSource
    ###
    A data source manages raw and derived data for different selections.  A data source can
    have many selections.  The raw data is expected to be in a split format

    data: mxn
    columns: n x 1
    index: m x 1
    ###

    constructor: (@data)->
        console.log Baobab
        @tree = new Baobab @data
        if @tree.select('columns').exists()
            for column,column_index in columns = @get 'columns'
                ### Create Dynamic Nodes for Each Column Data Source ###
                @addColumnDataSource column
        if @tree.select('index').exists()
            ### Create a data source for the index ###
            @addColumnDataSource 'index', Baobab.monkey ['index'], (data)-> data

    updateIndex: (new_index)->
        ### Set sorted data and indices ###
        @set 'data', d3.permute @get('data'), new_index.map (value)=>
                @ColumnDataSource('index').indexOf value
        @set 'index', new_index
        this

    addDerivedDataSource: (name, columns, f )->
        ### return the new data source ###
        cursor = @tree.select('columns')
        cursor.push name
        @addColumnDataSource name, Baobab.monkey columns.map((value)=>['ColumnDataSource',value,'data'])..., f
        data = cursor.get().map((column_name)=> @ColumnDataSource column_name)
        @tree.set 'data', d3.zip data...
        @ColumnDataSource name

    ColumnDataSource: (column_name)->
        if Array.isArray column_name
            d3.zip column_name.map((c)=>@get('ColumnDataSource', c,'data'))...
        else
            Array @get('ColumnDataSource', column_name,'data')...

    addColumnDataSource: (column, monkey)->
        monkey ?= Baobab.monkey ['data'], ['.','name'], ['columns'], (data,name,columns)->
            column_index = columns.indexOf name
            data.map (value)=> value[column_index]
        @set ['ColumnDataSource', column],
            name: column
            data: monkey

    sort: (columns,direction='ascending')->
        ### Multisort on an  ###
        MultiSort = (a,b,direction='ascending',i=0)->
            ### Multisorting function in d3 ###
            [a[i],b[i]] = [parseFloat(a[i]),parseFloat(b[i])]
            if a[i] == b[i] then MultiSort a, b, direction, i+1
            d3[direction] a[i],b[i]

        columns = if not Array.isArray columns then [columns] else columns
        sorted = d3.zip columns.map((c)=> @ColumnDataSource c)..., @ColumnDataSource 'index'
            .sort (a,b)-> MultiSort a,b,direction
        @updateIndex sorted.map (value)-> value[columns.length]
        this

    order: ()->
        ### Order the original indices ###
        @sort('index')

    shuffle: ()->
        ### Randomly Sort the Indices ###
        @updateIndex d3.shuffle @ColumnDataSource 'index'

    get: (args...)->  @tree.get args...
    set: (args...)->  @tree.set args...
