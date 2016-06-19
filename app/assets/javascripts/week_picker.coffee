$(document).on 'ready', ->
  weekPicker = $('#wednesday-datepicker')
  weekPicker.datepicker
    daysOfWeekHighlighted: '3'
    format: 'yyyy/mm/dd'
  weekPicker.datepicker 'update', $('#weekday').data('week')
  weekPicker.on 'changeDate', (e)->
    date = e.date.getFullYear() + '-' + (e.date.getMonth()+1) + '-' + e.date.getDate()
    window.location.href = "/releases/" + date
