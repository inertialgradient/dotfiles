const DEBUG = false;
DEBUG && console.log("alphagpc loading...");

function compileQuestion({ title, content }, i, orgLevel, parentNum) {
  let [prompt, ...responses] = content;
  prompt = prompt.value;

  let choices = [];
  if (responses[0].type !== "text_input") {
    choices = responses
      .flatMap((e) => e.choices)
      .map((e) => `- [ ] ${e.value}`);
  }

  const stars = "*".repeat(orgLevel);
  const number = [parentNum, i + 1].filter(Boolean).join(".");
  const header = [`Q${number}`, title].filter(Boolean).join(".");
  return [`${stars} ${header}`, prompt, choices.join("\n")].join("\n\n");
}

function compileQuestionGroup({ title, content, children }, i, orgLevel) {
  let questions = [...children].map((e, j) =>
    compileQuestion(e, j, orgLevel + 1, i + 1),
  );
  const sharedContent = content[0].value;
  const stars = "*".repeat(orgLevel);
  const header = [`Q${i + 1}`, title].filter(Boolean).join(".");
  return [`${stars} ${header}`, sharedContent, questions.join("\n\n")].join(
    "\n\n",
  );
}

function compile(el, i) {
  const orgLevel = 3;
  if (el.type === "QuestionGroup") {
    return compileQuestionGroup(el, i, orgLevel);
  }
  return compileQuestion(el, i, orgLevel);
}

/**
 * Collect all questions on the page, convert to Org, copy to clipboard and log.
 */
function exportQuizAsOrg() {
  var qzSelector = "[data-react-class=OnlineAssignmentSubmitter]";
  var qzObj = JSON.parse(document.querySelector(qzSelector).dataset.reactProps);
  var qzList = Array.from(qzObj.outline);
  var qzQuestions = qzList.map((e, i) => compile(e, i));
  var doc = qzQuestions.join("\n\n");
  navigator.clipboard.writeText(doc);
  console.log(doc);
}

/** Insert the "Copy as Org Doc" button and wire up its click. */
function addButtonQuiz() {
  const btnHtml = `
    <button id="copy-org" class="tiiBtn tiiBtn-primary" type="button">Copy as Org Doc</button>`;
  const headerEl = document.querySelector("h1.onlineAssignment--title");
  if (headerEl && !document.getElementById("copy-org")) {
    headerEl.insertAdjacentHTML("afterend", btnHtml);
    document
      .getElementById("copy-org")
      .addEventListener("click", exportQuizAsOrg);
  }
}

window.addEventListener("load", () => {
  console.log("alphagpc ready.");
  addButtonQuiz();
});
