$ ->
  $('input#acquisition_date').datepicker dateFormat: "yyyy-mm-dd"
  $('a#confirmaddmusic').click (e) ->
    e.preventDefault()
    haveText = $.trim($('span#havemusic').text())
    $releaseLink = $('a#addmusic')
    labels = []
    $('li.token-input-token-facebook p').each ->
      labels.push $(this).text()
    if $.trim($releaseLink.text()) != haveText
      jqxhr = $.post '/possessions.json',
        possession:
          release_wiki_link_text: "oid:#{$(this).attr 'data-release-id'}"
          labels: labels
          comments: $('textarea#comments').val()
          acquisition_date: $('input#acquisition_date').val()
          rating: $('input#rating').val()
        (data) =>
          $(this).attr 'data-possession-id', data._id
          $releaseLink.text haveText
          $(this).text $('span#update').text()
          $('#addmusicform').modal('hide')
      jqxhr.fail (data) ->
        console.log data
        alert $('span#adderror').text()
    else
      jqxhr = $.post "/possessions/#{$(this).attr 'data-possession-id' }.json",
        _method: 'PUT'
        possession:
          labels: labels
          comments: $('textarea#comments').val()
          acquisition_date: $('input#acquisition_date').val()
          rating: $('input#rating').val()
        (data) ->
          console.log data
          $releaseLink.text haveText
          $('#addmusicform').modal('hide')
      jqxhr.fail (data) ->
        console.log data
        alert $('span#adderror').text()