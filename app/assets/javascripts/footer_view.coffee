class @FooterView extends Backbone.View

  el: '[data-view=footer]'

  events:
    'click [data-action=next-page]'     : 'nextPage'
    'click [data-action=prev-page]'     : 'prevPage'
    'click [data-action=refresh]'       : 'refresh'


  initialize: ->
    @cacheSelectors()
    @bind()


  bind: ->
    @model.on 'change:data', => 
      count = @model.get('data').items.length
      if count is 0
        @updateStatus(I18n.t("status.showing", count: count, results: @resultName(count)))
      else
        @updateStatus("processing #{count} #{@resultName(count)}")


    @model.on 'before:send', (collection, options) => 
      @updateStatus(I18n.t("status.requesting", collection: collection))

    App.tableView.on 'render', =>
      count = @model.get('data').items.length
      @updatePagingState()
      @updateStatus(I18n.t("status.showing", count: count, results: @resultName(count)))


  cacheSelectors: ->
    @$nextPage = @$("[data-action=next-page]")
    @$prevPage = @$("[data-action=prev-page]")
    @$status = @$("[data-name=status]")


  updatePagingState: ->
    count = @model.get('data').items.length
    limit = @model.get('lastFind').options.limit
    @$prevPage.removeAttr("data-disabled")
    @$nextPage.removeAttr("data-disabled")
    if count is 0
      @$prevPage.attr("data-disabled", true) if @skippedCount() is 0
      @$nextPage.attr("data-disabled", true)
    else if count < limit
      @$nextPage.attr("data-disabled", true)
    if @skippedCount() is 0
      @$prevPage.attr("data-disabled", true)


  prevPage: (e) ->
    e.preventDefault()
    return if @$prevPage.attr("data-disabled") is "true"
    @model.filterPrevious(skip: @skippedCount() - @model.defaults.limit)


  nextPage: (e) ->
    e.preventDefault()
    return if @$nextPage.attr("data-disabled") is "true"
    @model.filterPrevious(skip: @skippedCount() + @model.defaults.limit)


  refresh: (e) ->
    e.preventDefault()
    @model.filterPrevious()
    

  skippedCount: -> @model.get('lastFind')?.options.skip ? 0
  resultName: (count) ->
    @model.resultName(count)

  updateStatus: (message) ->
    @$status.text(message)

