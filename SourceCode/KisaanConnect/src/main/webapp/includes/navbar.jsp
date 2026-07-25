<%@page contentType="text/html" pageEncoding="UTF-8"%>

<nav class="navbar navbar-expand-lg navbar-dark bg-success">

    <div class="container">

        <a class="navbar-brand fw-bold"
           href="${pageContext.request.contextPath}/index.jsp">
            🌾 KisaanConnect
        </a>

        <button class="navbar-toggler"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target="#navbarNav">

            <span class="navbar-toggler-icon"></span>

        </button>

        <div class="collapse navbar-collapse" id="navbarNav">

            <ul class="navbar-nav ms-auto">

                <li class="nav-item">
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/index.jsp">
                        Home
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/auth/login.jsp">
                        Login
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/auth/register.jsp">
                        Register
                    </a>
                </li>

            </ul>

        </div>

    </div>

</nav>