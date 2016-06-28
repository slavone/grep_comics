$(document).on 'ready', ->
  dataTable = $('#creators-table').DataTable
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
