$(document).on 'ready', ->
  dataTable = $('#releases').DataTable
    order: []
    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]]
    pageLength: 25
    dom: "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
         "<'row'<'col-sm-6'l><'col-sm-6'<'#tableFilter'>>>" +
         "<'row'<'col-sm-12'tr>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>",

  dataTable.searchFilters = []
  dataTable.addSearchFilter = (word) ->
    this.searchFilters.push word
  dataTable.removeSearchFilter = (word) ->
    this.searchFilters = this.searchFilters.filter (elem)->
      elem != word
  dataTable.applySearchFilters = ->
    this.search(this.searchFilters.join('|'), true, false, true).draw()

  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    dataTable.search( e.target.value ).draw()

  $('#releases tbody').on 'click', 'tr', ->
    tr = $(this)
    row = dataTable.row(tr)

    if row.child.isShown()
      row.child.hide()
      tr.removeClass 'shown'
    else
      row.child(tr.data('preview')).show()
      tr.addClass('shown')

  $(document).on 'click', '.creator-filter', (e)->
    creatorName = e.target.innerText
    selector = $(e.target)

    if selector.hasClass 'filterOn'
      dataTable.removeSearchFilter creatorName
      selector.removeClass 'filterOn'
    else
      selector.addClass 'filterOn'
      dataTable.addSearchFilter creatorName
    dataTable.applySearchFilters()
