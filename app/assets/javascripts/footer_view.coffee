class @FooterView extends Backbone.View

  el: '[data-view=footer]'

  events:
    'click [data-action=next-page]'     : 'nextPage'
    'click [data-action=prev-page]'     : 'prevPage'
    'click [data-action=refresh]'       : 'refresh'
    'click [data-action=config]'        : 'configure'
    'click [data-action=delete-item]'   : 'deleteItem'
    'click [data-action=create-item]'   : 'createItem'


  initialize: ->
    @cacheSelectors()
    @bind() if app.hasDatabase()


  bind: ->
    @model.on 'change:data', => 
      count = @model.get('data').items.length
      if count is 0
        @updateStatus(I18n.t("status.showing", count: count, results: @resultName(count)))
      else
        @updateStatus("processing #{count} #{@resultName(count)}")


    @model.on 'before:send', (collection, options) => 
      @updateStatus(I18n.t("status.requesting", collection: collection))

    app.tableView.on 'render', =>
      count = @model.get('data').items.length
      @updatePagingState()
      @updateStatus(I18n.t("status.showing", count: count, results: @resultName(count)))

    key 'left', (e) => @prevPage(e)
    key 'right', (e) => @nextPage(e)


  cacheSelectors: ->
    @$refresh = @$("[data-action=refresh]")
    @$nextPage = @$("[data-action=next-page]")
    @$prevPage = @$("[data-action=prev-page]")
    @$status = @$("[data-name=status]")
    @$createItem = @$("[data-action=create-item]")
    @$removeItem = @$("[data-aciton=remove-item]")


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
    e?.preventDefault()
    return if @$prevPage.attr("data-disabled") is "true"
    @model.filterPrevious(skip: @skippedCount() - app.get('limit'))


  nextPage: (e) ->
    e?.preventDefault()
    return if @$nextPage.attr("data-disabled") is "true"
    @model.filterPrevious(skip: @skippedCount() + app.get('limit'))


  refresh: (e) ->
    return if @$refresh.attr("data-disabled") is "true"
    e?.preventDefault()
    app.refreshContext()
    

  skippedCount: -> @model.get('lastFind')?.options.skip ? 0

  resultName: (count) ->
    @model.resultName(count)


  updateStatus: (message) ->
    @$status.text(message)


  configure: (e) ->
    e?.preventDefault()
    $modal = @$('.modal')
    $apply = $modal.find("[data-action=apply]")
    $limit = $modal.find("[data-name=limit]")

    $limit.val(app.get('limit'))
    $modal.modal(backdrop: false)
    $modal.find('form').off('submit').on 'submit', (e) => 
      e?.preventDefault()
      $apply.trigger('click')

    $apply.off('click').on 'click', =>
      app.set(limit: Number($limit.val()))
      $modal.modal('hide')


  createItem: (e) ->
    e?.preventDefault()
    return if @$createItem.attr("data-disabled") is "true"
    Modal.alert
      title: I18n.t('modals.coming_soon')
      body: I18n.t('modals.not_supported')


  deleteItem: (e) ->
    e?.preventDefault()
    return if @$createItem.attr("data-disabled") is "true"
    return unless app.isEditable()
    selectedItem = app.tableView.selectedItem()
    return unless selectedItem?
    primaryKey = selectedItem.get('primaryKeyName')
    id = selectedItem.get('primaryKeyValue')
    Modal.prompt
      title: I18n.t("modals.database.confirm_delete.title")
      body: I18n.t("modals.database.confirm_delete.body", primary_key: primaryKey, id: id)
      ok:
        label: I18n.t("modals.database.confirm_delete.ok")
        onclick: => 
          Modal.close()
          @model.delete @model.collection(), id, => @refresh()
      cancel:
        label: I18n.t("modals.database.confirm_delete.cancel")



  




