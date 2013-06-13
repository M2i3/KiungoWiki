$ ->
  $('a#confirmaddtag').click (e) ->
    name = $('input#name').val()
    jqxhr = $.post "#{window.location.pathname}/user_tags.json",
      user_tag:
        name: name
      (data) =>
        liTags = ""
        for tagName in name.split(",")
          liTags += "<li>#{tagName}</li>"
        $('ul#tags').html liTags
        $('#addtagform').modal('hide')
    jqxhr.fail (data) ->
      console.log data