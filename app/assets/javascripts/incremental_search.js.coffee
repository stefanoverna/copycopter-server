$.fn.incrementalSearch = (options) ->
  timeout = undefined
  matchAny = (object, fields, needle) ->
    index = 0

    while index < fields.length
      return true  unless object[fields[index]].toLowerCase().indexOf(needle) is -1
      index++
    false

  matchQuery = (object, fields, needles) ->
    index = 0

    while index < needles.length
      return false  unless matchAny(object, fields, needles[index])
      index++
    true

  renderResults = (filter, missing) =>
    list = $("<ul/>")
    resultCount = 0
    $.each options.items, ->
      if not filter or filter(this)
        list.append options.render(this)
        resultCount += 1

    @html ""
    @append list
    resultCount

  search = (query, onlyMissing) =>
    timeout = null
    $(options.noResults).hide()
    if query is "" and not onlyMissing
      $(options.viewAll).show()
      @html ""
    else
      $(options.viewAll).hide()
      searchTerms = query.toLowerCase().split(" ")
      resultCount = renderResults((item) ->
        matchMissing = if onlyMissing
          !item['draft_content'] or item['draft_content'] == ""
        else
          true

        matchQuery(item, options.search, searchTerms) && matchMissing
      )
      $(options.noResults).show()  if resultCount is 0

  $(options.onlyMissingInput).click -> updateSearch()
  $(options.queryInput).keyup -> updateSearch()

  updateSearch = ->
    queryInput = $(options.queryInput)
    query = if queryInput.is(".prefilled") then "" else queryInput.val()
    missing = $(options.onlyMissingInput).is(':checked')
    clearTimeout timeout  if timeout
    timeout = setTimeout(->
      search(query, missing)
    , 250)

  removeStart = ->
    $(options.queryInput).unbind "focus", removeStart
    $(options.blankSlate).slideUp()
    $(options.searchContainter).removeClass "start", "fast"

  $(options.queryInput).focus removeStart
  $(options.onlyMissingInput).click removeStart

  $(options.viewAll).click ->
    $(this).hide()
    renderResults(false, false)
    false

  $(options.viewMissing).click ->
    $(this).hide()
    renderResults(false, true)
    false

  return @

