---
---

window.manager = new Manager {{site.data.iris|jsonify}}

### Add a Selection to the Manager with ad hoc settings ###
table = manager.attach d3.selectAll('.vs').html(''),Table,'table'
scroller = manager.attach table.selection.select('table'), VirtualScroll,'scroll'

plot = manager.attach d3.selectAll('#scatter'),Plot,'plot'

plot.load {{site.data.scatter|jsonify}}

## Shuffle the data ##
d3.selectAll('#shuffle').on 'click', ()=>
    manager.DataSource.shuffle()
    plot.updateSelected()
table.cursor.select 'max_rows'
    .on 'update', ()->
        table.build()
        scroller.updateSize()

# Set up listeners on the tree #
manager.DataSource.tree.select('index').on 'update', ()->
    table.build()

manager.DataSource.tree.select('data').on 'update', ()->
    scroller.updateSize()
manager.DataSource.tree.select('table','iloc').on 'update', ()-> table.build()

scroller.render = ()-> plot.updateSelected()

##Fix the table width ##
table.selection.select('table')
    .style 'width', '900px'

console.log table.selection.node()
