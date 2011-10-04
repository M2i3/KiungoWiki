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
  $("input.work_title_lookup").tokenInput("/works/lookup.json", {
     tokenLimit: 1,
     classes: {
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
      }  
  });

  $("input.artist_name_lookup").tokenInput("/artists/lookup.json", {
     classes: {
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
      }  
  });
  

});

