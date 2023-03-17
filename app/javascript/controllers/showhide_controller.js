import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="showhide"
export default class extends Controller {
  static targets = ["signup", "button", "login"]

  connect() {
    console.log("Hello from our first Stimulus controller")
  }

  disable() {
    if (this.buttonTarget.innerText === "Sign up") {
      this.buttonTarget.innerText = "Log in";
      } else {
        this.buttonTarget.innerText = "Sign up";
      }

    this.signupTarget.classList.toggle("d-none")
    this.loginTarget.classList.toggle("d-none")
  }
}
