/* ==========================================================
   KisaanConnect
   Login Page JavaScript
========================================================== */

document.addEventListener("DOMContentLoaded", function () {

    /* ===========================
       INPUT ANIMATION
    =========================== */

    const inputs = document.querySelectorAll(".input-field");

    inputs.forEach(input => {

        input.addEventListener("focus", function () {
            this.parentElement.classList.add("focused");
        });

        input.addEventListener("blur", function () {

            if (this.value.trim() === "") {
                this.parentElement.classList.remove("focused");
            }

        });

    });

    /* ===========================
       PASSWORD TOGGLE
    =========================== */

    const toggle = document.getElementById("togglePassword");
    const password = document.getElementById("password");

    if (toggle && password) {

        toggle.addEventListener("click", function () {

            if (password.type === "password") {

                password.type = "text";
                toggle.classList.remove("fa-eye");
                toggle.classList.add("fa-eye-slash");

            } else {

                password.type = "password";
                toggle.classList.remove("fa-eye-slash");
                toggle.classList.add("fa-eye");

            }

        });

    }

    /* ===========================
       EMAIL VALIDATION
    =========================== */

    const form = document.getElementById("loginForm");

    if (form) {

        form.addEventListener("submit", function (e) {

            const email = document.getElementById("email").value.trim();
            const pass = document.getElementById("password").value.trim();

            if (email === "") {

                alert("Please enter your email.");
                e.preventDefault();
                return;

            }

            const emailPattern =
                    /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

            if (!emailPattern.test(email)) {

                alert("Please enter a valid email address.");
                e.preventDefault();
                return;

            }

            if (pass === "") {

                alert("Please enter your password.");
                e.preventDefault();
                return;

            }

        });

    }

});


