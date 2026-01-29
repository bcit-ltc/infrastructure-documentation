// Configure Plausible before any dependent scripts load.
window.plausible = window.plausible || function () {
  (window.plausible.q = window.plausible.q || []).push(arguments);
};
window.plausible.o = {
  captureOnLocalhost: false,
  autoCapturePageviews: true,
};
