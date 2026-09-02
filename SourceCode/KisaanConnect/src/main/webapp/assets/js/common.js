/**
 * KisaanConnect — Common UI Interactions & Utilities
 */
document.addEventListener("DOMContentLoaded", function () {
    // Auto-dismiss alert notifications after 5 seconds
    const alerts = document.querySelectorAll(".alert-dismissible, .alert");
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = "opacity 0.4s ease, transform 0.4s ease";
            alert.style.opacity = "0";
            alert.style.transform = "translateY(-6px)";
            setTimeout(function () {
                if (alert.parentNode) {
                    alert.parentNode.removeChild(alert);
                }
            }, 400);
        }, 5000);
    });

    // Mobile sidebar toggle
    const toggleBtn = document.querySelector(".mobile-menu-toggle");
    const sidebar = document.querySelector(".sidebar");
    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener("click", function () {
            sidebar.classList.toggle("active");
        });
    }
});
