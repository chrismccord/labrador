class @FooterView extends Backbone.View

  el: '[data-view=footer]'

  events:
    'click [data-action=next-page]'     : 'nextPage'
    'click [data-action=prev-page]'     : 'prevPage'
    'click [data-action=refresh]'       : 'refresh'


  initialize: ->
    @model.on 'change:data', => 
      @updateStatus("processing #{@model.get('data').items.length} results")
    
    @model.on 'before:send', => @updateStatus('requesting...')

    App.tableView.on 'render', => 
      @updateStatus("showing #{@model.get('data').items.length} results")


  prevPage: (e) ->
    e.preventDefault()
    skipped = @model.get('lastFind')?.options.skip ? 0
    @model.filterPrevious(skip: skipped - @model.defaults.limit)


  nextPage: (e) ->
    e.preventDefault()
    skipped = @model.get('lastFind')?.options.skip ? 0
    @model.filterPrevious(skip: skipped + @model.defaults.limit)


  refresh: (e) ->
    e.preventDefault()
    @model.filterPrevious()
    

  updateStatus: (message) ->
    @$("[data-name=status]").text(message)