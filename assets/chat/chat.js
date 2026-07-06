/*  chat.js — Mentova Chat Client-Side Logic

    Handles sending messages, showing replies, justifications, mentor
    sign-in, teaching, and the review queue.

    No external dependencies.  Works with both index.html and mentor.html.
*/

'use strict';

// MentovaChat is the single public namespace for this script.
var MentovaChat = (function () {

  // sessionId is generated once per page load.
  var sessionId = 'sess_' + Date.now() + '_' + Math.random().toString(36).slice(2);

  // tier is set by MentovaChat.init.
  var tier = 'public';

  // token holds the mentor session token after sign-in.
  var token = sessionStorage.getItem('mc_token') || '';

  // ------------------------------------------------------------------
  // init — entry point called by the page
  // ------------------------------------------------------------------

  // init(options) sets up event listeners based on which page is loaded.
  function init(options) {
    // Store the tier from the options object.
    tier = (options && options.tier) || 'public';

    // Wire up the chat form send button.
    var form = document.getElementById('mc-form');
    if (form) {
      form.addEventListener('submit', function (e) {
        e.preventDefault();
        var input = document.getElementById('mc-input');
        var text = input.value.trim();
        if (!text) return;
        input.value = '';
        sendMessage(text);
      });
    }

    // On the mentor tier, wire up sign-in and teach forms.
    if (tier === 'mentor') {
      setupMentorPage();
    }
  }

  // ------------------------------------------------------------------
  // sendMessage — post a message and display the reply
  // ------------------------------------------------------------------

  // sendMessage(text) sends a public chat message to the server.
  function sendMessage(text) {
    // Display the visitor's message in the chat history immediately.
    appendMessage('You', text, 'person', '', '', '');

    // Build the request body.
    var body = JSON.stringify({ message: text, session_id: sessionId });

    // Send the message to the server.
    fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: body
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
      // Display Mentova's reply with emotional and linguistic prosody cues.
      appendMessage(
        'Mentova',
        data.reply,
        'mentova',
        data.justification,
        data.focus_word,
        data.emotional_prosody,
        data.linguistic_prosody
      );
    })
    .catch(function () {
      // Display a system error message.
      appendMessage('Mentova', 'Something on my side is not working right now. Please try again shortly.', 'mentova', '', '', 'neutral');
    });
  }

  // ------------------------------------------------------------------
  // appendMessage — add one message bubble to the chat history
  // ------------------------------------------------------------------

  // appendMessage builds and inserts a message element.
  function appendMessage(speaker, text, role, justification, focusWord, tone, linguisticProsody) {
    // Get the chat history container.
    var history = document.getElementById('mc-history');
    if (!history) return;

    // Create the outer message container.
    var bubble = document.createElement('div');
    bubble.className = 'mc-bubble mc-bubble--' + role;

    // Create the speaker label.
    var label = document.createElement('span');
    label.className = 'mc-speaker';
    label.textContent = speaker + ':';
    bubble.appendChild(label);

    // Create the message text, applying focus-word small-caps if present.
    var msg = document.createElement('span');
    msg.className = 'mc-text';
    if (focusWord && focusWord !== '') {
      // Replace the focused word with a small-caps span.
      var parts = text.split(new RegExp('(' + escapeRegex(focusWord) + ')', 'i'));
      parts.forEach(function (part) {
        if (part.toLowerCase() === focusWord.toLowerCase()) {
          var em = document.createElement('span');
          em.className = 'mc-focus';
          em.textContent = part;
          msg.appendChild(em);
        } else {
          msg.appendChild(document.createTextNode(part));
        }
      });
    } else {
      msg.textContent = text;
    }
    bubble.appendChild(msg);

    // Add a tone indicator badge if the tone is not neutral.
    if (tone && tone !== 'neutral' && tone !== '') {
      var toneBadge = document.createElement('span');
      toneBadge.className = 'mc-tone mc-tone--' + tone;
      toneBadge.textContent = tone;
      bubble.appendChild(toneBadge);
    }

    // Add linguistic prosody annotation for Mentova messages.
    if (role === 'mentova' && linguisticProsody) {
      var lpParts = [];
      if (linguisticProsody.speech_act && linguisticProsody.speech_act !== 'statement') {
        lpParts.push(linguisticProsody.speech_act);
      }
      if (linguisticProsody.certainty && linguisticProsody.certainty !== 'neutral') {
        lpParts.push(linguisticProsody.certainty);
      }
      if (linguisticProsody.politeness && linguisticProsody.politeness !== 'neutral') {
        lpParts.push(linguisticProsody.politeness);
      }
      if (linguisticProsody.inarticulate && linguisticProsody.inarticulate !== 'none') {
        lpParts.push('hesitant');
      }
      if (lpParts.length > 0) {
        var lpBadge = document.createElement('span');
        lpBadge.className = 'mc-lp-badge';
        lpBadge.textContent = lpParts.join(' · ');
        bubble.appendChild(lpBadge);
      }
    }

    // Add a Why? link if there is a justification or for Mentova messages.
    if (role === 'mentova') {
      var whyLink = document.createElement('button');
      whyLink.className = 'mc-why-btn';
      whyLink.textContent = 'Why?';
      // Store the justification text as a data attribute.
      whyLink.setAttribute('data-just', justification || '');
      whyLink.setAttribute('data-query', text);
      // Wire the click handler.
      whyLink.addEventListener('click', function () {
        toggleJustification(bubble, whyLink);
      });
      bubble.appendChild(whyLink);
    }

    // Append the bubble to the history.
    history.appendChild(bubble);
    // Scroll to the latest message.
    history.scrollTop = history.scrollHeight;
  }

  // ------------------------------------------------------------------
  // toggleJustification — show or hide the justification panel
  // ------------------------------------------------------------------

  // toggleJustification shows or hides the justification for a message.
  function toggleJustification(bubble, btn) {
    // Check whether a justification panel already exists in this bubble.
    var existing = bubble.querySelector('.mc-just-panel');
    if (existing) {
      // Toggle visibility.
      existing.hidden = !existing.hidden;
      return;
    }

    // Create the justification panel element.
    var panel = document.createElement('div');
    panel.className = 'mc-just-panel';

    // Use the stored justification if present.
    var stored = btn.getAttribute('data-just');
    if (stored && stored !== '') {
      panel.textContent = stored;
      bubble.appendChild(panel);
      return;
    }

    // Otherwise fetch the justification from the server.
    var query = btn.getAttribute('data-query');
    panel.textContent = 'Loading...';
    bubble.appendChild(panel);

    fetch('/api/why?query=' + encodeURIComponent(query))
    .then(function (res) { return res.json(); })
    .then(function (data) {
      panel.textContent = data.explanation || 'I cannot show you a reason for that, so I should not claim it.';
    })
    .catch(function () {
      panel.textContent = 'Could not load justification.';
    });
  }

  // ------------------------------------------------------------------
  // Mentor page setup
  // ------------------------------------------------------------------

  // setupMentorPage wires up the mentor sign-in, teach, and queue UI.
  function setupMentorPage() {
    // If already signed in, show the workspace immediately.
    if (token) {
      showWorkspace();
    }

    // Wire the sign-in form.
    var signinForm = document.getElementById('mc-signin-form');
    if (signinForm) {
      signinForm.addEventListener('submit', function (e) {
        e.preventDefault();
        var username = document.getElementById('mc-username').value.trim();
        var password = document.getElementById('mc-password').value;
        mentorLogin(username, password);
      });
    }

    // Wire the sign-out button.
    var signoutBtn = document.getElementById('mc-signout-btn');
    if (signoutBtn) {
      signoutBtn.addEventListener('click', mentorLogout);
    }

    // Wire the teach form.
    var teachForm = document.getElementById('mc-teach-form');
    if (teachForm) {
      teachForm.addEventListener('submit', function (e) {
        e.preventDefault();
        var factInput = document.getElementById('mc-teach-input');
        var fact = factInput.value.trim();
        if (!fact) return;
        factInput.value = '';
        mentorTeach(fact);
      });
    }

    // Wire the refresh queue button.
    var refreshBtn = document.getElementById('mc-refresh-queue-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', refreshQueue);
    }
  }

  // ------------------------------------------------------------------
  // mentorLogin — authenticate and obtain a session token
  // ------------------------------------------------------------------

  // mentorLogin(user, pass) posts credentials and stores the token.
  function mentorLogin(username, password) {
    fetch('/api/mentor/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: username, password: password })
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
      if (data.ok) {
        // Store the token in sessionStorage for this browser tab.
        token = data.token;
        sessionStorage.setItem('mc_token', token);
        showWorkspace(username);
      } else {
        // Show the error message on the sign-in form.
        var err = document.getElementById('mc-signin-error');
        if (err) {
          err.textContent = data.error || 'Sign-in failed.';
          err.hidden = false;
        }
      }
    })
    .catch(function () {
      var err = document.getElementById('mc-signin-error');
      if (err) {
        err.textContent = 'Network error. Please try again.';
        err.hidden = false;
      }
    });
  }

  // ------------------------------------------------------------------
  // mentorLogout — revoke the session token
  // ------------------------------------------------------------------

  // mentorLogout posts the token to the logout endpoint and hides the workspace.
  function mentorLogout() {
    fetch('/api/mentor/logout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: token })
    })
    .finally(function () {
      // Clear the stored token regardless of server response.
      token = '';
      sessionStorage.removeItem('mc_token');
      // Hide the workspace and show the sign-in panel.
      hideWorkspace();
    });
  }

  // ------------------------------------------------------------------
  // mentorTeach — propose a fact for the review queue
  // ------------------------------------------------------------------

  // mentorTeach(fact) posts a proposed fact to the server.
  function mentorTeach(fact) {
    var statusEl = document.getElementById('mc-teach-status');
    fetch('/api/mentor/teach', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: token, fact: fact, session_id: sessionId })
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
      if (statusEl) {
        statusEl.hidden = false;
        if (data.ok) {
          statusEl.textContent = 'Proposed (Queue ID ' + data.queue_id + '). Awaiting approval before entering the knowledge base.';
          statusEl.className = 'mc-status mc-status--ok';
          // Refresh the queue list.
          refreshQueue();
        } else {
          statusEl.textContent = data.error || 'Proposal failed.';
          statusEl.className = 'mc-status mc-status--err';
        }
      }
    })
    .catch(function () {
      if (statusEl) {
        statusEl.hidden = false;
        statusEl.textContent = 'Network error.';
        statusEl.className = 'mc-status mc-status--err';
      }
    });
  }

  // ------------------------------------------------------------------
  // mentorApprove — approve a queued proposal
  // ------------------------------------------------------------------

  // mentorApprove(queueId) sends an approve request to the server.
  function mentorApprove(queueId) {
    fetch('/api/mentor/approve', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: token, queue_id: queueId })
    })
    .then(function (res) { return res.json(); })
    .then(function (data) {
      if (data.ok) {
        // Refresh the queue list after approval.
        refreshQueue();
      } else {
        alert(data.error || 'Approval failed.');
      }
    });
  }

  // ------------------------------------------------------------------
  // refreshQueue — reload the pending queue from the server
  // ------------------------------------------------------------------

  // refreshQueue fetches the current queue and renders it.
  function refreshQueue() {
    fetch('/api/mentor/queue?token=' + encodeURIComponent(token))
    .then(function (res) { return res.json(); })
    .then(function (data) {
      renderQueue(data.proposals || []);
    })
    .catch(function () {
      var list = document.getElementById('mc-queue-list');
      if (list) list.textContent = 'Could not load queue.';
    });
  }

  // ------------------------------------------------------------------
  // renderQueue — display queue entries
  // ------------------------------------------------------------------

  // renderQueue(proposals) renders the list of pending proposals.
  function renderQueue(proposals) {
    var list = document.getElementById('mc-queue-list');
    if (!list) return;
    list.innerHTML = '';
    if (proposals.length === 0) {
      list.textContent = 'No pending proposals.';
      return;
    }
    proposals.forEach(function (p) {
      // Create a queue entry element.
      var entry = document.createElement('div');
      entry.className = 'mc-queue-entry';

      // Show the proposal text and metadata.
      var info = document.createElement('span');
      info.className = 'mc-queue-fact';
      info.textContent = '[' + p.id + '] ' + p.fact + ' (proposed ' + p.created_at + ')';
      entry.appendChild(info);

      // Add an approve button for each entry.
      var approveBtn = document.createElement('button');
      approveBtn.className = 'mc-btn-approve';
      approveBtn.textContent = 'Approve';
      approveBtn.addEventListener('click', (function (id) {
        return function () { mentorApprove(id); };
      })(p.id));
      entry.appendChild(approveBtn);

      list.appendChild(entry);
    });
  }

  // ------------------------------------------------------------------
  // showWorkspace / hideWorkspace
  // ------------------------------------------------------------------

  // showWorkspace hides the sign-in panel and shows the mentor workspace.
  function showWorkspace(username) {
    var signin = document.getElementById('mc-signin-panel');
    var workspace = document.getElementById('mc-workspace');
    var label = document.getElementById('mc-signed-in-as');
    if (signin) signin.hidden = true;
    if (workspace) workspace.hidden = false;
    if (label && username) label.textContent = 'Signed in as: ' + username;
    // Load the initial queue.
    refreshQueue();
  }

  // hideWorkspace shows the sign-in panel and hides the mentor workspace.
  function hideWorkspace() {
    var signin = document.getElementById('mc-signin-panel');
    var workspace = document.getElementById('mc-workspace');
    if (signin) signin.hidden = false;
    if (workspace) workspace.hidden = true;
  }

  // ------------------------------------------------------------------
  // Utility
  // ------------------------------------------------------------------

  // escapeRegex escapes special characters in a string for use in RegExp.
  function escapeRegex(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  // ------------------------------------------------------------------
  // Public API
  // ------------------------------------------------------------------

  return {
    init: init,
    sendMessage: sendMessage,
    mentorLogin: mentorLogin,
    mentorLogout: mentorLogout,
    mentorTeach: mentorTeach,
    mentorApprove: mentorApprove
  };

}());
