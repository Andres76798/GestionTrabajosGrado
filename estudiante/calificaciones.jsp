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

    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("mis_anteproyectos.jsp");
        return;
    }

    // Cargar datos del anteproyecto y calificaciones
    String titulo = "", estado = "", calificacionDirector = "", calificacionEvaluador = "";
    String observacionesDirector = "", observacionesEvaluador = "";
    String directorNombre = "", evaluadorNombre = "";
    String fechaCreacion = "";
    
    try {
        String sql = "SELECT a.titulo, a.estado, a.calificacion_director, a.calificacion_evaluador, " +
                   "a.observaciones_director, a.observaciones_evaluador, a.fecha_creacion, " +
                   "d.nombre as director, ev.nombre as evaluador " +
                   "FROM anteproyectos a " +
                   "LEFT JOIN usuarios d ON a.director_id = d.id " +
                   "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                   "WHERE a.id = ? AND a.estudiante_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setInt(2, usuarioId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            titulo = rs.getString("titulo");
            estado = rs.getString("estado");
            calificacionDirector = rs.getString("calificacion_director");
            calificacionEvaluador = rs.getString("calificacion_evaluador");
            observacionesDirector = rs.getString("observaciones_director");
            observacionesEvaluador = rs.getString("observaciones_evaluador");
            directorNombre = rs.getString("director");
            evaluadorNombre = rs.getString("evaluador");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion"));
        } else {
            response.sendRedirect("mis_anteproyectos.jsp");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calificaciones - Estudiante</title>
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
                    <h2>⭐ Calificaciones de Mi Anteproyecto</h2>
                    <div>
                        <a href="ver_anteproyecto.jsp?id=<%= id %>" class="btn btn-secondary">← Volver al Anteproyecto</a>
                        <a href="mis_anteproyectos.jsp" class="btn btn-info">📚 Todos Mis Proyectos</a>
                    </div>
                </div>

                <!-- Información General -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">📋 Información del Proyecto</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <h4 class="text-primary"><%= titulo %></h4>
                                <p class="text-muted">Fecha de envío: <%= fechaCreacion %></p>
                            </div>
                            <div class="col-md-4 text-end">
                                <%
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
                                <span class="badge <%= badgeClass %> fs-6"><%= estadoText %></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Resumen de Calificaciones -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card text-center">
                            <div class="card-header bg-warning text-white">
                                <h5 class="mb-0">🧑‍🏫 Calificación del Director</h5>
                            </div>
                            <div class="card-body">
                                <% if (calificacionDirector != null) { 
                                    double calificacion = Double.parseDouble(calificacionDirector);
                                    String color = calificacion >= 3.5 ? "text-success" : calificacion >= 3.0 ? "text-warning" : "text-danger";
                                %>
                                <div class="display-4 <%= color %>"><strong><%= calificacionDirector %></strong></div>
                                <h5 class="<%= color %>">/ 5.0</h5>
                                <p class="text-muted">Director: <%= directorNombre %></p>
                                <% } else { %>
                                <div class="display-4 text-muted">--</div>
                                <h5 class="text-muted">/ 5.0</h5>
                                <p class="text-muted">⏳ Pendiente de calificación</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card text-center">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">⭐ Calificación del Evaluador</h5>
                            </div>
                            <div class="card-body">
                                <% if (calificacionEvaluador != null) { 
                                    double calificacion = Double.parseDouble(calificacionEvaluador);
                                    String color = calificacion >= 3.5 ? "text-success" : calificacion >= 3.0 ? "text-warning" : "text-danger";
                                %>
                                <div class="display-4 <%= color %>"><strong><%= calificacionEvaluador %></strong></div>
                                <h5 class="<%= color %>">/ 5.0</h5>
                                <p class="text-muted">Evaluador: <%= evaluadorNombre %></p>
                                <% } else { %>
                                <div class="display-4 text-muted">--</div>
                                <h5 class="text-muted">/ 5.0</h5>
                                <p class="text-muted">⏳ Pendiente de calificación</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Calificación Final -->
                <div class="card mb-4">
                    <div class="card-header bg-success text-white text-center">
                        <h4 class="mb-0">🎓 Calificación Final</h4>
                    </div>
                    <div class="card-body text-center">
                        <%
                            if (calificacionDirector != null && calificacionEvaluador != null) {
                                double calDir = Double.parseDouble(calificacionDirector);
                                double calEval = Double.parseDouble(calificacionEvaluador);
                                double promedio = (calDir + calEval) / 2;
                                String colorFinal = promedio >= 3.5 ? "text-success" : promedio >= 3.0 ? "text-warning" : "text-danger";
                                String estadoFinal = promedio >= 3.0 ? "APROBADO" : "REPROBADO";
                                String badgeFinal = promedio >= 3.0 ? "bg-success" : "bg-danger";
                        %>
                        <div class="display-1 <%= colorFinal %>"><strong><%= String.format("%.1f", promedio) %></strong></div>
                        <h3 class="<%= colorFinal %>">/ 5.0</h3>
                        <span class="badge <%= badgeFinal %> fs-4 mt-2"><%= estadoFinal %></span>
                        <%
                            } else if (calificacionDirector != null) {
                        %>
                        <div class="alert alert-info">
                            <h5>📊 Calificación Parcial</h5>
                            <p>Director: <strong><%= calificacionDirector %>/5.0</strong></p>
                            <p>Evaluador: <span class="text-muted">Pendiente</span></p>
                        </div>
                        <%
                            } else {
                        %>
                        <div class="alert alert-warning">
                            <h5>⏳ En Proceso de Evaluación</h5>
                            <p>Tu anteproyecto está siendo revisado por los evaluadores.</p>
                            <p>Las calificaciones estarán disponibles pronto.</p>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Observaciones Detalladas -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h5 class="mb-0">📋 Observaciones del Director</h5>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <% if (observacionesDirector != null) { %>
                                        <%= observacionesDirector.replace("\n", "<br>") %>
                                    <% } else { %>
                                        <div class="text-center text-muted">
                                            <p>📝</p>
                                            <p>No hay observaciones del director aún</p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">⭐ Observaciones del Evaluador</h5>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <% if (observacionesEvaluador != null) { %>
                                        <%= observacionesEvaluador.replace("\n", "<br>") %>
                                    <% } else { %>
                                        <div class="text-center text-muted">
                                            <p>⏳</p>
                                            <p>No hay observaciones del evaluador aún</p>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recomendaciones -->
                <div class="card mt-4">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">💡 Recomendaciones</h5>
                    </div>
                    <div class="card-body">
                        <%
                            if (calificacionDirector != null && calificacionEvaluador != null) {
                                double calDir = Double.parseDouble(calificacionDirector);
                                double calEval = Double.parseDouble(calificacionEvaluador);
                                double promedio = (calDir + calEval) / 2;
                                
                                if (promedio >= 4.0) {
                        %>
                        <div class="alert alert-success">
                            <h5>🎉 ¡Excelente trabajo!</h5>
                            <p>Tu anteproyecto ha sido calificado de manera excelente. Continúa con el mismo nivel de dedicación en el desarrollo del trabajo completo.</p>
                        </div>
                        <%
                                } else if (promedio >= 3.5) {
                        %>
                        <div class="alert alert-info">
                            <h5>👍 Buen trabajo</h5>
                            <p>Tu anteproyecto ha sido aprobado satisfactoriamente. Considera las observaciones para mejorar en el desarrollo final.</p>
                        </div>
                        <%
                                } else if (promedio >= 3.0) {
                        %>
                        <div class="alert alert-warning">
                            <h5>⚠️ Aprobado con observaciones</h5>
                            <p>Tu anteproyecto ha sido aprobado, pero requiere atención a las observaciones señaladas antes del desarrollo final.</p>
                        </div>
                        <%
                                } else {
                        %>
                        <div class="alert alert-danger">
                            <h5>❌ Requiere revisión</h5>
                            <p>Es necesario realizar las correcciones indicadas y volver a enviar el anteproyecto para una nueva evaluación.</p>
                        </div>
                        <%
                                }
                            } else if (calificacionDirector != null) {
                        %>
                        <div class="alert alert-info">
                            <h5>⏳ En proceso</h5>
                            <p>Tu anteproyecto ha sido calificado por el director y está pendiente de evaluación por el evaluador.</p>
                        </div>
                        <%
                            } else {
                        %>
                        <div class="alert alert-secondary">
                            <h5>📝 En revisión</h5>
                            <p>Tu anteproyecto está siendo evaluado. Revisa periódicamente para ver las calificaciones y observaciones.</p>
                        </div>
                        <%
                            }
                        %>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="card mt-4">
                    <div class="card-body text-center">
                        <div class="btn-group">
                            <a href="ver_anteproyecto.jsp?id=<%= id %>" class="btn btn-secondary">← Volver al Anteproyecto</a>
                            <a href="mis_anteproyectos.jsp" class="btn btn-info">📚 Mis Proyectos</a>
                            <a href="../calendario.jsp" class="btn btn-warning">📅 Calendario Académico</a>
                            <a href="../formatos.jsp" class="btn btn-primary">📋 Formatos de Grado</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>