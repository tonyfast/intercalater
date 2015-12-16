class Plot extends Selection
    from_ref = (ref)-> Bokeh.Collections(ref.type).get ref.id
    config:
        ColumnDataSource: Baobab.monkey ['ColumnDataSource'],['columns'],['index'], (cds,columns,index)->
            updated = {}
            columns.forEach (k)=> updated[k] = cds[k]['data']
            updated
    constructor: (selection,name,tree,config)->
        super selection, name, tree, config
        @from_ref = from_ref

    load: (p)->
        plot = p['payload'].filter (d)-> d.type in ['Plot']
        Bokeh.load_models  p['payload']
        @figure = from_ref plot[0]
        view = new @figure.default_view
          model: @figure,
          el: '#'+@selection.attr 'id'
        delete p['payload']
        @cursor.set p
        @cds = from_ref @cursor.get 'refs','source'
        @select = @cds.get 'selected'

        @updateDataSource()

    updateDataSource: ->
        new_source = @cursor.get 'ColumnDataSource'
        cds = from_ref @cursor.get 'refs','source'
        old_source = cds.get 'data'
        d3.entries new_source
            .forEach (n)=> old_source[n.key] = n.value
        cds.set 'data', old_source
        cds
    updateSelected: ->
        @select['1d']['indices'] = @tree.get 'table','index'
        @cds.set 'selected', @select
        @cds.trigger 'select'
