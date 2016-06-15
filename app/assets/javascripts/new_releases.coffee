$(document).on 'turbolinks:load', ->
  table = $('#releases').DataTable
    order: []
    lengthMenu: [[25, 50, 100, -1], [10, 25, 50, "All"]]
    pageLength: -1
    dom:"<'row'<'col-sm-2'l><'col-sm-10'<'#tableFilter'>>>" +
        "<'row'<'col-sm-12'tr>>" +
        "<'row'<'col-sm-5'i><'col-sm-7'p>>",
  searchField = $('#tableFilter').html "<input class='form-control' style='width: 100%' placeholder='Search'>"
  $(searchField).on 'search input paste cut', (e)->
    table.search( e.target.value ).draw()

