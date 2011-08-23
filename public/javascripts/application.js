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
          tokenList: "token-input-list-facebook",
          token: "token-input-token-facebook",
          tokenDelete: "token-input-delete-token-facebook",
          selectedToken: "token-input-selected-token-facebook",
          highlightedToken: "token-input-highlighted-token-facebook",
          dropdown: "token-input-dropdown-facebook",
          dropdownItem: "token-input-dropdown-item-facebook",
          dropdownItem2: "token-input-dropdown-item2-facebook",
          selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
          inputToken: "token-input-input-token-facebook"
      },
     prePopulate: [{"id":"4e4c325f41c25e0a64000023","name":"La maison de mon enfance"}] 
  });

  $("input.work_title_lookup").each(function (){
    alert($.data(this,"prepopulate"));
  });

});

