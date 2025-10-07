console.log('[auto-pdf-title] Loading...');

(function() {
    console.log(`[auto-pdf-title] Title originally: ${document.title}`);

    const topic = document.querySelector('#topicName').textContent;
    document.title = topic;
    console.log(`[auto-pdf-title] Title updated to: ${document.title}`);
})();
