<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">
    <title>KisaanConnect</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/style.css">

</head>

<body>

<%@include file="includes/navbar.jsp" %>

<div class="container py-5">

    <div class="row align-items-center" style="min-height:75vh;">

        <div class="col-md-6">

            <h1 class="display-4 fw-bold text-success">
                Welcome to KisaanConnect
            </h1>

            <p class="lead mt-3">
                KisaanConnect is a web-based farmer marketplace where farmers
                can sell their agricultural products directly to buyers without
                middlemen.
            </p>

            <a href="auth/register.jsp" class="btn btn-success btn-lg">
                Get Started
            </a>

        </div>

        <div class="col-md-6 text-center">

            <img src="${pageContext.request.contextPath}/images/farmer.png"
            class="img-fluid"
            style="max-width:450px;"
            alt="Farmer">

        </div>

    </div>

</div>

<%@include file="includes/footer.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/script.js"></script>

</body>
</html>
</body>
</html>