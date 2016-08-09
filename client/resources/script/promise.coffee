synck = (chain) ->
  chain and chain.hold()
  has_success = false
  has_error = false
  success = []
  error = []
  data = undefined

  invoke = (callback) ->
    callback.apply {}, data

  instance = 
    success: (callback) ->
      if has_error
        return this
      if has_success
        invoke callback
        return this
      success.push callback
      this
    error: (callback) ->
      if has_error
        invoke callback
        return this
      if has_success
        return this
      error.push callback
      this
    always: (callback) ->
      if has_error or has_success
        invoke callback
        return this
      error.push callback
      success.push callback
      this
    resolve: ->
      has_success = true
      data = arguments
      #invoke callbacks before leave chain
      success.forEach invoke
      instance.close()
      this
    failure: ->
      has_error = true
      data = arguments
      #invoke callbacks before leave chain
      error.forEach invoke
      instance.close true
      this
    bind_error: (other) ->
      @error ->
        other.failure arguments
        return
      this
    bind_success: (other) ->
      @success ->
        other.resolve arguments
        return
      this
    close: (with_error) ->
      chain and chain.leave(with_error)
      @resolve =
      @failure = ->
        console.log 'WARNING: promise has end'
        return
      return
  instance
  
resolved = (result)->
  args = Array.prototype.slice.call(arguments, 1)
  instance =
    success: (callback)->
      if result
        callback.apply(window, args)
      instance
    error: (callback)->
      if not result
        callback.apply(window, args)
      instance
    always: (callback)->
      callback.apply(window, args)
      instance
  instance
  
link = ->
  requests = 0
  success = []
  error = []
  always = []
  has_error = undefined

  call_all = (callbacks) ->
    callbacks.forEach (callback) ->
      callback()
      return
    return

  instance = 
    subscribe: (promise) ->
      instance.hold()
      promise.success(instance.leave()).error instance.leave(true)
      return
    hold: ->
      requests += 1
      return
    call_leave: (error) ->
      ->
        instance.leave error
        return
    leave: (with_error) ->
      has_error = has_error or with_error
      requests -= 1
      if requests == 0
        call_all !has_error and success or error
        call_all always

        instance.hold = ->
          console.log 'trying to hold blocked link'
          return

        success = error = always = []
      return
    success: (callback) ->
      if !has_error
        if requests == 0
          callback()
        else
          success.push callback
      this
    error: (callback) ->
      if requests == 0
        has_error and callback(has_error)
      else
        error.push callback
      this
    always: (callback) ->
      if requests == 0
        callback has_error
      else
        always.push callback
      this
  instance
