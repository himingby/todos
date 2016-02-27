require './todos-item.html'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Todos } = require '../../api/todos/todos.coffee'

{ setCheckedStatus, updateText, remove } = require '../../api/todos/methods.coffee'

Template.Todos_item.onCreated ->
  @autorun ->
    new SimpleSchema
      todo:
      	type: Todos._helpers
      editing:
        type: Boolean
        optional: yes
      onEditingChange:
      	type: Function
    .validate Template.currentData()


Template.Todos_item.helpers
  checkedClass: (todo) ->
    'checked' if todo.checked

  editingClass: (editing) ->
    'editing' if editing


Template.Todos_item.events
  'change [type=checkbox]': (event) ->
    checked = $(event.target).is(':checked')

    setCheckedStatus.call
      todoId: @todo._id
      newCheckedStatus: checked


  'focus input[type=text]': ->
    @onEditingChange yes


  'blur input[type=text]': ->
    if @editing
      @onEditingChange no


  'keydown input[type=text]': (event) ->
    # ESC or ENTER
    if event.which is 27 or event.which is 13
      event.preventDefault()
      event.target.blur()

  # update the text of the item on keypress but throttle the event to ensure
  # we don't flood the server with updates (handles the event at most once
  # every 300ms)
  'keyup input[type=text]': _.throttle (event) ->
    updateText.call
      todoId: @todo._id
      newText: event.target.value
    , (err) ->
      alert err.error if err? # translate this string after #59
  , 300


  'mousedown .js-delete-item, click .js-delete-item': ->
    remove.call { todoId: @todo._id }, (err) ->
      alert err.error if err? # translate this string after #59
