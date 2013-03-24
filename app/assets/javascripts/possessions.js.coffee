$(document).ready ->
  $('a#addmusic').click (e) ->
    e.preventDefault()
    $albumLink = $(this)
    haveText = 'Already in My Music'
    if $albumLink.text() != haveText
      $('div#addmusicform').dialog
        height: 200
        width: 350
        modal: true
        buttons:
          "Add to My Music": ->
            jqxhr = $.post '/possessions.json',
              possession:
                album_id: $albumLink.attr 'data-album-id'
              (data) =>
                $albumLink.text haveText
                $(this).dialog('close')
            jqxhr.fail (data) ->
              console.log data
              alert 'Album not added, please try again or be sure that you do not already own this album'
        Cancel: ->
          $(this).dialog('close')