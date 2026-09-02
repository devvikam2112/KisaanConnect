(function() {
    'use strict';

    document.addEventListener('DOMContentLoaded', () => {
        // Inject widget HTML
        const widgetHtml = `
            <div id="aiAssistantContainer" style="position: fixed; bottom: 24px; right: 24px; z-index: 1050; font-family: var(--kc-font, sans-serif);">
                <!-- Floating Launcher Button -->
                <button id="aiLauncherBtn" class="btn btn-primary rounded-pill shadow-lg d-flex align-items-center gap-2 px-3 py-2"
                        style="background: linear-gradient(135deg, #15803D 0%, #166534 100%); border: 2px solid #FFFFFF; box-shadow: 0 10px 25px -5px rgba(21, 128, 61, 0.4); transition: transform 0.2s ease;"
                        title="Open KisaanConnect AI Assistant">
                    <i class="fa-solid fa-headset fs-5 text-white"></i>
                    <span class="fw-bold text-white small d-none d-sm-inline">AI Assistant</span>
                </button>

                <!-- Chat Panel Container -->
                <div id="aiChatCard" class="card shadow-lg border-0 rounded-4" 
                     style="display: none; position: absolute; bottom: 65px; right: 0; width: 360px; max-width: calc(100vw - 32px); height: 480px; overflow: hidden; background: #FFFFFF; border: 1px solid #E2E8F0; box-shadow: 0 20px 35px -5px rgba(0, 0, 0, 0.15);">
                    
                    <!-- Header -->
                    <div class="card-header py-3 px-3 d-flex justify-content-between align-items-center text-white"
                         style="background: linear-gradient(135deg, #0F291E 0%, #15803D 100%); border-bottom: 1px solid rgba(255,255,255,0.1);">
                        <div class="d-flex align-items-center gap-2">
                            <div style="width: 32px; height: 32px; border-radius: 50%; background: rgba(255,255,255,0.15); display: flex; align-items: center; justify-content: center;">
                                <i class="fa-solid fa-robot text-white fs-6"></i>
                            </div>
                            <div>
                                <div class="fw-bold small lh-1 text-white">KisaanConnect AI</div>
                                <span class="badge bg-success-subtle text-success border border-success-subtle p-0 px-1 mt-1" style="font-size: 10px;">● Marketplace Guide</span>
                            </div>
                        </div>
                        <button type="button" id="aiCloseBtn" class="btn-close btn-close-white small shadow-none" aria-label="Close"></button>
                    </div>

                    <!-- Messages Area -->
                    <div id="aiMessageArea" class="card-body p-3 overflow-y-auto" style="height: 330px; background: #F8FAFC; font-size: 13px;">
                        <div class="d-flex gap-2 mb-3">
                            <div style="width: 28px; height: 28px; border-radius: 50%; background: #DCFCE7; color: #15803D; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                <i class="fa-solid fa-robot" style="font-size: 13px;"></i>
                            </div>
                            <div class="p-2.5 rounded-3 bg-white border text-dark shadow-sm" style="max-width: 85%; line-height: 1.45; border-radius: 4px 14px 14px 14px !important;">
                                Welcome to <strong>KisaanConnect</strong>! I am your agricultural assistant. Ask me about fresh crops, escrow payments, farmer onboarding, or live order tracking!
                            </div>
                        </div>

                        <!-- Quick suggestion chips -->
                        <div id="aiQuickChips" class="d-flex flex-wrap gap-1 mb-2">
                            <button class="btn btn-outline-success btn-sm py-1 px-2 rounded-pill chip-btn" style="font-size: 11px;">How does escrow work?</button>
                            <button class="btn btn-outline-success btn-sm py-1 px-2 rounded-pill chip-btn" style="font-size: 11px;">How to sell produce as a farmer?</button>
                            <button class="btn btn-outline-success btn-sm py-1 px-2 rounded-pill chip-btn" style="font-size: 11px;">Commercial bulk lots</button>
                            <button class="btn btn-outline-success btn-sm py-1 px-2 rounded-pill chip-btn" style="font-size: 11px;">How to track delivery?</button>
                        </div>
                    </div>

                    <!-- Input Footer -->
                    <div class="card-footer bg-white p-2 border-top">
                        <form id="aiChatForm" class="d-flex gap-2">
                            <input type="text" id="aiUserInput" class="form-control form-control-sm rounded-pill px-3" 
                                   placeholder="Ask a question about KisaanConnect..." maxlength="500" required autocomplete="off" style="font-size: 13px;">
                            <button type="submit" id="aiSendBtn" class="btn btn-primary btn-sm rounded-circle d-flex align-items-center justify-content-center" style="width: 34px; height: 34px; flex-shrink: 0; background: #15803D; border-color: #15803D;">
                                <i class="fa-solid fa-paper-plane" style="font-size: 12px;"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', widgetHtml);

        const launcherBtn = document.getElementById('aiLauncherBtn');
        const chatCard = document.getElementById('aiChatCard');
        const closeBtn = document.getElementById('aiCloseBtn');
        const chatForm = document.getElementById('aiChatForm');
        const userInput = document.getElementById('aiUserInput');
        const messageArea = document.getElementById('aiMessageArea');
        const quickChips = document.getElementById('aiQuickChips');

        function toggleChat() {
            if (chatCard.style.display === 'none') {
                chatCard.style.display = 'flex';
                chatCard.style.flexDirection = 'column';
                userInput.focus();
            } else {
                chatCard.style.display = 'none';
            }
        }

        launcherBtn.addEventListener('click', toggleChat);
        closeBtn.addEventListener('click', toggleChat);

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function appendMessage(sender, text) {
            const isUser = sender === 'user';
            const msgRow = document.createElement('div');
            msgRow.className = 'd-flex gap-2 mb-3 ' + (isUser ? 'justify-content-end' : 'justify-content-start');

            const icon = isUser ? '' : `
                <div style="width: 28px; height: 28px; border-radius: 50%; background: #DCFCE7; color: #15803D; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <i class="fa-solid fa-robot" style="font-size: 13px;"></i>
                </div>
            `;
            const bubbleStyle = isUser 
                ? 'background: #15803D; color: #FFFFFF; border-radius: 14px 14px 4px 14px; box-shadow: 0 2px 4px rgba(21, 128, 61, 0.2);' 
                : 'background: #FFFFFF; color: #0F172A; border: 1px solid #E2E8F0; border-radius: 4px 14px 14px 14px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);';

            // XSS safe formatting with bold and newline support
            let formattedText = escapeHtml(text).replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>').replace(/\n/g, '<br>');

            msgRow.innerHTML = `
                ${icon}
                <div class="p-2.5" style="max-width: 80%; line-height: 1.45; font-size: 13px; ${bubbleStyle}">
                    ${formattedText}
                </div>
            `;

            messageArea.appendChild(msgRow);
            messageArea.scrollTop = messageArea.scrollHeight;
        }

        function showTypingIndicator() {
            const ind = document.createElement('div');
            ind.id = 'aiTypingIndicator';
            ind.className = 'd-flex gap-2 mb-3';
            ind.innerHTML = `
                <div style="width: 28px; height: 28px; border-radius: 50%; background: #DCFCE7; color: #15803D; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <i class="fa-solid fa-robot" style="font-size: 13px;"></i>
                </div>
                <div class="p-2 px-3 rounded-3 bg-white border text-muted small shadow-sm d-flex align-items-center gap-1" style="border-radius: 4px 14px 14px 14px;">
                    <span>Assistant is thinking</span>
                    <span class="spinner-grow spinner-grow-sm text-success" style="width: 6px; height: 6px;"></span>
                </div>
            `;
            messageArea.appendChild(ind);
            messageArea.scrollTop = messageArea.scrollHeight;
        }

        function removeTypingIndicator() {
            const ind = document.getElementById('aiTypingIndicator');
            if (ind) ind.remove();
        }

        function sendMessage(question) {
            if (!question || question.trim().length === 0) return;
            const cleanQ = question.trim().substring(0, 500);

            appendMessage('user', cleanQ);
            userInput.value = '';
            showTypingIndicator();

            if (quickChips) quickChips.style.display = 'none';

            const contextPath = window.KisaanContextPath || '';
            const params = new URLSearchParams();
            params.append('message', cleanQ);

            fetch(contextPath + '/api/assistant/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                removeTypingIndicator();
                if (data.success && data.reply) {
                    appendMessage('assistant', data.reply);
                } else {
                    appendMessage('assistant', data.error || 'I am sorry, I could not process your query right now. Please try again.');
                }
            })
            .catch(err => {
                removeTypingIndicator();
                appendMessage('assistant', 'Unable to connect to assistant service. Please check your internet connection.');
            });
        }

        chatForm.addEventListener('submit', (e) => {
            e.preventDefault();
            sendMessage(userInput.value);
        });

        if (quickChips) {
            quickChips.addEventListener('click', (e) => {
                if (e.target.classList.contains('chip-btn')) {
                    sendMessage(e.target.textContent);
                }
            });
        }
    });
})();
