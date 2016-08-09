EXCEPTION = {}

EXCEPTION.DuplicatedProcedure = do ->
  error = (name) ->
    this.name = 'DuplicatedProcedure'
    this.message = "Duplicated procedure '#{name}'"
  error.prototype = Error.prototype
  error
EXCEPTION.ProcedureNotExist = do ->
  error = (name) ->
    this.name = 'ProcedureNotExist'
    this.message = "'#{name}' procedure not implemented"
  error.prototype = Error.prototype
  error