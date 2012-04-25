// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

function checkOverflow(el)
{
   var curOverflow = el.style.overflow;
   //if ( !curOverflow || curOverflow === "visible" )
   //   el.style.overflow = "hidden";

   var isOverflowing = el.clientWidth < el.scrollWidth 
      || el.clientHeight < el.scrollHeight;

   //el.style.overflow = curOverflow;

   return isOverflowing;
}

$(function(){

  $(".res-data").each(function(){
    $el = $(this);
    if ( checkOverflow( $el.get(0) ) ) {
      $el.find(".res-more").css({ "display" : "block" });
    }
  });

  $(".res-more").click(function(){
    var $this = $(this);
    var $parent = $this.parents(".res-data");
    if ( $parent.css("overflow") == "hidden" ) {
      $parent.css({ "overflow" : "visible", "height" : "auto" });
      $this.find("span").html("Show less");
    }
    else
    {
      $parent.css({ "overflow" : "hidden", "height" : "315px" });
      $this.find("span").html("Show more");
    }
  });

});
