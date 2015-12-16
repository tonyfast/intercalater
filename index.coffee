---
---

window.manager = new Manager {{site.data.iris|jsonify}}

### Add a Selection to the Manager with ad hoc settings ###

Table::inView = (plot)->
    debugger
    [x,y]=plot.getAxis()
    columns = d3.merge @selection.select('tr.heading').datum()
    xx = columns.indexOf plot.cursor.get 'x'
    yy = columns.indexOf plot.cursor.get 'y'
    @selection.selectAll 'tr.values'
        .each (d)->
            if x.get('_end') > d[xx] > x.get('_start') and y.get('_end') > d[yy] > y.get('_start')
                d3.select(@).classed 'in', yes
            else
                d3.select(@).classed 'in', no
    @build()

table = manager.attach d3.selectAll('.vs').html(''),Table,'table'
scroller = manager.attach table.selection.select('table'), VirtualScroll,'scroll'

Plot::getAxis = ()->
    [
      @from_ref @cursor.get 'refs','x_range'
      @from_ref @cursor.get 'refs','y_range'
    ]

Plot::scrollCallback = ()-> table.inView @

plot = manager.attach d3.selectAll('#scatter'),Plot,'plot'
plot.load {{site.data.scatter|jsonify}}
## Shuffle the data ##
d3.selectAll('#shuffle').on 'click', ()=>
    manager.DataSource.shuffle()
    plot.updateSelected()
    table.inView plot
table.cursor.select 'max_rows'
    .on 'update', ()->
        scroller.updateSize()


# Set up listeners on the tree #
manager.DataSource.tree.select('index').on 'update', ()->
    table.build()

manager.DataSource.tree.select('data').on 'update', ()->
    scroller.updateSize()
manager.DataSource.tree.select('table','iloc').on 'update', ()-> table.build()

scroller.render = ()->
  plot.updateSelected()
  table.inView plot
##Fix the table width ##
table.selection.select('table')
    .style 'width', '900px'
