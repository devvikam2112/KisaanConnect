(function () {
    const POLL_INTERVAL = 10000; // 10 seconds

    function getContextPath() {
        if (window.KisaanContextPath !== undefined) return window.KisaanContextPath;
        const path = window.location.pathname;
        const idx = path.indexOf('/', 1);
        return idx !== -1 ? path.substring(0, idx) : '';
    }

    function updateBadges(unreadCount) {
        // Bootstrap navbar badge
        const bsBadges = document.querySelectorAll('.nav-link[href*=notifications] .badge, #navNotifBadge');
        bsBadges.forEach(b => {
            if (unreadCount > 0) {
                b.textContent = unreadCount;
                b.style.display = 'inline-block';
            } else {
                b.textContent = '0';
                b.style.display = 'none';
            }
        });

        // Top-navbar (Farmer / Commercial) count badges
        const topNavCounts = document.querySelectorAll('.notification[title*=Notification] .notification-count');
        topNavCounts.forEach(c => {
            if (unreadCount > 0) {
                c.textContent = unreadCount;
                c.style.display = 'inline-flex';
            } else {
                c.textContent = '0';
                c.style.display = 'none';
            }
        });

        // If badge didn't exist in top-navbar and unreadCount > 0, create it
        if (unreadCount > 0 && topNavCounts.length === 0) {
            const topNavParent = document.querySelectorAll('.notification[title*=Notification]');
            topNavParent.forEach(p => {
                let badge = p.querySelector('.notification-count');
                if (!badge) {
                    badge = document.createElement('span');
                    badge.className = 'notification-count';
                    badge.style.background = '#DC2626';
                    badge.textContent = unreadCount;
                    p.appendChild(badge);
                }
            });
        }
    }

    function renderLiveNotifications(notifications) {
        const container = document.getElementById('notificationsContainer');
        if (!container || !notifications || notifications.length === 0) return;

        const emptyState = document.getElementById('notificationsEmptyState');
        if (emptyState) emptyState.style.display = 'none';

        const existingCards = container.querySelectorAll('.notif-card');
        const existingIds = new Set();
        existingCards.forEach(card => {
            const id = card.getAttribute('data-notif-id');
            if (id) existingIds.add(id);
        });

        const ctx = getContextPath();

        notifications.forEach(n => {
            if (!existingIds.has(String(n.id))) {
                const type = (n.type || 'SYSTEM').toUpperCase();
                let iconClass = 'icon-system';
                let iconFa = 'fa-bell';

                if (type === 'ORDER') {
                    iconClass = 'icon-order';
                    iconFa = 'fa-clipboard-list';
                } else if (type === 'WALLET') {
                    iconClass = 'icon-wallet';
                    iconFa = 'fa-wallet';
                } else if (type === 'CHAT') {
                    iconClass = 'icon-chat';
                    iconFa = 'fa-comment-dots';
                } else if (type === 'DELIVERY') {
                    iconClass = 'icon-delivery';
                    iconFa = 'fa-truck';
                }

                const card = document.createElement('div');
                card.className = 'notif-card ' + (!n.isRead ? 'unread' : '');
                card.setAttribute('data-notif-id', n.id);

                let actionsHtml = '';
                if (n.targetUrl) {
                    actionsHtml += '<a href="' + ctx + '/notifications/read?id=' + encodeURIComponent(n.id) + '&target=' + encodeURIComponent(n.targetUrl) + '" class="btn btn-sm btn-outline-success rounded-pill px-3 py-1 fw-semibold" style="font-size: 12px;">View Details <i class="fa-solid fa-arrow-right ms-1"></i></a>';
                }
                if (!n.isRead) {
                    actionsHtml += '<a href="' + ctx + '/notifications/read?id=' + encodeURIComponent(n.id) + '" class="btn btn-sm btn-light text-muted rounded-pill px-3 py-1 ms-2" style="font-size: 12px;">Mark as read</a>';
                }

                card.innerHTML = '<div class="notif-icon-box ' + iconClass + '">' +
                    '<i class="fa-solid ' + iconFa + '"></i>' +
                    '</div>' +
                    '<div class="flex-grow-1">' +
                    '<div class="d-flex justify-content-between align-items-center mb-1">' +
                    '<h6 class="fw-bold mb-0 text-dark">' + escapeHtml(n.title) + (!n.isRead ? ' <span class="badge bg-success small ms-2" style="font-size: 10px;">NEW</span>' : '') + '</h6>' +
                    '<span class="small text-muted">' + escapeHtml(n.createdAt) + '</span>' +
                    '</div>' +
                    '<p class="text-muted mb-2 small">' + escapeHtml(n.message) + '</p>' +
                    '<div class="d-flex gap-2 align-items-center">' + actionsHtml + '</div>' +
                    '</div>';

                container.insertBefore(card, container.firstChild);
            }
        });
    }

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function pollNotifications() {
        if (document.hidden) return; // Pause polling when tab is inactive

        const ctx = getContextPath();
        fetch(ctx + '/notifications/poll', {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => {
            if (!res.ok) throw new Error('Polling error HTTP ' + res.status);
            return res.json();
        })
        .then(data => {
            if (data && typeof data.unreadCount === 'number') {
                updateBadges(data.unreadCount);
                if (data.notifications) {
                    renderLiveNotifications(data.notifications);
                }
            }
        })
        .catch(() => {
            // Silently handle temporary network failures
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        pollNotifications();
        setInterval(pollNotifications, POLL_INTERVAL);
    });
})();
