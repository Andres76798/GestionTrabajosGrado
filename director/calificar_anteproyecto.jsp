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
    String estado = "", calificacionDirector = "", observacionesDirector = "";
    String estudianteNombre = "", estudianteCodigo = "", estudianteEmail = "", estudiantePrograma = "", estudianteTelefono = "";
    String fechaCreacion = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, a.calificacion_director, a.observaciones_director, a.fecha_creacion, " +
                   "e.codigo as est_codigo, e.nombre as estudiante, e.email as est_email, " +
                   "e.programa_academico as est_programa, e.telefono as est_telefono " +
                   "FROM anteproyectos a " +
                   "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
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
            observacionesDirector = rs.getString("observaciones_director");
            estudianteNombre = rs.getString("estudiante");
            estudianteCodigo = rs.getString("est_codigo");
            estudianteEmail = rs.getString("est_email");
            estudiantePrograma = rs.getString("est_programa");
            estudianteTelefono = rs.getString("est_telefono");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion"));
        } else {
            response.sendRedirect("anteproyectos_asignados.jsp?error=1");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }

    // Procesar calificación
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String nuevaCalificacion = request.getParameter("calificacion");
        String nuevasObservaciones = request.getParameter("observaciones");
        String decision = request.getParameter("decision");
        String evaluadorId = request.getParameter("evaluador_id");
        
        try {
            String nuevoEstado = "en_revision"; // Por defecto sigue en revisión
            
            if ("aprobar".equals(decision)) {
                nuevoEstado = "aprobado_director";
            } else if ("rechazar".equals(decision)) {
                nuevoEstado = "rechazado";
            }
            
            String sql = "UPDATE anteproyectos SET calificacion_director = ?, observaciones_director = ?, estado = ?, evaluador_id = ? WHERE id = ? AND director_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nuevaCalificacion);
            pstmt.setString(2, nuevasObservaciones);
            pstmt.setString(3, nuevoEstado);
            pstmt.setString(4, "aprobar".equals(decision) ? evaluadorId : null);
            pstmt.setString(5, id);
            pstmt.setInt(6, usuarioId);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("anteproyectos_asignados.jsp?mensaje=1");
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
    <title>Calificar Anteproyecto - Director</title>
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
                    <h2>⭐ Calificar Anteproyecto</h2>
                    <div>
                        <a href="anteproyectos_asignados.jsp" class="btn btn-secondary">← Volver</a>
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
                                        <th>Fecha Envío:</th>
                                        <td><%= fechaCreacion %></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información del Anteproyecto -->
                <div class="card mb-4">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">📋 Información del Anteproyecto</h5>
                    </div>
                    <div class="card-body">
                        <h4 class="text-primary"><%= titulo %></h4>
                        
                        <div class="row mt-3">
                            <div class="col-md-6">
                                <h6>📝 Descripción General:</h6>
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

                <!-- Formulario de Calificación -->
                <form method="POST">
                    <div class="card">
                        <div class="card-header bg-warning text-white">
                            <h5 class="mb-0">📊 Evaluación del Anteproyecto</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Calificación (0-5) *</label>
                                        <input type="number" class="form-control" name="calificacion" 
                                               min="0" max="5" step="0.1" value="<%= calificacionDirector != null ? calificacionDirector : "" %>" required>
                                        <div class="form-text">Califica el anteproyecto en una escala de 0.0 a 5.0</div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Observaciones y Recomendaciones *</label>
                                        <textarea class="form-control" name="observaciones" rows="5" required 
                                                  placeholder="Escribe tus observaciones, recomendaciones y aspectos a mejorar..."><%= observacionesDirector != null ? observacionesDirector : "" %></textarea>
                                        <div class="form-text">Incluye comentarios constructivos para el estudiante</div>
                                    </div>
                                </div>
                                
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Decisión Final *</label>
                                        <select class="form-select" name="decision" id="decisionSelect" required>
                                            <option value="">Seleccionar decisión</option>
                                            <option value="seguir_revision">⏳ Seguir en Revisión</option>
                                            <option value="aprobar">✅ Aprobar para Evaluador</option>
                                            <option value="rechazar">❌ Rechazar</option>
                                        </select>
                                        <div class="form-text">Determina el estado del anteproyecto después de tu evaluación</div>
                                    </div>
                                    
                                    <!-- Selector de Evaluador (solo visible cuando se aprueba) -->
                                    <div class="mb-3" id="evaluadorContainer" style="display: none;">
                                        <label class="form-label">Asignar Evaluador *</label>
                                        <select class="form-select" name="evaluador_id">
                                            <option value="">Seleccionar evaluador</option>
                                            <%
                                                try {
                                                    String sqlEvaluadores = "SELECT id, nombre, programa_academico FROM usuarios WHERE rol = 'evaluador' AND estado = 'activo'";
                                                    PreparedStatement pstmtEval = conn.prepareStatement(sqlEvaluadores);
                                                    ResultSet rsEval = pstmtEval.executeQuery();
                                                    while (rsEval.next()) {
                                            %>
                                            <option value="<%= rsEval.getInt("id") %>">
                                                <%= rsEval.getString("nombre") %> - <%= rsEval.getString("programa_academico") %>
                                            </option>
                                            <%
                                                    }
                                                    rsEval.close();
                                                    pstmtEval.close();
                                                } catch (Exception e) {
                                                    out.println("<option value=''>Error al cargar evaluadores</option>");
                                                }
                                            %>
                                        </select>
                                        <div class="form-text">Selecciona el evaluador que revisará este anteproyecto</div>
                                    </div>
                                    
                                    <!-- Información de la decisión -->
                                    <div id="infoSeguir" class="alert alert-info" style="display: none;">
                                        <h6>⏳ Seguir en Revisión</h6>
                                        <p class="mb-0">El anteproyecto permanecerá en estado de revisión. El estudiante podrá realizar modificaciones basadas en tus observaciones.</p>
                                    </div>
                                    
                                    <div id="infoAprobar" class="alert alert-success" style="display: none;">
                                        <h6>✅ Aprobar para Evaluador</h6>
                                        <p class="mb-0">El anteproyecto será enviado al evaluador asignado para la evaluación final. El estudiante no podrá realizar más modificaciones.</p>
                                    </div>
                                    
                                    <div id="infoRechazar" class="alert alert-danger" style="display: none;">
                                        <h6>❌ Rechazar</h6>
                                        <p class="mb-0">El anteproyecto será rechazado. El estudiante deberá realizar correcciones significativas y volver a enviarlo.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Criterios de Evaluación -->
                    <div class="card mt-4">
                        <div class="card-header bg-light">
                            <h6 class="mb-0">📈 Criterios de Evaluación</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <h6>🎯 Claridad y Enfoque</h6>
                                    <ul class="small">
                                        <li>Objetivos claros y alcanzables</li>
                                        <li>Problema bien definido</li>
                                        <li>Alcance del proyecto</li>
                                    </ul>
                                </div>
                                <div class="col-md-4">
                                    <h6>🔬 Metodología</h6>
                                    <ul class="small">
                                        <li>Metodología apropiada</li>
                                        <li>Viabilidad técnica</li>
                                        <li>Plan de trabajo claro</li>
                                    </ul>
                                </div>
                                <div class="col-md-4">
                                    <h6>💡 Innovación y Relevancia</h6>
                                    <ul class="small">
                                        <li>Aportes al conocimiento</li>
                                        <li>Relevancia académica</li>
                                        <li>Aplicabilidad práctica</li>
                                    </ul>
                                </div>
                            </div>
                            
                            <div class="mt-3">
                                <h6>📊 Escala de Calificación:</h6>
                                <div class="row text-center">
                                    <div class="col">
                                        <span class="badge bg-danger">0.0 - 2.9</span>
                                        <small class="d-block">Insuficiente</small>
                                    </div>
                                    <div class="col">
                                        <span class="badge bg-warning">3.0 - 3.4</span>
                                        <small class="d-block">Aceptable</small>
                                    </div>
                                    <div class="col">
                                        <span class="badge bg-info">3.5 - 4.0</span>
                                        <small class="d-block">Bueno</small>
                                    </div>
                                    <div class="col">
                                        <span class="badge bg-success">4.1 - 5.0</span>
                                        <small class="d-block">Excelente</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-body">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="anteproyectos_asignados.jsp" class="btn btn-secondary me-md-2">❌ Cancelar</a>
                                <button type="submit" class="btn btn-primary">✅ Guardar Evaluación</button>
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
            const evaluadorContainer = document.getElementById('evaluadorContainer');
            const infoSeguir = document.getElementById('infoSeguir');
            const infoAprobar = document.getElementById('infoAprobar');
            const infoRechazar = document.getElementById('infoRechazar');
            
            function updateDecisionInfo() {
                // Ocultar todos primero
                evaluadorContainer.style.display = 'none';
                infoSeguir.style.display = 'none';
                infoAprobar.style.display = 'none';
                infoRechazar.style.display = 'none';
                
                // Mostrar según la selección
                const decision = decisionSelect.value;
                if (decision === 'seguir_revision') {
                    infoSeguir.style.display = 'block';
                } else if (decision === 'aprobar') {
                    evaluadorContainer.style.display = 'block';
                    infoAprobar.style.display = 'block';
                    // Hacer requerido el select de evaluador
                    evaluadorContainer.querySelector('select').required = true;
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