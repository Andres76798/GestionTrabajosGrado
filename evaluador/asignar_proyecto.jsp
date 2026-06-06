<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    if (usuarioRol == null || !"evaluador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    // Procesar asignación de proyecto
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String proyectoId = request.getParameter("proyecto_id");
        
        try {
            String sql = "UPDATE anteproyectos SET evaluador_id = ? WHERE id = ? AND estado = 'aprobado_director' AND evaluador_id IS NULL";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            pstmt.setString(2, proyectoId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("evaluar_anteproyecto.jsp?id=" + proyectoId + "&mensaje=1");
                return;
            } else {
                response.sendRedirect("anteproyectos_evaluar.jsp?error=2");
                return;
            }
        } catch (Exception e) {
            response.sendRedirect("anteproyectos_evaluar.jsp?error=3");
            return;
        }
    } else {
        response.sendRedirect("anteproyectos_evaluar.jsp");
    }
%>