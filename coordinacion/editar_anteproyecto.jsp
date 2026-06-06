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
    String descripcion = "";
    String estudianteId = "";
    String directorId = "";
    String estado = "";

    // Cargar datos del anteproyecto
    if (id != null) {
        try {
            String sql = "SELECT titulo, descripcion, estudiante_id, director_id, estado FROM anteproyectos WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                titulo = rs.getString("titulo");
                descripcion = rs.getString("descripcion");
                estudianteId = rs.getString("estudiante_id");
                directorId = rs.getString("director_id");
                estado = rs.getString("estado");
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }

    // Procesar actualización
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        titulo = request.getParameter("titulo");
        descripcion = request.getParameter("descripcion");
        estudianteId = request.getParameter("estudiante_id");
        directorId = request.getParameter("director_id");
        estado = request.getParameter("estado");
        
        try {
            String sql = "UPDATE anteproyectos SET titulo = ?, descripcion = ?, estudiante_id = ?, director_id = ?, estado = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, titulo);
            pstmt.setString(2, descripcion);
            pstmt.setString(3, estudianteId);
            pstmt.setString(4, directorId);
            pstmt.setString(5, estado);
            pstmt.setString(6, id);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("anteproyectos.jsp?mensaje=2");
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
    <title>Editar Anteproyecto - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">Editar Anteproyecto</h4>
                    </div>
                    <div class="card-body">
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label">Título del Anteproyecto</label>
                                <input type="text" class="form-control" name="titulo" value="<%= titulo %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Descripción</label>
                                <textarea class="form-control" name="descripcion" rows="5" required><%= descripcion %></textarea>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Estudiante</label>
                                <select class="form-select" name="estudiante_id" required>
                                    <option value="">Seleccionar estudiante</option>
                                    <%
                                        try {
                                            String sql = "SELECT id, nombre FROM usuarios WHERE rol = 'estudiante' AND estado = 'activo'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            while (rs.next()) {
                                    %>
                                        <option value="<%= rs.getInt("id") %>" <%= String.valueOf(rs.getInt("id")).equals(estudianteId) ? "selected" : "" %>>
                                            <%= rs.getString("nombre") %>
                                        </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<option value=''>Error al cargar estudiantes</option>");
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Director</label>
                                <select class="form-select" name="director_id" required>
                                    <option value="">Seleccionar director</option>
                                    <%
                                        try {
                                            String sql = "SELECT id, nombre FROM usuarios WHERE rol = 'director' AND estado = 'activo'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            while (rs.next()) {
                                    %>
                                        <option value="<%= rs.getInt("id") %>" <%= String.valueOf(rs.getInt("id")).equals(directorId) ? "selected" : "" %>>
                                            <%= rs.getString("nombre") %>
                                        </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<option value=''>Error al cargar directores</option>");
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Estado</label>
                                <select class="form-select" name="estado" required>
                                    <option value="borrador" <%= "borrador".equals(estado) ? "selected" : "" %>>Borrador</option>
                                    <option value="en_revision" <%= "en_revision".equals(estado) ? "selected" : "" %>>En Revisión</option>
                                    <option value="aprobado_director" <%= "aprobado_director".equals(estado) ? "selected" : "" %>>Aprobado por Director</option>
                                    <option value="aprobado_evaluador" <%= "aprobado_evaluador".equals(estado) ? "selected" : "" %>>Aprobado por Evaluador</option>
                                    <option value="rechazado" <%= "rechazado".equals(estado) ? "selected" : "" %>>Rechazado</option>
                                </select>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="anteproyectos.jsp" class="btn btn-secondary me-md-2">Cancelar</a>
                                <button type="submit" class="btn btn-primary">Actualizar Anteproyecto</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>