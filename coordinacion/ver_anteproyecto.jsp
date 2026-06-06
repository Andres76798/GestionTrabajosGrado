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
    String directorNombre = "";

    // Cargar datos del anteproyecto - CORREGIDO
    if (id != null) {
        try {
            String sql = "SELECT a.titulo, e.nombre as estudiante, d.nombre as director " +
                        "FROM anteproyectos a " +
                        "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                        "LEFT JOIN usuarios d ON a.director_id = d.id " +
                        "WHERE a.id = ?"; // ← QUITAMOS EL FILTRO DE ESTADO
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                titulo = rs.getString("titulo");
                estudianteNombre = rs.getString("estudiante");
                directorNombre = rs.getString("director");
            } else {
                response.sendRedirect("anteproyectos.jsp");
                return;
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Procesar asignación
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String evaluadorId = request.getParameter("evaluador_id");
        
        try {
            String sql = "UPDATE anteproyectos SET evaluador_id = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, evaluadorId);
            pstmt.setString(2, id);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("anteproyectos.jsp?mensaje=4");
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
    <title>Asignar Evaluador - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h4 class="mb-0">⭐ Asignar Evaluador</h4>
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
                        <div class="mb-3">
                            <label class="form-label">Director</label>
                            <input type="text" class="form-control" value="<%= directorNombre != null ? directorNombre : "No asignado" %>" readonly>
                        </div>
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label">Asignar Evaluador *</label>
                                <select class="form-select" name="evaluador_id" required>
                                    <option value="">Seleccionar evaluador</option>
                                    <%
                                        try {
                                            String sql = "SELECT id, nombre, programa_academico FROM usuarios WHERE rol = 'evaluador' AND estado = 'activo'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            while (rs.next()) {
                                    %>
                                        <option value="<%= rs.getInt("id") %>">
                                            <%= rs.getString("nombre") %> - <%= rs.getString("programa_academico") %>
                                        </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<option value=''>Error al cargar evaluadores</option>");
                                        } finally {
                                            if (rs != null) rs.close();
                                            if (pstmt != null) pstmt.close();
                                            if (conn != null) conn.close();
                                        }
                                    %>
                                </select>
                                <div class="form-text">Seleccione el evaluador que revisará este anteproyecto aprobado por el director.</div>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="anteproyectos.jsp" class="btn btn-secondary me-md-2">❌ Cancelar</a>
                                <button type="submit" class="btn btn-primary">✅ Asignar Evaluador</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>