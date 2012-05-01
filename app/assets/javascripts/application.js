// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.8.16.custom.min
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

jQTubeUtil.init({
  key: "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q",
  orderby: "viewCount",  // *optional -- "viewCount" is set by default
  time: "this_month",   // *optional -- "this_month" is set by default
  maxResults: 10   // *optional -- defined as 10 results by default
});


$(function(){
  
  $("#searchInput").autocomplete({
		source: function( request, response ) {
      var q = request.term;
      jQTubeUtil.suggest(q, function(data){
        response( $.map( data.suggestions.slice(0, 5), function( item ) {
          return {
            label: item,
            value: item
          }
        }));
      });
		},
		minLength: 2,
		select: function( event, ui ) {      
			$form = $(this).parents("form");
      setTimeout(function(){
        $form.submit();
      }, 0);
		},
		open: function() {
			$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
		},
		close: function() {
			$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
		}
	});

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
      $parent.attr("orig-height", $parent.css("height"));
      $parent.css({ "overflow" : "visible", "height" : "auto" });
      $this.find("span").html("Show less");
    }
    else
    {
      $parent.css({ "overflow" : "hidden", "height" : $parent.attr("orig-height") });
      $this.find("span").html("Show more");
    }
  });
  
  $("#filter").click(function(e){
    if ( $(this).hasClass("open") ) {
      $(".filter-options").css({ display : "none" });
    }
    else
    {
      $(".filter-options").css({ display : "" });
    }
    $(this).toggleClass("open");
    e.preventDefault();
  });

});
