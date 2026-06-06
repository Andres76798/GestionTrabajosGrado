<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"administrador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    String id = request.getParameter("id");
    
    if (id != null) {
        try {
            String sql = "DELETE FROM usuarios WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("usuarios.jsp?mensaje=3");
                return;
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    } else {
        response.sendRedirect("usuarios.jsp");
    }
%>