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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Anteproyectos - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Estudiante)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>📚 Mis Anteproyectos</h2>
                    <div>
                        <a href="subir_anteproyecto.jsp" class="btn btn-success">📤 Subir Anteproyecto</a>
                        <a href="../calendario.jsp" class="btn btn-info">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-secondary">📋 Formatos</a>
                    </div>
                </div>

                <%
                    String mensaje = request.getParameter("mensaje");
                    if (mensaje != null) {
                %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <%= "1".equals(mensaje) ? "✅ Anteproyecto subido exitosamente" : 
                           "2".equals(mensaje) ? "✏️ Anteproyecto actualizado exitosamente" : "" %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <%
                    }
                %>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">📋 Lista de Mis Anteproyectos</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Título</th>
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
                                            String sql = "SELECT a.id, a.titulo, a.estado, a.calificacion_director, a.calificacion_evaluador, " +
                                                       "a.observaciones_director, a.observaciones_evaluador, a.fecha_creacion, " +
                                                       "d.nombre as director, ev.nombre as evaluador " +
                                                       "FROM anteproyectos a " +
                                                       "LEFT JOIN usuarios d ON a.director_id = d.id " +
                                                       "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                                                       "WHERE a.estudiante_id = ? " +
                                                       "ORDER BY a.fecha_creacion DESC";
                                            pstmt = conn.prepareStatement(sql);
                                            pstmt.setInt(1, usuarioId);
                                            rs = pstmt.executeQuery();
                                            
                                            while (rs.next()) {
                                    %>
                                        <tr>
                                            <td><strong>#<%= rs.getInt("id") %></strong></td>
                                            <td>
                                                <div><strong><%= rs.getString("titulo") %></strong></div>
                                                <small class="text-muted"><%= rs.getString("titulo").length() > 60 ? rs.getString("titulo").substring(0, 60) + "..." : rs.getString("titulo") %></small>
                                            </td>
                                            <td>
                                                <%= rs.getString("director") != null ? rs.getString("director") : "<span class='text-danger'>No asignado</span>" %>
                                            </td>
                                            <td>
                                                <%= rs.getString("evaluador") != null ? rs.getString("evaluador") : "<span class='text-warning'>No asignado</span>" %>
                                            </td>
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
                                                <div class="text-center">
                                                    <div>Director: 
                                                        <strong class="<%= rs.getDouble("calificacion_director") > 0 ? "text-success" : "text-muted" %>">
                                                            <%= rs.getDouble("calificacion_director") > 0 ? rs.getDouble("calificacion_director") + "/5.0" : "N/A" %>
                                                        </strong>
                                                    </div>
                                                    <div>Evaluador: 
                                                        <strong class="<%= rs.getDouble("calificacion_evaluador") > 0 ? "text-success" : "text-muted" %>">
                                                            <%= rs.getDouble("calificacion_evaluador") > 0 ? rs.getDouble("calificacion_evaluador") + "/5.0" : "N/A" %>
                                                        </strong>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion")) %></td>
                                            <td>
                                                <div class="btn-group-vertical btn-group-sm">
                                                    <a href="ver_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info btn-sm mb-1" title="Ver detalles">👁️</a>
                                                    <a href="editar_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning btn-sm mb-1" title="Editar">✏️</a>
                                                    <a href="calificaciones.jsp?id=<%= rs.getInt("id") %>" class="btn btn-success btn-sm mb-1" title="Ver calificaciones">⭐</a>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='8' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
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