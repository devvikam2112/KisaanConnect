document.addEventListener("DOMContentLoaded", () => {
    const cards = document.querySelectorAll(".role-card");
    const radios = document.querySelectorAll("input[name='role']");

    function updateActiveCard() {
        cards.forEach(card => {
            const radio = card.querySelector("input[type='radio']");
            if (radio && radio.checked) {
                card.classList.add("active");
            } else {
                card.classList.remove("active");
            }
        });
    }

    cards.forEach(card => {
        card.addEventListener("click", () => {
            const radio = card.querySelector("input[type='radio']");
            if (radio) {
                radio.checked = true;
                updateActiveCard();
            }
        });
    });

    radios.forEach(radio => {
        radio.addEventListener("change", updateActiveCard);
    });

    // Form client-side validation
    const form = document.querySelector("form");
    if (form) {
        form.addEventListener("submit", (e) => {
            const password = form.querySelector("input[name='password']");
            const confirmPassword = form.querySelector("input[name='confirmPassword']");

            if (password && confirmPassword && password.value !== confirmPassword.value) {
                e.preventDefault();
                alert("Passwords do not match! Please check and try again.");
                confirmPassword.focus();
            }
        });
    }
});