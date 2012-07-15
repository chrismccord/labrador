class @App extends Backbone.Model
  
  defaults:
    limit: 500

  tooltipsVisible: false

  initialize: ->
    $ =>
      @database = new Database(path: serverExports.app.path)
      @tableView = new TableView(model: @database, el: ".fixed-table-container table:first")
      @progressView = new ProgressView()  
      @footerView = new FooterView(model: @database)
      @resizeBody()
      @bind()


  bind: ->
    @tableView.off('scroll').on 'scroll', =>
      @hideTooltips() if @tooltipsVisible

    $(window).on 'resize', => @resizeBody()

    $("#collections li a").on 'click', (e) =>
      e.preventDefault()
      $target = $(e.target)
      $("#collections li").removeClass('active')
      $target.parent('li').addClass('active')
      collection = $target.attr('data-collection')
      adapter = $target.attr('data-adapter')
      @database.set(adapter: adapter)
      @tableView.showLoading()
      @database.find collection, limit: @get('limit'), (err, data) => @database.set({data: data})

    $(document).on 'keydown', (e) => 
      switch e.keyCode
        when 27
          e.preventDefault()
          @hideTooltips() 

    @database.on 'error', (data) => @showError("Caught error from database: #{data.error}")

  
  resizeBody: ->
    $("[data-view=main]").css(height: $(window).height() - 104)


  popover: ($el, options) ->
    @tooltipsVisible = true if options is 'show'
    options.animation ?= false
    $el.popover(options)


  hideTooltips: ->
    @tooltipsVisible = false    
    $('.popover').remove()


  showError: (error) ->
    console.log error


@app = new App()

