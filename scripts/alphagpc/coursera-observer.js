const DEBUG = false;
DEBUG && console.log("alphagpc loading...");

const CONTENT_REGEX = /learn\/.+\/lecture\/.+/;
const QUIZ_REGEX = /(attempt$|view-submission$|view-feedback$)/;
const ASSIGNMENTS_REGEX = /assignments$/;

function setObserver() {
  let lastPathname = location.pathname;
  let debounceTimer = null;

  const observer = new MutationObserver((_mutations) => {
    DEBUG && console.log("MutationObserver triggered");

    const currentPath = location.pathname;

    // Reset on navigation
    if (currentPath !== lastPathname) {
      lastPathname = currentPath;
      clearTimeout(debounceTimer);
    }

    // Debounce: wait 500ms of DOM stability before running
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      // Check if button already exists to prevent duplicates
      if (document.getElementById("download-content") || 
          document.getElementById("download-quiz") ||
          document.getElementById("download-assignments")) {
        return;
      }

      if (CONTENT_REGEX.test(currentPath)) {
        DEBUG && console.log("Content page detected");
        addButtonContent();
      } else if (QUIZ_REGEX.test(currentPath)) {
        DEBUG && console.log("Quiz page detected");
        addButtonQuiz();
      } else if (ASSIGNMENTS_REGEX.test(currentPath)) {
        DEBUG && console.log("Assignments page detected");
        addButtonAssignments();
      }
    }, 500);
  });

  observer.observe(document.body, { childList: true, subtree: true });
}

window.addEventListener("load", () => {
  console.log("alphagpc ready.");
  setObserver();
});
