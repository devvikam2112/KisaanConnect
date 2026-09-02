<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String email = request.getParameter("email");
    String redirect = request.getParameter("redirect");
    String roleParam = request.getParameter("role");

    if ("admin@kisaanconnect.com".equalsIgnoreCase(email) || "ADMIN".equalsIgnoreCase(roleParam)) {
        com.kisaanconnect.model.User adminUser = new com.kisaanconnect.model.User();
        adminUser.setUserId(1);
        adminUser.setEmail("admin@kisaanconnect.com");
        adminUser.setFullName("Platform Administrator");
        adminUser.setRole("ADMIN");
        adminUser.setStatus("ACTIVE");
        session.setAttribute("loggedInUser", adminUser);
    } else if (email != null) {
        com.kisaanconnect.dao.UserDAO uDAO = new com.kisaanconnect.dao.UserDAO();
        com.kisaanconnect.model.User user = uDAO.getUserByEmail(email);
        if (user != null) {
            session.setAttribute("loggedInUser", user);
            if ("FARMER".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("farmerProfile", new com.kisaanconnect.dao.FarmerProfileDAO().getProfileByUserId(user.getUserId()));
            } else if ("COMMERCIAL".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("organization", new com.kisaanconnect.dao.OrganizationDAO().getOrganizationByUserId(user.getUserId()));
            } else if ("BUYER".equalsIgnoreCase(user.getRole())) {
                session.setAttribute("buyerProfile", new com.kisaanconnect.dao.BuyerDAO().getProfileByUserId(user.getUserId()));
            }
        }
    }

    if (redirect != null) {
        response.sendRedirect(request.getContextPath() + redirect);
    }
%>
