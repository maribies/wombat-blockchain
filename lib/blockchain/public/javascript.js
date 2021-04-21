// stolen from "you might not need jQuery"
function ready(fn) {
  if (document.readyState != 'loading')
    fn()
  else
    document.addEventListener('DOMContentLoaded', fn)
}


document.addEventListener("DOMContentLoaded", function(event) {
  for(const link of document.querySelectorAll('a.close[data-closes-selector]')) {
    const selector = link.dataset.closesSelector
    link.addEventListener('click', function() {
      for(const toClose of document.querySelectorAll(selector)) {
        toClose.style.display = 'none'
      }
    })
  }
})
