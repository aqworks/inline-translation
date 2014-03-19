class Translation
  k:
    backspace:  8
    enter:      13
    shift:      16
    ctrl:       17
    leftArrow:  37
    upArrow:    38
    rightArrow: 39
    downArrow:  40
    t:          84

  currentEl: 0
  keys: {}
  mode: "HYBRID"
  arrowPressed: false

  constructor: ->
    # console.log "Initializing translation UI..."
    @canvas = $('#translation')
    @canvas.swipe(
      swipeLeft:  @switchHybrid
      swipeRight: @switchTranslate
    )
    $(document).swipe(
      swipeLeft:  @switchHybrid
      swipeRight: @switchTranslate
    )
    @canvas.bind('mousedown', @mouseDownHandler)
    @canvas.bind('mouseup', @mouseUpHandler)
    @canvas.bind('click', @clickHandler)
    @canvas.bind('keydown', @keyDownHandler)
    @canvas.bind('keyup', @keyUpHandler)

  #
  # Event handlers
  #
  mouseDownHandler: (e) =>
    # console.log "[event] mousedown"
    pos = @getSelectionPosition()
    if pos < 0
      # console.log("Setting all contenteditable to FALSE")
      _.each($('[contenteditable="true"]'), (element) ->
        $(element).attr('contenteditable', false)
      )

  mouseUpHandler: (e) =>
    # console.log "[event] mouseup"
    pos = @getSelectionPosition()
    if pos > -1
      # console.log("Setting all contenteditable to TRUE")
      _.each($('[contenteditable="false"]'), (element) ->
        $(element).attr('contenteditable', true)
      )

  clickHandler: (e) =>
    # console.log "[event] click"
    # This seems to do nothing?
    _.each($('[contenteditable="true"]'), (element) ->
      $(element).attr('contenteditable', false)
    )
    pos = @getSelectionPosition()
    section = $(@getSelectedNode())
    if section.hasClass('editable')
      # console.log "This section is editable!"
      section.attr('contenteditable', true)
    else if pos > -1
      editedWrapper = $('<p class="edited"></p>')

      editableElement = $('<p class="editable edit_' + @currentEl + '" contenteditable="true">&nbsp;</p>')
      content = section.html()
      beforeSegment = '<span class="segment" contenteditable="true">' + content.substr(0, pos) + '</span>'
      afterSegment = '<span class="segment2" contenteditable="true">' + content.substr(pos) + '</span>'

      if section.is('p.unedited')
        editedWrapper.html(editableElement)
        editedWrapper.prepend(beforeSegment)
        editedWrapper.append(afterSegment)
        section.after(editedWrapper)
      else
        section.after(editableElement)
        editableElement.before(beforeSegment)
        editableElement.after(afterSegment)
      section.remove()

      editableElement.focus()
      editableElement.blur( (e) =>
        @cleanUpEditable(e.delegateTarget)
      )

  keyDownHandler: (e) =>
    # console.log "[event] keyDown"
    @keys[e.which] = true
    @checkKeys(e)

    if e.which is @k.backspace
      unless $(@getSelectedNode()).hasClass('editable')
        e.preventDefault()
    # unless @arrowPressed
    #   unless $(document.activeElement).hasClass('editable')
    #     section = $(@getSelectedNode())
    #     pos = @getSelectionPosition
    #     # if section.hasClass('editable')
    #     #   console.log "This section is editable!"
    #     #   # Forgot what I need this for
    #     # else if pos > -1
    #     if pos > -1
    #       editedWrapper = $('<p class="edited"></p>')

    #       editableElement = $('<p class="editable edit_' + @currentEl + '" contenteditable="true">&nbsp;</p>')
    #       content = section.html()
    #       beforeSegment = '<span class="segment" contenteditable="true">' + section.html().substr(0, pos) + '</span>'
    #       afterSegment = '<span class="segment2" contenteditable="true">' + section.html().substr(pos) + '</span>'
    #       # if section.is('p.unedited')
    #       #   editableElement.wrap('<p class="edited"></p>').prepend(beforeSegment).append(afterSegment)
    #       # else

    #       if section.is('p.unedited')
    #         editedWrapper.html(editableElement)
    #         editedWrapper.prepend(beforeSegment)
    #         editedWrapper.append(afterSegment)
    #         section.after(editedWrapper)
    #       else
    #         editableElement.before(beforeSegment)
    #         editableElement.after(afterSegment)
    #         section.after(editableElement)
    #       section.remove()

    #       editableElement.focus()
    #       editableElement.blur( (e) =>
    #         @cleanUpEditable(e.delegateTarget)
    #       )

  keyUpHandler: (e) =>
    # console.log "[event] keyUp"
    delete @keys[e.which]

  #
  # Utility functions
  #
  cleanUpEditable: (el) =>
    # Check if blank line
    prevEl = $(el).prev()
    nextEl = $(el).next()
    if nextEl.text().length == 0 and prevEl.text().length == 0 and $(el).text().length <= 1
      prevEl.before('<div class="spacer"></div>')
      prevEl.remove()
      nextEl.remove()
    $(el).remove() if $(el).text().length <= 1
    @currentEl++

  checkKeys: (e) ->
    that = this
    k = that.k

    keys = that.keys
    that.arrowPressed = _.has(keys, k.leftArrow) or _.has(keys, k.rightArrow) or _.has(keys, k.upArrow) or _.has(keys, k.downArrow)

    editableElement = $('.edit_' + that.currentEl)

    if _.has(keys, k.enter) and editableElement.text().length <= 1
      e.preventDefault()
      editableElement.append('<br class="extra" /><br class="extra" />')
    if _.has(keys, k.shift) and _.has(keys, k.ctrl) and _.has(keys, k.t)
      if that.mode == "HYBRID"
        that.switchHybrid()
      else
        that.switchTranslate()

  switchTranslate: ->
    @canvas.removeClass('translation')
    @canvas.addClass('hybrid')
    delete @keys[@k.t]
    @mode = "HYBRID"

  switchHybrid: ->
    @canvas.removeClass('hybrid')
    @canvas.addClass('translation')
    delete @keys[@k.t]
    @mode = "TRANSLATION"

  getSelectedNode: ->
    target = null
    if window.getSelection
      target = window.getSelection().getRangeAt(0).commonAncestorContainer
      if target.nodeType == 1
        return target
      else
        return target.parentNode
    else if document.selection
      target = document.selection.createRange().parentElement()
    return target

  getSelectionPosition: ->
    selection = window.getSelection()
    if selection.focusOffset != selection.anchorOffset
      return -1
    else
      return selection.focusOffset

$ ->
  window.translation = new Translation
