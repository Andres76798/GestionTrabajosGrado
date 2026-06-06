<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"coordinacion".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    String id = request.getParameter("id");
    String titulo = "";
    String estudianteNombre = "";

    // Cargar datos del anteproyecto
    if (id != null) {
        try {
            String sql = "SELECT a.titulo, e.nombre as estudiante FROM anteproyectos a " +
                        "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                        "WHERE a.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                titulo = rs.getString("titulo");
                estudianteNombre = rs.getString("estudiante");
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Procesar asignación
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String directorId = request.getParameter("director_id");
        
        try {
            String sql = "UPDATE anteproyectos SET director_id = ?, estado = 'en_revision' WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, directorId);
            pstmt.setString(2, id);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("anteproyectos.jsp?mensaje=3");
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
    <title>Asignar Director - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Asignar Director</h4>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Anteproyecto</label>
                            <input type="text" class="form-control" value="<%= titulo %>" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Estudiante</label>
                            <input type="text" class="form-control" value="<%= estudianteNombre %>" readonly>
                        </div>
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label">Asignar Director</label>
                                <select class="form-select" name="director_id" required>
                                    <option value="">Seleccionar director</option>
                                    <%
                                        try {
                                            String sql = "SELECT id, nombre FROM usuarios WHERE rol = 'director' AND estado = 'activo'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            while (rs.next()) {
                                    %>
                                        <option value="<%= rs.getInt("id") %>"><%= rs.getString("nombre") %></option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<option value=''>Error al cargar directores</option>");
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="anteproyectos.jsp" class="btn btn-secondary me-md-2">Cancelar</a>
                                <button type="submit" class="btn btn-primary">Asignar Director</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>