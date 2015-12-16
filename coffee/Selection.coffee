class Selection 
    constructor: (@selection, @name, @tree, config)->
        @tree.set [@name], config
        @cursor = @tree.select [@name]


    update: (selection,selector,data,direction='down')->
        ### Repeatable pattern for creating, updating, and removing data dependent dom elements ###
        [tag,classes...] = selector.split '.'
        selection = selection.selectAll(selector).data data
        if direction in ['right','down']
            selection.enter().append tag
        else if direction in ['left','up']
            selection.enter().insert tag, ':first-child'
        classes.forEach (c)=> selection.classed c, yes
        selection.exit().remove()
        selection

    clear: ()-> @selection.html ''
