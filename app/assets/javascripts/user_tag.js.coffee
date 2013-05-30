$ ->
  $('a#confirmaddtag').click (e) ->
    jqxhr = $.post '/user_tags.json',
      user_tag:
        taggable_id: $(this).attr 'data-resource-id'
        taggable_class: $(this).attr 'data-resource-class'
        name: $('input#name').val()
      (data) =>
        $('#addtagform').modal('hide')
    jqxhr.fail (data) ->
      console.log data