<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"coordinacion".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Anteproyectos - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Coordinación)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>📋 Gestión de Anteproyectos</h2>
                    <div>
                        <a href="crear_anteproyecto.jsp" class="btn btn-success">➕ Nuevo Anteproyecto</a>
                        <a href="informes.jsp" class="btn btn-info">📊 Informes</a>
                        <a href="../calendario.jsp" class="btn btn-warning">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-secondary">📋 Formatos</a>
                    </div>
                </div>

                <%
                    String mensaje = request.getParameter("mensaje");
                    if (mensaje != null) {
                %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <%= "1".equals(mensaje) ? "✅ Anteproyecto creado exitosamente" : 
                           "2".equals(mensaje) ? "✏️ Anteproyecto actualizado exitosamente" :
                           "3".equals(mensaje) ? "👨‍🏫 Director asignado exitosamente" : 
                           "4".equals(mensaje) ? "⭐ Evaluador asignado exitosamente" : "" %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <%
                    }
                %>

                <!-- Filtros -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">🔍 Filtros de Búsqueda</h5>
                    </div>
                    <div class="card-body">
                        <form method="GET" class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">Estado</label>
                                <select class="form-select" name="estado">
                                    <option value="">Todos los estados</option>
                                    <option value="borrador">Borrador</option>
                                    <option value="en_revision">En Revisión</option>
                                    <option value="aprobado_director">Aprobado Director</option>
                                    <option value="aprobado_evaluador">Aprobado Evaluador</option>
                                    <option value="rechazado">Rechazado</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Estudiante</label>
                                <input type="text" class="form-control" name="estudiante" placeholder="Código o nombre">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Director</label>
                                <select class="form-select" name="director">
                                    <option value="">Todos los directores</option>
                                    <%
                                        try {
                                            String sqlDirectores = "SELECT id, nombre FROM usuarios WHERE rol = 'director' AND estado = 'activo'";
                                            PreparedStatement pstmtDirectores = conn.prepareStatement(sqlDirectores);
                                            ResultSet rsDirectores = pstmtDirectores.executeQuery();
                                            while (rsDirectores.next()) {
                                    %>
                                        <option value="<%= rsDirectores.getInt("id") %>"><%= rsDirectores.getString("nombre") %></option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            // Ignorar error
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">&nbsp;</label>
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary">Buscar</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">📚 Lista de Anteproyectos</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Título</th>
                                        <th>Estudiante</th>
                                        <th>Director</th>
                                        <th>Evaluador</th>
                                        <th>Estado</th>
                                        <th>Calificaciones</th>
                                        <th>Fecha</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String filtroEstado = request.getParameter("estado");
                                            String filtroEstudiante = request.getParameter("estudiante");
                                            String filtroDirector = request.getParameter("director");
                                            
                                            StringBuilder sql = new StringBuilder(
                                                "SELECT a.id, a.titulo, a.estado, a.calificacion_director, a.calificacion_evaluador, a.fecha_creacion, " +
                                                "e.codigo as est_codigo, e.nombre as estudiante, " +
                                                "d.nombre as director, ev.nombre as evaluador " +
                                                "FROM anteproyectos a " +
                                                "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                                                "LEFT JOIN usuarios d ON a.director_id = d.id " +
                                                "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                                                "WHERE 1=1"
                                            );
                                            
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                sql.append(" AND a.estado = ?");
                                            }
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                sql.append(" AND (e.codigo LIKE ? OR e.nombre LIKE ?)");
                                            }
                                            if (filtroDirector != null && !filtroDirector.isEmpty()) {
                                                sql.append(" AND a.director_id = ?");
                                            }
                                            sql.append(" ORDER BY a.fecha_creacion DESC");
                                            
                                            pstmt = conn.prepareStatement(sql.toString());
                                            int paramIndex = 1;
                                            
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                pstmt.setString(paramIndex++, filtroEstado);
                                            }
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                String likeParam = "%" + filtroEstudiante + "%";
                                                pstmt.setString(paramIndex++, likeParam);
                                                pstmt.setString(paramIndex++, likeParam);
                                            }
                                            if (filtroDirector != null && !filtroDirector.isEmpty()) {
                                                pstmt.setString(paramIndex++, filtroDirector);
                                            }
                                            
                                            rs = pstmt.executeQuery();
                                            
                                            while (rs.next()) {
                                    %>
                                        <tr>
                                            <td><strong>#<%= rs.getInt("id") %></strong></td>
                                            <td>
                                                <div><strong><%= rs.getString("titulo") %></strong></div>
                                                <small class="text-muted"><%= rs.getString("titulo").length() > 50 ? rs.getString("titulo").substring(0, 50) + "..." : rs.getString("titulo") %></small>
                                            </td>
                                            <td>
                                                <div><%= rs.getString("estudiante") %></div>
                                                <small class="text-muted"><%= rs.getString("est_codigo") %></small>
                                            </td>
                                            <td><%= rs.getString("director") != null ? rs.getString("director") : "<span class='text-danger'>No asignado</span>" %></td>
                                            <td><%= rs.getString("evaluador") != null ? rs.getString("evaluador") : "<span class='text-warning'>No asignado</span>" %></td>
                                            <td>
                                                <%
                                                    String estado = rs.getString("estado");
                                                    String badgeClass = "bg-secondary";
                                                    String estadoText = "Borrador";
                                                    if ("en_revision".equals(estado)) {
                                                        badgeClass = "bg-warning";
                                                        estadoText = "En Revisión";
                                                    } else if ("aprobado_director".equals(estado)) {
                                                        badgeClass = "bg-info";
                                                        estadoText = "Aprobado Director";
                                                    } else if ("aprobado_evaluador".equals(estado)) {
                                                        badgeClass = "bg-success";
                                                        estadoText = "Aprobado Evaluador";
                                                    } else if ("rechazado".equals(estado)) {
                                                        badgeClass = "bg-danger";
                                                        estadoText = "Rechazado";
                                                    }
                                                %>
                                                <span class="badge <%= badgeClass %>"><%= estadoText %></span>
                                            </td>
                                            <td>
                                                <div>Director: <strong><%= rs.getDouble("calificacion_director") > 0 ? rs.getDouble("calificacion_director") + "/5.0" : "N/A" %></strong></div>
                                                <div>Evaluador: <strong><%= rs.getDouble("calificacion_evaluador") > 0 ? rs.getDouble("calificacion_evaluador") + "/5.0" : "N/A" %></strong></div>
                                            </td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion")) %></td>
                                            <td>
                                                <div class="btn-group-vertical btn-group-sm">
                                                    <a href="ver_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info btn-sm mb-1" title="Ver detalles">👁️</a>
                                                    <a href="editar_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning btn-sm mb-1" title="Editar">✏️</a>
                                                    <a href="asignar_director.jsp?id=<%= rs.getInt("id") %>" class="btn btn-primary btn-sm mb-1" title="Asignar director">👨‍🏫</a>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='9' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
                                        } finally {
                                            if (rs != null) rs.close();
                                            if (pstmt != null) pstmt.close();
                                            if (conn != null) conn.close();
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>