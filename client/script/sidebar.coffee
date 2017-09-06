toggleSidebar = ->

window.addLoadListener ->

  body = document.querySelector('body')

  showSidebar = false;

  toggleSidebar = ->
    if showSidebar
      showSidebar = false
      body.classList.remove 'show-sidebar'
    else
      showSidebar = true
      body.classList.add 'show-sidebar'
