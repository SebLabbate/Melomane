import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

// Connects to data-controller="typed-js"
export default class extends Controller {
  connect() {
    new Typed(this.element, {
      strings: ["Find gigs", "Make memories", "Reminisce"],
      typeSpeed: 150,
      backspeed: 150,
      loop: true
    })
  }
}
