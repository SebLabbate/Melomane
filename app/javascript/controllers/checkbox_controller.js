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

  toggleParent() {
    if (this.childTargets.map(x => x.checked).includes(false)) {
      this.parentTarget.checked = false
    } else {
      this.parentTarget.checked = true
    }
    // this.childTargets.map(x => x.checked)
    // console.log(this.childTargets.map(x => x.checked).includes(false));
  }
}


// https://stimulus.hotwired.dev/handbook/managing-state
// https://gist.github.com/mrmartineau/a4b7dfc22dc8312f521b42bb3c9a7c1e
