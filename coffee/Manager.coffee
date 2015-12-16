class Manager
    ###
    One Data Source for many selections
    Attaches event driven data tress to selections
    Selections in a manager share a data source
    ###
    constructor: (@data)->
        ### @data changes state many times ###
        @DataSource = new Manager.DataSource @data
        @Selections = {}

    attach: (selection,SelectionType,name,config)->
        ### Attach a new selection to the manager ###
        if name not in @Selections
            @Selections[name] = new SelectionType selection, name, @DataSource.tree, config
        @Selections[name]
