class VirtualScroll extends Selection
    s = (v)->"#{v}px"
    config:
        speed: 1
        max_rows: Baobab.monkey ['table','max_rows'], (v)-> v
        rowHeight: 20
        height: 800
        width: 600
        scroll_width: 50
        size: Baobab.monkey ['index'], (v)-> v.length
    constructor: (selection,name,tree)->
        super selection, name, tree, @config
        _this = @
        @cursor = @tree.select ['scroll']
        @cursor.set @config
        @parent = d3.select @selection.property 'parentNode'
        @before = @update @parent, 'div.before.longscroll', [0], 'up'
        @current = @update @parent, 'div.current.longscroll', [0], 'down'
        @after = @update @parent, 'div.after.longscroll', [0], 'down'
        @updateSize()
        console.log @parent
        @parent.on 'scroll.longscroll', ()->
            position = Math.floor _this.offset @scrollTop, 'screen-data'
            _this.updateSize()
            _this.scroll @scrollTop,position
        @scroll 0, @tree.get('index',0)
        @build()
    build: ->
        [maxRows,size] = @cursor.project [['max_rows'],['size']]
        @cursor.set ['rowHeight'], d3.mean @selection.selectAll('tr.rows')[0].map (t)-> t.offsetHeight
        @updateSize()
    scroll: (scrollTop,position)->
        @current.call (current)=>
            current.property 'scrollTop', scrollTop
            position = d3.max [0, d3.min [@cursor.get('size') - @cursor.get('max_rows'), position]]
            @before.style("height", s @offset position )
            @after.style("height", s @offset @cursor.get('size')-position)

            if Math.abs(position - @tree.get('table','iloc'))>=1
                @tree.select('table','iloc').set position
                @render()
    offset: (v,method="data-screen")->
        scale = d3.scale.linear()
            .domain [0,@cursor.get('size')-@cursor.get('max_rows')]
            .range [0,@cursor.get('size')*@cursor.get('size')]
            .clamp yes
        if method in ['data-screen']
            scale v
        else if method in ['screen-data']
            Math.floor scale.invert(v)
    updateSize: ()->
        @selection.style
            position: 'absolute'
            left: s d3.select(@selection.property 'parentNode').property('offsetLeft')
            top: s d3.select(@selection.property 'parentNode').property('offsetTop')
            'margin-top': s 0
        @parent.style
            'overflow-y': 'auto'
            height: s @selection.property 'offsetHeight'
            width: s @cursor.get('scroll_width')+@selection.property 'offsetWidth'
            'background-color': 'cyan'
    render: ()->
