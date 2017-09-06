window.addLoadListener = (func)->
  oldonload = window.onload;
  if (typeof oldonload isnt 'function')
    window.onload = func;
  else
    window.onload = ()->
      oldonload();
      func();
