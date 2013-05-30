// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.tokeninput
//= require jquery.ui.datepicker
//= require possessions
//= require user_tag
//= require_self

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var myMessages = ['info','warning','error','notice'];

function hideAllMessages()
{
  var messagesHeights = new Array(); // this array will store height for each

  for (i=0; i<myMessages.length; i++)
  {
    messagesHeights[i] = $('.' + myMessages[i]).outerHeight(); // fill array
    $('.' + myMessages[i]).css('top', -messagesHeights[i]); //move element outside viewport
  }
}

function slideAllMessages()
{
  $('.message').each(function(){
    $(this).animate({top: -$(this).outerHeight()}, 500);
  });            
}


$(document).ready(function(){

  // Initially, hide them all
  hideAllMessages();

  // Show message
  for(var i=0;i<myMessages.length;i++)
  {                        
    $('.'+myMessages[i]).animate({top:"0"}, 500);
  }

  // When message is clicked, hide it
  $('.message').click(function(){
    $(this).animate({top: -$(this).outerHeight()}, 500);
  });            

  setTimeout(slideAllMessages, 5000);  

});

$(document).ready(function () {

  default_classes = {
          tokenList: "token-input-list",
          token: "token-input-token",
          tokenDelete: "token-input-delete-token",
          selectedToken: "token-input-selected-token",
          highlightedToken: "token-input-highlighted-token",
          dropdown: "token-input-dropdown",
          dropdownItem: "token-input-dropdown-item",
          dropdownItem2: "token-input-dropdown-item2",
          selectedDropdownItem: "token-input-selected-dropdown-item",
          inputToken: "token-input-input-token"
      };


  /* 
    Work === Work === Work === Work === Work === Work === Work === Work === Work === Work
  */
  $("input.work_title_lookup").tokenInput("/works/lookup.json", {
     tokenLimit: 1,
     classes: default_classes
  });
  
  $("input.works_title_lookup").tokenInput("/works/lookup.json", {
     classes: default_classes
  });

  $("input.artist_works_title_lookup").tokenInput("/works/lookup.json?src=artist", {
     classes: default_classes
  });

  $("input.recording_works_title_lookup").tokenInput("/works/lookup.json?src=recording", {
     classes: default_classes
  });

  $("input.work_works_title_lookup").tokenInput("/works/lookup.json?src=work", {
     classes: default_classes
  });

  /*
    Artist === Artist === Artist === Artist === Artist === Artist === Artist === Artist
  */
  $("input.artist_lookup").tokenInput("/artists/lookup.json", {
     tokenLimit: 1,
     classes: default_classes
  });

  $("input.artists_lookup").tokenInput("/artists/lookup.json", {
     classes: default_classes
  });

  $("input.release_artists_lookup").tokenInput("/artists/lookup.json?src=release", {
     classes: default_classes
  });

  $("input.artist_artists_lookup").tokenInput("/artists/lookup.json?src=artist", {
     classes: default_classes
  });

  $("input.recording_artists_lookup").tokenInput("/artists/lookup.json?src=recording", {
     classes: default_classes
  });

  $("input.work_artists_lookup").tokenInput("/artists/lookup.json?src=work", {
     classes: default_classes
  });

  /*
    Release === Release === Release === Release === Release === Release === Release === Release === Release
  */
  $("input.release_title_lookup").tokenInput("/releases/lookup.json", {
     tokenLimit: 1,
     classes: default_classes
  });
  
  $("input.releases_title_lookup").tokenInput("/releases/lookup.json", {
     classes: default_classes
  });

  $("input.artist_releases_title_lookup").tokenInput("/releases/lookup.json?src=artist", {
     classes: default_classes
  });

  $("input.recording_releases_title_lookup").tokenInput("/releases/lookup.json?src=recording", {
     classes: default_classes
  });

  /* 
    Recording === Recording === Recording === Recording === Recording === Recording === Recording
  */
  $("input.recording_title_lookup").tokenInput("/recordings/lookup.json", {
     tokenLimit: 1,
     classes: default_classes
  });
  
  $("input.recordings_title_lookup").tokenInput("/recordings/lookup.json", {
     classes: default_classes
  });

  $("input.release_recordings_title_lookup").tokenInput("/recordings/lookup.json?src=release", {
     classes: default_classes
  });

  $("input.artist_recordings_title_lookup").tokenInput("/recordings/lookup.json?src=artist", {
     classes: default_classes
  });

  $("input.work_recordings_title_lookup").tokenInput("/recordings/lookup.json?src=work", {
     classes: default_classes
  });

  /*
    Category === Category === Category === Category === Category === Category === Category
  */
  $("input.category_lookup").tokenInput("/categories/lookup.json", {
     tokenLimit: 1,
     classes: default_classes
  });

  $("input.categories_lookup").tokenInput("/categories/lookup.json", {
     classes: default_classes
  });
  
  /*
    Label === Label === Label === Label === Label === Label === Label
  */
  $('input.labels_lookup').tokenInput("/labels/lookup.json", {
     classes: default_classes
  });

});


