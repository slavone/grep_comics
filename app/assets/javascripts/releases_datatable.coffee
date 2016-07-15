$(document).on 'ready', ->
  $('.toggle-filters').on 'click', ->
    button = document.getElementById 'toggle-filters-button'
    if button.innerText == 'Show filters'
      button.innerText = 'Hide filters'
    else
      button.innerText = 'Show filters'

  dataTable = $('#releases').DataTable
    order: []
    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]]
    pageLength: 50
    dom: "<'row'<'col-sm-5'l>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
         "<'row'<'col-sm-12'<'#tableFilter'>>>" +
         "<'row'<'col-sm-12'tr>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>",

  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    dataTable.search( e.target.value ).draw()

  dataTable.searchFilters = {
    publishers: []
    creators: []
    editions: []
  }

  dataTable.addSearchFilter = (word, type) ->
    this.searchFilters[type].push word

  dataTable.removeSearchFilter = (word, type) ->
    this.searchFilters[type] = this.searchFilters[type].filter (elem)->
      elem != word

  dataTable.applySearchFilter = (type)->
    if type == 'creators'
      this
        .search(dataTable.searchFilters[type].join('|'), true, false, true)
        .draw()
    else
      columnSelector = '#' + type
      this.column(columnSelector)
        .search(this.searchFilters[type].join('|'), true, false, true)
        .draw()

  dataTable.applySearchFilters = ()->
    $.each this.searchFilters, (key, val)->
      if val
        dataTable.applySearchFilter key

  $('#releases tbody').on 'click', 'tr', ->
    tr = $(this)
    row = dataTable.row(tr)

    if row.child.isShown()
      row.child.hide()
      tr.removeClass 'shown'
    else
      row.child(tr.data('preview')).show()
      tr.addClass('shown')

  appliedFilterLi = (type, value) ->
    return '<li class="applied-filter"><a data-filter-type="' + type +
    '">' + value + '</a></li>'

  $('.main-sidebar').on 'click', '.filterable', (e)->
    filterValue = e.target.innerText
    selector = $(e.target)
    filterType = selector.data('filter-type')

    if selector.hasClass 'filterOn'
      dataTable.removeSearchFilter filterValue, filterType

      selector.removeClass 'filterOn'
      $('.applied-filter:contains("' + filterValue + '")').remove()
    else
      dataTable.addSearchFilter filterValue, filterType
      selector.addClass 'filterOn'
      $('#applied_filters').after(appliedFilterLi(filterType, filterValue))

    dataTable.applySearchFilters(filterType)

  $('.main-sidebar').on 'click', '.applied-filter', (e)->
    filterValue = e.target.innerText
    console.log $(e.target)
    filterType = $(e.target).data('filter-type')

    dataTable.removeSearchFilter filterValue, filterType
    $('.filterOn:contains("' + filterValue + '")').removeClass 'filterOn'
    $(e.target).parent().remove()
    dataTable.applySearchFilters()
