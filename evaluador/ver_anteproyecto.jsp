<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    if (usuarioRol == null || !"evaluador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("anteproyectos_evaluar.jsp");
        return;
    }

    // Cargar datos del anteproyecto
    String titulo = "", descripcion = "", objetivoGeneral = "", objetivosEspecificos = "", justificacion = "", metodologia = "";
    String estado = "", calificacionDirector = "", calificacionEvaluador = "", observacionesDirector = "", observacionesEvaluador = "";
    String estudianteNombre = "", estudianteCodigo = "", estudiantePrograma = "", directorNombre = "", directorEmail = "";
    String fechaCreacion = "", fechaActualizacion = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, a.calificacion_director, a.calificacion_evaluador, a.observaciones_director, a.observaciones_evaluador, " +
                   "a.fecha_creacion, a.fecha_actualizacion, " +
                   "e.codigo as est_codigo, e.nombre as estudiante, e.programa_academico as programa, " +
                   "d.nombre as director, d.email as director_email " +
                   "FROM anteproyectos a " +
                   "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                   "LEFT JOIN usuarios d ON a.director_id = d.id " +
                   "WHERE a.id = ? AND a.estado = 'aprobado_director' AND (a.evaluador_id = ? OR a.evaluador_id IS NULL)";
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
            estudianteNombre = rs.getString("estudiante");
            estudianteCodigo = rs.getString("est_codigo");
            estudiantePrograma = rs.getString("programa");
            directorNombre = rs.getString("director");
            directorEmail = rs.getString("director_email");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_creacion"));
            fechaActualizacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_actualizacion"));
        } else {
            response.sendRedirect("anteproyectos_evaluar.jsp?error=1");
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
    <title>Ver Anteproyecto - Evaluador</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Evaluador)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>👁️ Detalles del Anteproyecto</h2>
                    <div>
                        <a href="anteproyectos_evaluar.jsp" class="btn btn-secondary">← Volver</a>
                        <%
                            if (calificacionEvaluador == null) {
                        %>
                        <a href="evaluar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">⭐ Evaluar</a>
                        <%
                            } else {
                        %>
                        <a href="evaluar_anteproyecto.jsp?id=<%= id %>" class="btn btn-info">📋 Ver Evaluación</a>
                        <%
                            }
                        %>
                        <a href="../calendario.jsp" class="btn btn-info">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-primary">📋 Formatos</a>
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
                                <p class="text-muted">ID: #<%= id %></p>
                            </div>
                            <div class="col-md-4 text-end">
                                <span class="badge bg-info fs-6">Aprobado por Director</span>
                            </div>
                        </div>
                        
                        <div class="row mt-3">
                            <div class="col-md-4">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Estudiante:</th>
                                        <td>
                                            <strong><%= estudianteNombre %></strong><br>
                                            <small class="text-muted"><%= estudianteCodigo %></small>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Programa:</th>
                                        <td><%= estudiantePrograma %></td>
                                    </tr>
                                    <tr>
                                        <th>Fecha Envío:</th>
                                        <td><%= fechaCreacion %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-4">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Director:</th>
                                        <td><%= directorNombre %></td>
                                    </tr>
                                    <tr>
                                        <th>Email Director:</th>
                                        <td><%= directorEmail %></td>
                                    </tr>
                                    <tr>
                                        <th>Última Actualización:</th>
                                        <td><%= fechaActualizacion %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-4">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Cal. Director:</th>
                                        <td>
                                            <strong class="text-success"><%= calificacionDirector %>/5.0</strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Mi Calificación:</th>
                                        <td>
                                            <strong class="<%= calificacionEvaluador != null ? "text-success" : "text-muted" %>">
                                                <%= calificacionEvaluador != null ? calificacionEvaluador + "/5.0" : "Pendiente" %>
                                            </strong>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Estado:</th>
                                        <td>
                                            <span class="badge <%= calificacionEvaluador != null ? "bg-success" : "bg-warning" %>">
                                                <%= calificacionEvaluador != null ? "Evaluado" : "Por Evaluar" %>
                                            </span>
                                        </td>
                                    </tr>
                                </table>
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
                        <div class="row">
                            <div class="col-md-6">
                                <h6>📋 Descripción General:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= descripcion != null ? descripcion : "<span class='text-muted'>No disponible</span>" %>
                                </div>
                                
                                <h6>🎯 Objetivo General:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= objetivoGeneral != null ? objetivoGeneral : "<span class='text-muted'>No disponible</span>" %>
                                </div>
                                
                                <h6>📌 Objetivos Específicos:</h6>
                                <div class="border p-3 bg-light rounded">
                                    <%= objetivosEspecificos != null ? objetivosEspecificos.replace("\n", "<br>") : "<span class='text-muted'>No disponible</span>" %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <h6>💡 Justificación:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= justificacion != null ? justificacion : "<span class='text-muted'>No disponible</span>" %>
                                </div>
                                
                                <h6>🔬 Metodología:</h6>
                                <div class="border p-3 bg-light rounded">
                                    <%= metodologia != null ? metodologia : "<span class='text-muted'>No disponible</span>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Observaciones -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">📋 Observaciones del Director</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <%= observacionesDirector != null ? observacionesDirector.replace("\n", "<br>") : 
                                       "<div class='text-center text-muted'><p>📝</p><p>El director no dejó observaciones</p></div>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">⭐ Mis Observaciones</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <%= observacionesEvaluador != null ? observacionesEvaluador.replace("\n", "<br>") : 
                                       "<div class='text-center text-muted'><p>⏳</p><p>No has evaluado este proyecto aún</p></div>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="card">
                    <div class="card-body text-center">
                        <div class="btn-group">
                            <a href="anteproyectos_evaluar.jsp" class="btn btn-secondary">← Volver a la Lista</a>
                            <%
                                if (calificacionEvaluador == null) {
                            %>
                            <a href="evaluar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">⭐ Evaluar Anteproyecto</a>
                            <%
                                } else {
                            %>
                            <a href="evaluar_anteproyecto.jsp?id=<%= id %>" class="btn btn-info">📋 Ver/Editar Evaluación</a>
                            <%
                                }
                            %>
                            <a href="../calendario.jsp" class="btn btn-info">📅 Consultar Calendario</a>
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