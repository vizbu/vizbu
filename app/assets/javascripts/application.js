// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.8.16.custom.min
//= require jquery.pjax
//= require_tree .

function checkOverflow(el)
{
   var curOverflow = el.style.overflow;

   var isOverflowing = el.clientWidth < el.scrollWidth 
      || el.clientHeight < el.scrollHeight;

   return isOverflowing;
}

jQTubeUtil.init({
  key: "AI39si5-1s6CVSSGdBqlMnzN9v_OMBufAMEW-0H4Ke1UG5laQpDCWyWJU5WJlpVHPXSTHyBDHEoFsbBdLfwgHBs7Aic3tjHR0Q",
  orderby: "viewCount",  // *optional -- "viewCount" is set by default
  time: "this_month",   // *optional -- "this_month" is set by default
  maxResults: 10   // *optional -- defined as 10 results by default
});

$(function(){
  
  $(".search-form").submit(function(){
    if (!$.trim( $(this).find("#searchInput").val() ).length){
      return false;
    }
  });
  
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

  $("body").on("click", "#filter", function(e){
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

  $(".source-link").click(function(){
  });

  $("body").on("click", ".share_video a", function(){
    var $this = $(this);
    window.open($this.attr("href"),'sharer','toolbar=0,status=0,width=650,height=450');
    return false;
  });
  
  $(".home-main-container #searchInput").focus();
  
  $("body").on("click", ".img-player-play-container", function(){
    var $parent = $(this).parents(".img-thumb-container");
    $parent.replaceWith($parent.data("embed-code"));
  });

  $(document).on("click", ".show_comments a", function(e){
    e.preventDefault();
    var $this = $(this);
    $comments_container = $this.parents(".res-data").find(".comments_container")
    if ( $comments_container.css("display") == "none" ) {
      $comments_container.css({ "display" : "block" });
      
      if ( checkOverflow( $this.parents(".res-data").get(0) ) ) {
        $this.parents(".res-data").find(".res-more").css({ "display" : "block" });
      }
      else {
        $this.parents(".res-data").find(".res-more").css({ "display" : "none" });
      }

      if ( $.trim($comments_container.html()) == "" ) {
        $.ajax({
          url: $this.data("href"),
          dataType : "script"
        });
        return true;
      }
      else {
        return false;
      }
    }
    else {
      $comments_container.css({ "display" : "none" });
      
      if ( checkOverflow( $this.parents(".res-data").get(0) ) ) {
        $this.parents(".res-data").find(".res-more").css({ "display" : "block" });
      }
      else {
        $this.parents(".res-data").find(".res-more").css({ "display" : "none" });
      }
      
      return false;
    }
  });

});
