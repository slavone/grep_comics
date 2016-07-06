$(document).on 'ready', ->
  dataTable = $('#releases').DataTable
    order: []
    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]]
    pageLength: 50
    dom: "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
         "<'row'<'col-sm-6'l><'col-sm-6'<'#tableFilter'>>>" +
         "<'row'<'col-sm-12'tr>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>",

  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    dataTable.search( e.target.value ).draw()

  dataTable.columns('.creators')
  dataTable.searchFilters = []
  dataTable.addSearchFilter = (word) ->
    this.searchFilters.push word
  dataTable.removeSearchFilter = (word) ->
    this.searchFilters = this.searchFilters.filter (elem)->
      elem != word
  dataTable.applySearchFilters = ->
    this.search(this.searchFilters.join('|'), true, false, true).draw()

  $('#releases tbody').on 'click', 'tr', ->
    tr = $(this)
    row = dataTable.row(tr)

    if row.child.isShown()
      row.child.hide()
      tr.removeClass 'shown'
    else
      row.child(tr.data('preview')).show()
      tr.addClass('shown')

  appliedFilterLi = (value) ->
    return '<li class="applied-filter"><a><span>' +
      value + '</span><i class="fa fa-times pull-right"></i></a></li>'

  $('.main-sidebar').on 'click', '.filterable', (e)->
    filterValue = e.target.innerText
    selector = $(e.target)

    if selector.hasClass 'filterOn'
      dataTable.removeSearchFilter filterValue
      selector.removeClass 'filterOn'
      $('.applied-filter:contains("' + filterValue + '")').remove()
    else
      dataTable.addSearchFilter filterValue
      selector.addClass 'filterOn'
      $('#applied_filters').after(appliedFilterLi(filterValue))

    dataTable.applySearchFilters()

  $('.main-sidebar').on 'click', '.applied-filter', (e)->
    filterValue = e.target.innerText
    dataTable.removeSearchFilter filterValue
    $('.filterOn:contains("' + filterValue + '")').removeClass 'filterOn'
    $(e.target).parent().remove()
    dataTable.applySearchFilters()
