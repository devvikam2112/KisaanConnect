<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String errorMsg = (String) request.getAttribute("error");
    if (errorMsg == null || errorMsg.trim().isEmpty()) {
        errorMsg = request.getParameter("error");
    }

    String successMsg = (String) request.getAttribute("success");
    if (successMsg == null || successMsg.trim().isEmpty()) {
        successMsg = request.getParameter("success");
    }
%>

<% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
    <div style="background-color: #FDE8E8; color: #9B1C1C; border: 1px solid #F8B4B4; padding: 12px 16px; border-radius: 12px; margin-bottom: 18px; font-size: 14px; display: flex; align-items: center; gap: 10px; font-family: var(--kc-font);">
        <span style="font-size: 18px;"><i class="fa-solid fa-triangle-exclamation"></i></span>
        <span><%= errorMsg %></span>
    </div>
<% } %>

<% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
    <div style="background-color: #DEF7EC; color: #03543F; border: 1px solid #BCF0DA; padding: 12px 16px; border-radius: 12px; margin-bottom: 18px; font-size: 14px; display: flex; align-items: center; gap: 10px; font-family: var(--kc-font);">
        <span style="font-size: 18px;"><i class="fa-solid fa-circle-check"></i></span>
        <span><%= successMsg %></span>
    </div>
<% } %>
