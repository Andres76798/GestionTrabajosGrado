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
    String nombre = "";
    String email = "";
    String rol = "";
    String estado = "";

    // Cargar datos del usuario
    if (id != null) {
        try {
            String sql = "SELECT nombre, email, rol, estado FROM usuarios WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                nombre = rs.getString("nombre");
                email = rs.getString("email");
                rol = rs.getString("rol");
                estado = rs.getString("estado");
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Procesar actualización
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        nombre = request.getParameter("nombre");
        email = request.getParameter("email");
        String password = request.getParameter("password");
        rol = request.getParameter("rol");
        estado = request.getParameter("estado");
        
        try {
            String sql;
            if (password != null && !password.trim().isEmpty()) {
                sql = "UPDATE usuarios SET nombre = ?, email = ?, password = ?, rol = ?, estado = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nombre);
                pstmt.setString(2, email);
                pstmt.setString(3, password);
                pstmt.setString(4, rol);
                pstmt.setString(5, estado);
                pstmt.setString(6, id);
            } else {
                sql = "UPDATE usuarios SET nombre = ?, email = ?, rol = ?, estado = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, nombre);
                pstmt.setString(2, email);
                pstmt.setString(3, rol);
                pstmt.setString(4, estado);
                pstmt.setString(5, id);
            }
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("usuarios.jsp?mensaje=2");
                return;
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Usuario - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Editar Usuario</h4>
                    </div>
                    <div class="card-body">
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label">Nombre Completo</label>
                                <input type="text" class="form-control" name="nombre" value="<%= nombre %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="email" value="<%= email %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Contraseña (dejar en blanco para no cambiar)</label>
                                <input type="password" class="form-control" name="password">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Rol</label>
                                <select class="form-select" name="rol" required>
                                    <option value="administrador" <%= "administrador".equals(rol) ? "selected" : "" %>>Administrador</option>
                                    <option value="coordinacion" <%= "coordinacion".equals(rol) ? "selected" : "" %>>Coordinación</option>
                                    <option value="director" <%= "director".equals(rol) ? "selected" : "" %>>Director</option>
                                    <option value="evaluador" <%= "evaluador".equals(rol) ? "selected" : "" %>>Evaluador</option>
                                    <option value="estudiante" <%= "estudiante".equals(rol) ? "selected" : "" %>>Estudiante</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Estado</label>
                                <select class="form-select" name="estado" required>
                                    <option value="activo" <%= "activo".equals(estado) ? "selected" : "" %>>Activo</option>
                                    <option value="inactivo" <%= "inactivo".equals(estado) ? "selected" : "" %>>Inactivo</option>
                                </select>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="usuarios.jsp" class="btn btn-secondary me-md-2">Cancelar</a>
                                <button type="submit" class="btn btn-primary">Actualizar Usuario</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>