<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    if (usuarioRol == null || !"director".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("anteproyectos_asignados.jsp");
        return;
    }

    // Cargar datos del anteproyecto y información del alumno
    String titulo = "", descripcion = "", objetivoGeneral = "", objetivosEspecificos = "", justificacion = "", metodologia = "";
    String estado = "", calificacionDirector = "", calificacionEvaluador = "", observacionesDirector = "", observacionesEvaluador = "";
    String estudianteNombre = "", estudianteCodigo = "", estudianteEmail = "", estudiantePrograma = "", estudianteTelefono = "";
    String fechaCreacion = "", fechaActualizacion = "", evaluadorNombre = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, a.calificacion_director, a.calificacion_evaluador, a.observaciones_director, a.observaciones_evaluador, " +
                   "a.fecha_creacion, a.fecha_actualizacion, " +
                   "e.codigo as est_codigo, e.nombre as estudiante, e.email as est_email, " +
                   "e.programa_academico as est_programa, e.telefono as est_telefono, " +
                   "ev.nombre as evaluador " +
                   "FROM anteproyectos a " +
                   "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                   "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                   "WHERE a.id = ? AND a.director_id = ?";
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
            estudianteEmail = rs.getString("est_email");
            estudiantePrograma = rs.getString("est_programa");
            estudianteTelefono = rs.getString("est_telefono");
            evaluadorNombre = rs.getString("evaluador");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_creacion"));
            fechaActualizacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_actualizacion"));
        } else {
            response.sendRedirect("anteproyectos_asignados.jsp?error=1");
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
    <title>Ver Anteproyecto - Director</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Director)
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
                        <a href="anteproyectos_asignados.jsp" class="btn btn-secondary">← Volver</a>
                        <a href="calificar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">⭐ Calificar</a>
                        <a href="../calendario.jsp" class="btn btn-info">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-primary">📋 Formatos</a>
                    </div>
                </div>

                <!-- Información del Estudiante -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">🎓 Información del Estudiante</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Nombre:</th>
                                        <td><strong><%= estudianteNombre %></strong></td>
                                    </tr>
                                    <tr>
                                        <th>Código:</th>
                                        <td><%= estudianteCodigo %></td>
                                    </tr>
                                    <tr>
                                        <th>Programa:</th>
                                        <td><%= estudiantePrograma %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Email:</th>
                                        <td><%= estudianteEmail %></td>
                                    </tr>
                                    <tr>
                                        <th>Teléfono:</th>
                                        <td><%= estudianteTelefono != null ? estudianteTelefono : "No disponible" %></td>
                                    </tr>
                                    <tr>
                                        <th>Contacto:</th>
                                        <td>
                                            <a href="mailto:<%= estudianteEmail %>" class="btn btn-sm btn-outline-primary">📧 Email</a>
                                            <% if (estudianteTelefono != null) { %>
                                            <a href="tel:<%= estudianteTelefono %>" class="btn btn-sm btn-outline-success">📞 Llamar</a>
                                            <% } %>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información General del Proyecto -->
                <div class="card mb-4">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">📋 Información del Proyecto</h5>
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
                                        <th>Evaluador Asignado:</th>
                                        <td><%= evaluadorNombre != null ? evaluadorNombre : "<span class='text-warning'>No asignado</span>" %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Mi Calificación:</th>
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
                                    <tr>
                                        <th>Calificación Final:</th>
                                        <td>
                                            <%
                                                if (calificacionDirector != null && calificacionEvaluador != null) {
                                                    double calDir = Double.parseDouble(calificacionDirector);
                                                    double calEval = Double.parseDouble(calificacionEvaluador);
                                                    double promedio = (calDir + calEval) / 2;
                                                    String colorFinal = promedio >= 3.5 ? "text-success" : promedio >= 3.0 ? "text-warning" : "text-danger";
                                            %>
                                            <strong class="<%= colorFinal %>"><%= String.format("%.1f", promedio) %>/5.0</strong>
                                            <%
                                                } else {
                                            %>
                                            <span class="text-muted">Pendiente</span>
                                            <%
                                                }
                                            %>
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

                <!-- Observaciones y Evaluaciones -->
                <div class="row mb-4">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">📋 Mis Observaciones</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <%= observacionesDirector != null ? observacionesDirector.replace("\n", "<br>") : 
                                       "<div class='text-center text-muted'><p>📝</p><p>No has agregado observaciones aún</p></div>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">⭐ Observaciones del Evaluador</h6>
                            </div>
                            <div class="card-body">
                                <div class="border p-3 bg-light rounded" style="min-height: 200px;">
                                    <%= observacionesEvaluador != null ? observacionesEvaluador.replace("\n", "<br>") : 
                                       "<div class='text-center text-muted'><p>⏳</p><p>No hay observaciones del evaluador</p></div>" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Acciones -->
                <div class="card">
                    <div class="card-body text-center">
                        <div class="btn-group">
                            <a href="anteproyectos_asignados.jsp" class="btn btn-secondary">← Volver a la Lista</a>
                            <a href="calificar_anteproyecto.jsp?id=<%= id %>" class="btn btn-warning">⭐ Calificar/Editar Evaluación</a>
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