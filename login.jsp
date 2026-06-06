<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="includes/conexion.jspf" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    
    if (email != null && password != null) {
        try {
            String sql = "SELECT id, nombre, email, rol, estado FROM usuarios WHERE email = ? AND password = ? AND estado = 'activo'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                session.setAttribute("usuario_id", rs.getInt("id"));
                session.setAttribute("usuario_nombre", rs.getString("nombre"));
                session.setAttribute("usuario_email", rs.getString("email"));
                session.setAttribute("usuario_rol", rs.getString("rol"));
                session.setAttribute("usuario_estado", rs.getString("estado"));
                
                // Redirigir al dashboard correspondiente
                response.sendRedirect("dashboard.jsp");
            } else {
                // Verificar si el usuario existe pero está inactivo
                String sqlInactivo = "SELECT id FROM usuarios WHERE email = ? AND password = ? AND estado = 'inactivo'";
                pstmt = conn.prepareStatement(sqlInactivo);
                pstmt.setString(1, email);
                pstmt.setString(2, password);
                ResultSet rsInactivo = pstmt.executeQuery();
                
                if (rsInactivo.next()) {
                    response.sendRedirect("index.jsp?error=2"); // Usuario inactivo
                } else {
                    response.sendRedirect("index.jsp?error=1"); // Credenciales incorrectas
                }
                
                if (rsInactivo != null) rsInactivo.close();
            }
        } catch (Exception e) {
            response.sendRedirect("index.jsp?error=3"); // Error del sistema
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    } else {
        response.sendRedirect("index.jsp?error=1");
    }
%>