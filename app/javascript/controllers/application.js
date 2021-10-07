import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.warnings = true
application.debug = true
window.Stimulus = application

Stimulus.handleError = (error, message, detail) => {
  console.warn(message, detail)
  ErrorTrackingSystem.captureException(error)
}

export { application }
