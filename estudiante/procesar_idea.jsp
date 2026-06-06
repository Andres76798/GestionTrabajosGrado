<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    if (usuarioRol == null || !"estudiante".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    // Procesar nueva idea
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String tituloIdea = request.getParameter("titulo_idea");
        String descripcionIdea = request.getParameter("descripcion_idea");
        String area = request.getParameter("area");
        String tecnologias = request.getParameter("tecnologias");
        
        try {
            // Insertar como nuevo anteproyecto en estado borrador
            String sql = "INSERT INTO anteproyectos (titulo, descripcion, estudiante_id, estado) VALUES (?, ?, ?, 'borrador')";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, tituloIdea);
            pstmt.setString(2, descripcionIdea + "\n\nÁrea: " + area + "\nTecnologías: " + (tecnologias != null ? tecnologias : "Por definir"));
            pstmt.setInt(3, usuarioId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("subir_anteproyecto.jsp?mensaje=1");
                return;
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    } else {
        response.sendRedirect("seleccionar_idea.jsp");
    }
%>