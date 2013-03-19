@Modal = 
  
  $el: null

  promptTemplate: (data = {}) ->
    data.title ?= ""
    data.body ?= ""
    """
      <div class="modal" id="modal">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">×</button>
          <h3>#{data.title}&nbsp;</h3>
        </div>
        <div class="modal-body">
          <p>#{data.body}</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="btn" data-dismiss="modal" data-action="cancel">#{data.cancel.label}</a>
          <a href="#" class="btn btn-primary" data-action="ok">#{data.ok.label}</a>
        </div>
      </div>
    """


  alertTemplate: (data = {}) ->
    data.title ?= ""
    data.body ?= ""
    """
      <div class="modal" id="modal">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">×</button>
          <h3>#{data.title}&nbsp;</h3>
        </div>        
        <div class="modal-body">
          <p>#{data.body}</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="btn btn-primary" data-action="ok">#{data.ok.label}</a>
        </div>
      </div>
    """


  # Close any modal and remove from DOM
  close: ->
    @$el?.remove()
    $("body").removeClass("modal-open")
    $("body > .modal-backdrop").remove()

  # Show modal prompt with title, message and ok/cancel buttons
  #
  # options - The hash of options
  #   title - The String title
  #   body - The String body for modal body
  #   ok - A hash of options for the 'ok' button
  #     label - The string label for the button
  #     onclick - The callback to run when clicked
  #   cancel - A hash of options for the 'cancel' button
  #     label - the String label for the button
  #     onclick - The callback to run when clicked
  #
  prompt: (options = {}) ->
    options.cancel ?= { label: I18n.t("modals.cancel") }
    options.ok ?= { label: I18n.t("modals.ok") }

    @close()
    @$el = $("<div/>").html(@promptTemplate(options)).modal(backdrop: false)
    $('body').append(@$el)
    @$el.find('[data-action=cancel]').on 'click', (e) =>
      options.cancel.onclick?()
    @$el.find('[data-action=ok]').on 'click', (e) =>
      options.ok.onclick?()      
    @$el.modal('show')


  # Show modal alert with title, message and ok button
  #
  # options - The hash of options
  #   title - The String title
  #   body - The String body for modal body
  #   ok - A hash of options for the 'ok' button
  #     label - The string label for the button
  #     onclick - The callback to run when clicked
  #
  alert: (options = {}) ->
    options.ok ?=
      label: I18n.t("modals.ok")
      onclick: => @close()

    @close()
    @$el = $("<div/>").html(@alertTemplate(options)).modal(backdrop: false)
    $('body').append(@$el)
    @$el.find('[data-action=cancel]').on 'click', (e) =>
      options.cancel.onclick?()
    @$el.find('[data-action=ok]').on 'click', (e) =>
      options.ok.onclick?()      
    @$el.modal('show')


