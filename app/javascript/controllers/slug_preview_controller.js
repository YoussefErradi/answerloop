import { Controller } from "@hotwired/stimulus"
import { slugifyPreview } from "utils/slugify"

// Preview only. Rails generates the authoritative slug with a unique suffix.
export default class extends Controller {
  static targets = ["name", "preview"]

  update() {
    this.previewTarget.textContent = slugifyPreview(this.nameTarget.value)
  }
}
