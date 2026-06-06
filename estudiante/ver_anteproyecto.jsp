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

    // Cargar datos del anteproyecto
    String titulo = "", descripcion = "", objetivoGeneral = "", objetivosEspecificos = "", justificacion = "", metodologia = "";
    String estado = "", calificacionDirector = "", calificacionEvaluador = "", observacionesDirector = "", observacionesEvaluador = "";
    String directorNombre = "", directorEmail = "", directorTelefono = "", evaluadorNombre = "", evaluadorEmail = "", evaluadorTelefono = "";
    String fechaCreacion = "", fechaActualizacion = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, a.calificacion_director, a.calificacion_evaluador, a.observaciones_director, a.observaciones_evaluador, " +
                   "a.fecha_creacion, a.fecha_actualizacion, " +
                   "d.nombre as director, d.email as director_email, d.telefono as director_telefono, " +
                   "ev.nombre as evaluador, ev.email as evaluador_email, ev.telefono as evaluador_telefono " +
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
            descripcion = rs.getString("descripcion");
            objetivoGeneral = rs.getString("objetivo_general");
            objetivosEspecificos = rs.getString("objetivos_especificos");
            justificacion = rs.getString("justificacion");
            metodologia = rs.getString("metodologia");
            estado = rs.getString("estado");
            calificacionDirector = rs.getString("calificacion_director");
            calificacionEvaluador = rs.getString("calificacion_evaluador");
            observacionesDirector = rs.getString("observaciones_director");
            observacionesEvaluador = rs.getString("observaciones_evaluador");
            directorNombre = rs.getString("director");
            directorEmail = rs.getString("director_email");
            directorTelefono = rs.getString("director_telefono");
            evaluadorNombre = rs.getString("evaluador");
            evaluadorEmail = rs.getString("evaluador_email");
            evaluadorTelefono = rs.getString("evaluador_telefono");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_creacion"));
            fechaActualizacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_actualizacion"));
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
    <title>Ver Anteproyecto - Estudiante</title>
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
                    <h2>👁️ Detalles de Mi Anteproyecto</h2>
                    <div>
                        <a href="mis_anteproyectos.jsp" class="btn btn-secondary">← Volver</a>
                        <a href="editar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">✏️ Editar</a>
                        <a href="calificaciones.jsp?id=<%= id %>" class="btn btn-success">⭐ Ver Calificaciones</a>
                    </div>
                </div>

                <!-- Información General -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">📋 Información General</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-8">
                                <h4 class="text-primary"><%= titulo %></h4>
                                <p class="text-muted">ID: #<%= id %></p>
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
                        
                        <div class="row mt-3">
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Fecha Creación:</th>
                                        <td><%= fechaCreacion %></td>
                                    </tr>
                                    <tr>
                                        <th>Última Actualización:</th>
                                        <td><%= fechaActualizacion %></td>
                                    </tr>
                                    <tr>
                                        <th>Calificación Director:</th>
                                        <td>
                                            <strong class="<%= calificacionDirector != null ? "text-success" : "text-muted" %>">
                                                <%= calificacionDirector != null ? calificacionDirector + "/5.0" : "Pendiente" %>
                                            </strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Calificación Evaluador:</th>
                                        <td>
                                            <strong class="<%= calificacionEvaluador != null ? "text-success" : "text-muted" %>">
                                                <%= calificacionEvaluador != null ? calificacionEvaluador + "/5.0" : "Pendiente" %>
                                            </strong>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información de Docentes -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">🧑‍🏫 Información del Director</h6>
                            </div>
                            <div class="card-body">
                                <% if (directorNombre != null) { %>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Nombre:</th>
                                        <td><strong><%= directorNombre %></strong></td>
                                    </tr>
                                    <tr>
                                        <th>Email:</th>
                                        <td><%= directorEmail %></td>
                                    </tr>
                                    <tr>
                                        <th>Teléfono:</th>
                                        <td><%= directorTelefono != null ? directorTelefono : "No disponible" %></td>
                                    </tr>
                                </table>
                                <% } else { %>
                                <div class="alert alert-warning text-center">
                                    <p>📝 <strong>Director no asignado</strong></p>
                                    <p>Espera a que coordinación asigne un director para tu proyecto.</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">⭐ Información del Evaluador</h6>
                            </div>
                            <div class="card-body">
                                <% if (evaluadorNombre != null) { %>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Nombre:</th>
                                        <td><strong><%= evaluadorNombre %></strong></td>
                                    </tr>
                                    <tr>
                                        <th>Email:</th>
                                        <td><%= evaluadorEmail %></td>
                                    </tr>
                                    <tr>
                                        <th>Teléfono:</th>
                                        <td><%= evaluadorTelefono != null ? evaluadorTelefono : "No disponible" %></td>
                                    </tr>
                                </table>
                                <% } else { %>
                                <div class="alert alert-info text-center">
                                    <p>⏳ <strong>Evaluador no asignado</strong></p>
                                    <p>Será asignado después de la aprobación del director.</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contenido del Anteproyecto -->
                <div class="card mb-4">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0">📝 Contenido del Anteproyecto</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6>📋 Descripción General:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= descripcion != null ? descripcion : "<span class='text-muted'>No disponible</span>" %>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <h6>🎯 Objetivo General:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= objetivoGeneral != null ? objetivoGeneral : "<span class='text-muted'>No disponible</span>" %>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <h6>📌 Objetivos Específicos:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= objetivosEspecificos != null ? objetivosEspecificos.replace("\n", "<br>") : "<span class='text-muted'>No disponible</span>" %>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <h6>💡 Justificación:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= justificacion != null ? justificacion : "<span class='text-muted'>No disponible</span>" %>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <h6>🔬 Metodología:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= metodologia != null ? metodologia : "<span class='text-muted'>No disponible</span>" %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Observaciones -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary text-white">
                                <h6 class="mb-0">📋 Observaciones del Director</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 120px;">
                                    <%= observacionesDirector != null ? observacionesDirector : "<span class='text-muted'>No hay observaciones del director</span>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">⭐ Observaciones del Evaluador</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 120px;">
                                    <%= observacionesEvaluador != null ? observacionesEvaluador : "<span class='text-muted'>No hay observaciones del evaluador</span>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="card mt-4">
                    <div class="card-body text-center">
                        <div class="btn-group">
                            <a href="mis_anteproyectos.jsp" class="btn btn-secondary">← Volver a la Lista</a>
                            <a href="editar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">✏️ Editar Anteproyecto</a>
                            <a href="calificaciones.jsp?id=<%= id %>" class="btn btn-success">⭐ Ver Calificaciones Detalladas</a>
                            <a href="../calendario.jsp" class="btn btn-info">📅 Consultar Calendario</a>
                            <a href="../formatos.jsp" class="btn btn-primary">📋 Descargar Formatos</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>