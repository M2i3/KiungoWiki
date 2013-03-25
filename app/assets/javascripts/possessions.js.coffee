$(document).ready ->
  $('a#confirmaddmusic').click (e) ->
    e.preventDefault()
    haveText = $('span#havemusic').text()
    $albumLink = $('a#addmusic')
    if $albumLink.text() != haveText
      jqxhr = $.post '/possessions.json',
        possession:
          album_id: $(this).attr 'data-album-id'
        (data) =>
          $albumLink.text haveText
          $('#addmusicform').modal('hide')
          $albumLink.removeAttr 'data-toggle'
      jqxhr.fail (data) ->
        console.log data
        alert $('span#adderror').text()