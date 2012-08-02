class @App extends Backbone.Model
  
  defaults:
    limit: 500


  initialize: ->
    $ =>
      @$main = $("[data-view=main]")
      @$collections = $("ul[data-view=collections]")
      @database = new Database(path: serverExports.app.path)
      @tableView = new TableView(model: @database, el: ".fixed-table-container table:first")
      @progressView = new ProgressView()  
      @footerView = new FooterView(model: @database)
      Popover.init()
      @resizeBody()
      @bind()


  bind: ->
    @tableView.off('scroll').on 'scroll', => 
      Popover.hide() if Popover.isVisible()

    $(window).on 'resize', => @resizeBody()

    @$collections.on 'click', 'li a', (e) =>
      e.preventDefault()
      $target = $(e.target)
      @$collections.find("li").removeClass('active')
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
    @$main.css(height: $(window).height() - 104)

  

  hideTooltips: ->
    app.trigger('hide:tooltips')


  showError: (error) ->
    Modal.alert
      title: I18n.t("modals.error.title")
      body: error
      ok:
        label: I18n.t("modals.ok")
        onclick: => Modal.close()


@app = new App()

