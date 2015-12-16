class Manager
    ###
    One Data Source for many selections
    Attaches event driven data tress to selections
    Selections in a manager share a data source
    ###
    constructor: (@data)->
        ### @data changes state many times ###
        @DataSource = new Manager.DataSource @data
        @Selections = []

    attach: (selection,SelectionType,name,config)->
        ### Attach a new selection to the manager ###
        selections_list = @Selections.filter (s)=> s.selection.node() == selection.node()
        if selections_list.length == 0
            id = @Selections.push new SelectionType selection, name, @DataSource.tree, config
            @Selections[id-1]
        else
            selections_list[0]
