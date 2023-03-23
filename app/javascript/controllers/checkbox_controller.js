import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox"
export default class extends Controller {
  static targets = ["parent" , "child"]

  connect() {
    // console.log("Stimulus is connected !")
    this.parentTarget.hidden = false
    this.childTargets.map(x => x.checked = false)
  }

  toggleChildren() {
    if (this.parentTarget.checked) {
      this.childTargets.map(x => x.checked = true)
    } else {
      this.childTargets.map(x => x.checked = false)
    }
  }

  toggleParent(e) {
    // e.preventDefault()
    const id = e.target.dataset.id
    const csrfToken = document.querySelector("[name='csrf-token']").content
    if (this.childTargets.map(x => x.checked).includes(false)) {
      this.parentTarget.checked = false
    } else {
      this.parentTarget.checked = true
    }
    fetch(`/user_gigs/${id}/toggle`, {
      method: 'POST',
      mode: 'cors',
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ "attended": e.target.checked })
    })
      .then(response => response.text())
      .then(data => {
        alert(data.message)
      })
    console.log(e.target.checked);
    }
  }

  // this.childTargets.map(x => x.checked)
  // console.log(this.childTargets.map(x => x.checked).includes(false));

// https://stimulus.hotwired.dev/handbook/managing-state
// https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e
