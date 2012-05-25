# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  #alert( $('.pagination li a').length );
  $('.pjax-enabled').pjax('[data-pjax-container]', {timeout: 5000})
  #$('.pagination li a').pjax('[data-pjax-container]', {timeout: 5000})
  #$('.pagination li a').click (e) ->
  #  e.preventDefault();
