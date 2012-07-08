@App =
  
  views: {}

  tooltipsVisible: false

  init: ->
    @database = new Database(adapter: 'auto')
    @views.progressView = new ProgressView()
    @tableView = new TableView(model: @database, el: ".fixed-table-container table:first")
    @footerView = new FooterView(model: @database)
    @resizeBody()
    @bind()


  bind: ->
    @tableView.on 'scroll', =>
      @hideTooltips() if @tooltipsVisible

    $(window).on 'resize', => @resizeBody()

    $("#collections li a").on 'click', (e) =>
      e.preventDefault()
      $target = $(e.target)
      $("#collections li").removeClass('active')
      $target.parent('li').addClass('active')
      collection = $(e.target).attr('data-collection')
      @tableView.showLoading()
      @database.find collection, limit: 500, (err, data) => @database.set({data: data})


    $(document).on 'keydown', (e) => 
      switch e.keyCode
        when 27
          e.preventDefault()
          @hideTooltips() 

  
  resizeBody: ->
    $("[data-view=main]").css(height: $(window).height() - 104)


  popover: ($el, options) ->
    @tooltipsVisible = true if options is 'show'
    options.animation ?= false
    $el.popover(options)


  hideTooltips: ->
    @tooltipsVisible = false    
    $('.popover').remove()


$ ->
  App.init()
