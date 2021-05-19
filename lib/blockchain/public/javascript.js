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

  const INPUTS = ['sender', 'recipient', 'amount'];

  // Perhaps IRL storing addresses in session storage is not desireable.
  // Couldn't make my mind up if it's sensitive like a credit card, but
  // seeing as this is for educational fun, it's definitely more helpful
  // than hurtful. :)

  INPUTS.map(input => {
    let i = document.getElementById(input);

    i.addEventListener("input", function storeValues() {
      sessionStorage.setItem(input, i.value);
    });
  });

  const getStoredForm = () => {
    return {
      sender: sessionStorage.getItem('sender'),
      recipient: sessionStorage.getItem('recipient'),
      amount: sessionStorage.getItem('amount')
     }
  }

  const inputs = getStoredForm();
  for (const input in inputs) {
    if (Object.prototype.hasOwnProperty.call(inputs, input)) {
      document.getElementById(input).value = inputs[input];
      document.getElementById(`${input}Error`).style.display = 'none';
    } else {
      document.getElementById(`${input}Error`).style.display = 'block';
    }
  }

  const makeTransactionSubmit = document.getElementById("makeTransaction");
  makeTransactionSubmit.addEventListener("click", transactionValidation = (e) => {
    let hasAllInputs = false;

    INPUTS.map(input => {
      if (document.getElementById(input).value == '') {
        e.preventDefault();
        document.getElementById(input).focus(); // TODO: Improvement to focus on first error in the form.
        document.getElementById(`${input}Error`).style.display = 'block';
        hasAllInputs = false;
      } else {
        document.getElementById(`${input}Error`).style.display = 'none';
        hasAllInputs = true;
      }
    })

    if (hasAllInputs == true) {
      INPUTS.map(input => {
        sessionStorage.setItem(input, '');
      });
    }

  }, false);
})
