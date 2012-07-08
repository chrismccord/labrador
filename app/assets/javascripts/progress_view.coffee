class @ProgressView extends Backbone.View
  
  el: "#find-progress"

  initialize: (attributes = {}) ->
    @$bar = @$el.find(".bar")


  show: (percentage) -> 
    @$bar.css(width: "#{percentage}%") if percentage?


  hide: ->
    @$bar.css(width: "0%")