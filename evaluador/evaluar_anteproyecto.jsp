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
    String estudianteNombre = "", estudianteCodigo = "", estudiantePrograma = "", directorNombre = "";
    String fechaCreacion = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, a.calificacion_director, a.calificacion_evaluador, a.observaciones_director, a.observaciones_evaluador, " +
                   "a.fecha_creacion, " +
                   "e.codigo as est_codigo, e.nombre as estudiante, e.programa_academico as programa, " +
                   "d.nombre as director " +
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
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion"));
        } else {
            response.sendRedirect("anteproyectos_evaluar.jsp?error=1");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }

    // Procesar evaluación
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevaCalificacion = request.getParameter("calificacion");
        String nuevasObservaciones = request.getParameter("observaciones");
        String decision = request.getParameter("decision");
        
        try {
            String nuevoEstado = "aprobado_director"; // Por defecto
            
            if ("aprobar".equals(decision)) {
                nuevoEstado = "aprobado_evaluador";
            } else if ("rechazar".equals(decision)) {
                nuevoEstado = "rechazado";
            }
            
            // Si el proyecto no estaba asignado, asignarlo al evaluador
            String sql = "UPDATE anteproyectos SET calificacion_evaluador = ?, observaciones_evaluador = ?, estado = ?, evaluador_id = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nuevaCalificacion);
            pstmt.setString(2, nuevasObservaciones);
            pstmt.setString(3, nuevoEstado);
            pstmt.setInt(4, usuarioId);
            pstmt.setString(5, id);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("anteproyectos_evaluar.jsp?mensaje=1");
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
    <title>Evaluar Anteproyecto - Evaluador</title>
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
                    <h2>⭐ Evaluar Anteproyecto</h2>
                    <div>
                        <a href="anteproyectos_evaluar.jsp" class="btn btn-secondary">← Volver</a>
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
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contenido del Anteproyecto -->
                <div class="card mb-4">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">📝 Contenido del Anteproyecto</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>📋 Descripción General:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= descripcion != null ? descripcion : "No disponible" %>
                                </div>
                                
                                <h6>🎯 Objetivo General:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= objetivoGeneral != null ? objetivoGeneral : "No disponible" %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <h6>💡 Justificación:</h6>
                                <div class="border p-3 bg-light rounded mb-3">
                                    <%= justificacion != null ? justificacion : "No disponible" %>
                                </div>
                                
                                <h6>🔬 Metodología:</h6>
                                <div class="border p-3 bg-light rounded">
                                    <%= metodologia != null ? metodologia : "No disponible" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mt-3">
                            <h6>📌 Objetivos Específicos:</h6>
                            <div class="border p-3 bg-light rounded">
                                <%= objetivosEspecificos != null ? objetivosEspecificos.replace("\n", "<br>") : "No disponible" %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Observaciones del Director -->
                <div class="card mb-4">
                    <div class="card-header bg-warning text-white">
                        <h5 class="mb-0">📋 Observaciones del Director</h5>
                    </div>
                    <div class="card-body">
                        <div class="border p-3 bg-light rounded">
                            <%= observacionesDirector != null ? observacionesDirector.replace("\n", "<br>") : 
                               "<div class='text-center text-muted'><p>El director no dejó observaciones</p></div>" %>
                        </div>
                    </div>
                </div>

                <!-- Formulario de Evaluación -->
                <form method="POST">
                    <div class="card">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">⭐ Evaluación Final</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Calificación Final (0-5) *</label>
                                        <input type="number" class="form-control" name="calificacion" 
                                               min="0" max="5" step="0.1" value="<%= calificacionEvaluador != null ? calificacionEvaluador : "" %>" required>
                                        <div class="form-text">Califica el anteproyecto en una escala de 0.0 a 5.0</div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Observaciones Detalladas *</label>
                                        <textarea class="form-control" name="observaciones" rows="6" required 
                                                  placeholder="Escribe tus observaciones, recomendaciones y evaluación detallada..."><%= observacionesEvaluador != null ? observacionesEvaluador : "" %></textarea>
                                        <div class="form-text">Incluye comentarios constructivos para el estudiante y coordinación</div>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Decisión Final *</label>
                                        <select class="form-select" name="decision" id="decisionSelect" required>
                                            <option value="">Seleccionar decisión</option>
                                            <option value="aprobar">✅ Aprobar Anteproyecto</option>
                                            <option value="rechazar">❌ Rechazar Anteproyecto</option>
                                        </select>
                                        <div class="form-text">Determina la aprobación final del anteproyecto</div>
                                    </div>
                                    
                                    <!-- Información de la decisión -->
                                    <div id="infoAprobar" class="alert alert-success" style="display: none;">
                                        <h6>✅ Aprobar Anteproyecto</h6>
                                        <p class="mb-0">El anteproyecto será <strong>aprobado definitivamente</strong>.</p>
                                        <p class="mb-0">El estudiante y coordinación serán notificados.</p>
                                        <p class="mb-0">El proceso de anteproyecto finalizará.</p>
                                    </div>
                                    
                                    <div id="infoRechazar" class="alert alert-danger" style="display: none;">
                                        <h6>❌ Rechazar Anteproyecto</h6>
                                        <p class="mb-0">El anteproyecto será <strong>rechazado</strong>.</p>
                                        <p class="mb-0">El estudiante deberá realizar correcciones significativas.</p>
                                        <p class="mb-0">El proceso volverá a etapa de director.</p>
                                    </div>
                                    
                                    <!-- Criterios de Evaluación -->
                                    <div class="card">
                                        <div class="card-header bg-light">
                                            <h6 class="mb-0">📊 Criterios de Evaluación</h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="row small">
                                                <div class="col-6">
                                                    <strong>Calidad académica (30%)</strong>
                                                    <ul class="mb-2">
                                                        <li>Rigor investigativo</li>
                                                        <li>Revisión bibliográfica</li>
                                                        <li>Fundamentación teórica</li>
                                                    </ul>
                                                </div>
                                                <div class="col-6">
                                                    <strong>Metodología (25%)</strong>
                                                    <ul class="mb-2">
                                                        <li>Viabilidad técnica</li>
                                                        <li>Plan de trabajo</li>
                                                        <li>Recursos necesarios</li>
                                                    </ul>
                                                </div>
                                                <div class="col-6">
                                                    <strong>Innovación (20%)</strong>
                                                    <ul class="mb-2">
                                                        <li>Aportes al conocimiento</li>
                                                        <li>Originalidad</li>
                                                        <li>Relevancia</li>
                                                    </ul>
                                                </div>
                                                <div class="col-6">
                                                    <strong>Estructura (15%)</strong>
                                                    <ul class="mb-2">
                                                        <li>Coherencia interna</li>
                                                        <li>Claridad expositiva</li>
                                                        <li>Formato adecuado</li>
                                                    </ul>
                                                </div>
                                                <div class="col-12">
                                                    <strong>Aplicabilidad (10%)</strong>
                                                    <ul class="mb-0">
                                                        <li>Impacto práctico</li>
                                                        <li>Transferencia</li>
                                                        <li>Beneficios</li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-body">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="anteproyectos_evaluar.jsp" class="btn btn-secondary me-md-2">❌ Cancelar</a>
                                <button type="submit" class="btn btn-success">✅ Guardar Evaluación Final</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const decisionSelect = document.getElementById('decisionSelect');
            const infoAprobar = document.getElementById('infoAprobar');
            const infoRechazar = document.getElementById('infoRechazar');
            
            function updateDecisionInfo() {
                // Ocultar todos primero
                infoAprobar.style.display = 'none';
                infoRechazar.style.display = 'none';
                
                // Mostrar según la selección
                const decision = decisionSelect.value;
                if (decision === 'aprobar') {
                    infoAprobar.style.display = 'block';
                } else if (decision === 'rechazar') {
                    infoRechazar.style.display = 'block';
                }
            }
            
            decisionSelect.addEventListener('change', updateDecisionInfo);
            
            // Ejecutar al cargar la página por si hay un valor preselected
            updateDecisionInfo();
        });
    </script>
</body>
</html>