import test from "node:test"
import assert from "node:assert/strict"
import { slugifyPreview } from "../../app/javascript/utils/slugify.js"

test("creates readable lowercase slugs", () => {
  assert.equal(slugifyPreview("Acme Support Desk"), "acme-support-desk")
})

test("handles accents and blank names", () => {
  assert.equal(slugifyPreview("Équipe & Support"), "equipe-support")
  assert.equal(slugifyPreview("  "), "your-workspace")
})

test("never uses unsafe URL characters", () => {
  assert.equal(slugifyPreview("Space / # Example!"), "space-example")
})
