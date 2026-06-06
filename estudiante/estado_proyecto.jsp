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
    <title>Estado de Proyecto - UTS</title>
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
                <h2 class="mb-4">Estado de Mi Proyecto</h2>

                <div class="card">
                    <div class="card-body">
                        <%
                            try {
                                String sql = "SELECT a.titulo, a.descripcion, a.estado, a.calificacion_director, a.calificacion_evaluador, " +
                                           "a.observaciones_director, a.observaciones_evaluador, a.fecha_creacion, " +
                                           "d.nombre as director, ev.nombre as evaluador " +
                                           "FROM anteproyectos a " +
                                           "LEFT JOIN usuarios d ON a.director_id = d.id " +
                                           "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                                           "WHERE a.estudiante_id = ? " +
                                           "ORDER BY a.id DESC LIMIT 1";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, usuarioId);
                                rs = pstmt.executeQuery();
                                
                                if (rs.next()) {
                        %>
                        <div class="row">
                            <div class="col-md-6">
                                <h5>Información del Proyecto</h5>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Título:</th>
                                        <td><%= rs.getString("titulo") %></td>
                                    </tr>
                                    <tr>
                                        <th>Descripción:</th>
                                        <td><%= rs.getString("descripcion") %></td>
                                    </tr>
                                    <tr>
                                        <th>Estado:</th>
                                        <td>
                                            <%
                                                String estado = rs.getString("estado");
                                                String badgeClass = "bg-secondary";
                                                if ("en_revision".equals(estado)) badgeClass = "bg-warning";
                                                else if ("aprobado_director".equals(estado)) badgeClass = "bg-info";
                                                else if ("aprobado_evaluador".equals(estado)) badgeClass = "bg-success";
                                                else if ("rechazado".equals(estado)) badgeClass = "bg-danger";
                                            %>
                                            <span class="badge <%= badgeClass %>"><%= estado %></span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Director:</th>
                                        <td><%= rs.getString("director") != null ? rs.getString("director") : "No asignado" %></td>
                                    </tr>
                                    <tr>
                                        <th>Evaluador:</th>
                                        <td><%= rs.getString("evaluador") != null ? rs.getString("evaluador") : "No asignado" %></td>
                                    </tr>
                                    <tr>
                                        <th>Fecha de Envío:</th>
                                        <td><%= rs.getTimestamp("fecha_creacion") %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <h5>Calificaciones y Observaciones</h5>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Calificación Director:</th>
                                        <td>
                                            <%
                                                Double calDir = rs.getDouble("calificacion_director");
                                                if (!rs.wasNull()) {
                                                    out.println(calDir + "/5.0");
                                                } else {
                                                    out.println("Pendiente");
                                                }
                                            %>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Observaciones Director:</th>
                                        <td><%= rs.getString("observaciones_director") != null ? rs.getString("observaciones_director") : "Sin observaciones" %></td>
                                    </tr>
                                    <tr>
                                        <th>Calificación Evaluador:</th>
                                        <td>
                                            <%
                                                Double calEval = rs.getDouble("calificacion_evaluador");
                                                if (!rs.wasNull()) {
                                                    out.println(calEval + "/5.0");
                                                } else {
                                                    out.println("Pendiente");
                                                }
                                            %>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Observaciones Evaluador:</th>
                                        <td><%= rs.getString("observaciones_evaluador") != null ? rs.getString("observaciones_evaluador") : "Sin observaciones" %></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <%
                                } else {
                        %>
                        <div class="alert alert-info">
                            No tienes anteproyectos registrados. <a href="subir_anteproyecto.jsp" class="alert-link">Sube tu primer anteproyecto</a>.
                        </div>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                            } finally {
                                if (rs != null) rs.close();
                                if (pstmt != null) pstmt.close();
                                if (conn != null) conn.close();
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>