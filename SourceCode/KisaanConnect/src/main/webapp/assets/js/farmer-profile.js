document.addEventListener("DOMContentLoaded", function () {

    const pincode = document.querySelector("input[name='pincode']");

    pincode.addEventListener("input", function () {

        this.value = this.value.replace(/\D/g, "");

    });

});