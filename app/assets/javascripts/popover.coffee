@Popover = 
  
  visible: false

  init: -> @bind()

  bind: ->
    app.on 'hide:tooltips', => @hide()
    

  pop: ($el, options) ->
      @visible = true if options is 'show'
      options.animation ?= false
      $el.popover(options)


  hide: ->
    @visible = false    
    $('.popover').remove()


  isVisible: -> @visible



