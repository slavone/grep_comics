$(document).on 'ready', ->
  dataTable = $('#creators-table').DataTable
    processing: true
    serverSide: true
    ajax: $('#creators-table').data('source')
    pagingType: 'full_numbers'
    order: [[0, 'asc']]
    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, "All"]]
    pageLength: 100
    columns: [
      { orderable: true },
      { orderable: true },
      { orderable: true },
      { orderable: true }
    ]
    dom: "<'row'<'col-sm-5'l>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
         "<'row'<'col-sm-12'<'#tableFilter'>>>" +
         "<'row'<'col-sm-12'tr>>" +
         "<'row'<'col-sm-5'i><'col-sm-7'p>>",

  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    dataTable.search( e.target.value ).draw()
