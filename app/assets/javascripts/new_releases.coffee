$(document).on 'turbolinks:load', ->
  dataTable = $('#releases').DataTable
    order: []
    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]]
    pageLength: 25
    dom:"<'row'<'col-sm-6'l><'col-sm-6'<'#tableFilter'>>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'row'<'col-sm-5'i><'col-sm-7'p>>",
  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    dataTable.search( e.target.value ).draw()

  $('#releases tbody').on 'click', 'tr', ->
    jThis = $(this)
    tr = jThis.closest('tr')
    row = dataTable.row(tr)

    if row.child.isShown()
      row.child.hide()
      tr.removeClass 'shown'
    else
      row.child(tr.data('preview')).show()
      tr.addClass('shown')

  dataTable.customFilters = []
  $(document).on 'click', '.creator-filter', (e)->
    creatorName = e.target.innerText
    selector = $(e.target)

    if selector.hasClass 'filterOn'
      dataTable.customFilters = dataTable.customFilters.filter (elem)->
        elem != creatorName
      selector.removeClass 'filterOn'
    else
      selector.addClass 'filterOn'
      dataTable.customFilters.push creatorName
    dataTable.search(dataTable.customFilters.join('|'), true, false, true).draw()


