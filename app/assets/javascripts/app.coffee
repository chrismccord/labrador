class @App extends Backbone.Model
  
  KEYS:
    ESCAPE: 27

  defaults:
    limit: 250
    context: 'content'

  initialize: ->
    $ =>
      @$main = $("[data-view=main]")
      @$collections = $("ul[data-view=collections]")
      if @hasDatabase()
        @database = new Database(path: @path())
        @tableView = new TableView(model: @database, el: ".fixed-table-container table:first")
        @progressView = new ProgressView()  
      @headerView = new HeaderView()
      @footerView = new FooterView(model: @database)
      Popover.init()
      Session.init()
      @resizeBody()
      @bind()


  hasDatabase: -> serverExports?.app?

  path: -> 
    return unless @hasDatabase()
    serverExports.app.path


  bind: ->
    $(window).on 'resize', => @resizeBody()
    @bindTable()
    @bindDatabase()
    @bindCollections()

    $(document).on 'keydown', (e) => 
      switch e.keyCode
        when @KEYS.ESCAPE
          e.preventDefault()
          @hideTooltips() 


  bindCollections: ->
    return unless @hasDatabase()
    @$collections.on 'click', 'li a', (e) =>
      e.preventDefault()
      $target = $(e.target)
      @$collections.find("li").removeClass('active')
      $target.parent('li').addClass('active')
      collection = $target.attr('data-collection')
      adapter = $target.attr('data-adapter')
      @database.set(adapter: adapter)
      @tableView.showLoading()
      @showContext(collection)
  
  bindTable: ->
    return unless @tableView?
    @tableView.off('scroll').on 'scroll', => Popover.hide() if Popover.isVisible()


  bindDatabase: ->
    return unless @database?
    @database.on 'error', (data) => @showError("Caught error from database: #{data.error}")


  resizeBody: ->
    @$main.css(height: $(window).height() - 104)


  hideTooltips: ->
    app.trigger('hide:tooltips')


  showSchema: (collection) ->
    collection ?= @database.collection()
    @set(context: 'schema')
    return unless @hasDatabase() and collection?

    @database.schema collection, (error, data) => @database.set({data})


  showContent: (collection) ->
    collection ?= @database.collection()
    @set(context: 'content')
    return unless @hasDatabase() and collection?

    @database.find collection, limit: @get('limit'), (err, data) => @database.set({data: data})


  refreshContext: ->
    collection = @database.collection()
    switch @get('context')
      when "schema"  then @showSchema(collection)
      when "content" then @showContent(collection)


  showContext: (collection) ->
    switch @get('context')
      when "schema"  then @showSchema(collection)
      when "content" then @showContent(collection)

  
  isEditable: ->
    return false unless @database.collection()?
    switch @get('context')
      when "schema"  then false
      when "content" then true


  showError: (error) ->
    Modal.alert
      title: I18n.t("modals.error.title")
      body: error
      ok:
        label: I18n.t("modals.ok")
        onclick: => Modal.close()


@app = new App()

