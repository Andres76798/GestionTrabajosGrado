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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anteproyectos a Evaluar - Evaluador</title>
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
                    <h2>⭐ Anteproyectos a Evaluar</h2>
                    <div>
                        <a href="../calendario.jsp" class="btn btn-info">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-primary">📋 Formatos</a>
                    </div>
                </div>

                <%
                    String mensaje = request.getParameter("mensaje");
                    if (mensaje != null) {
                %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <%= "1".equals(mensaje) ? "✅ Evaluación guardada exitosamente" : 
                           "2".equals(mensaje) ? "✏️ Evaluación actualizada exitosamente" : "" %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <%
                    }
                %>

                <!-- Estadísticas Rápidas -->
                <div class="row mb-4">
                    <%
                        try {
                            // Contar proyectos por estado asignados al evaluador
                            String sqlStats = "SELECT estado, COUNT(*) as total FROM anteproyectos WHERE evaluador_id = ? OR (estado = 'aprobado_director' AND evaluador_id IS NULL) GROUP BY estado";
                            PreparedStatement pstmtStats = conn.prepareStatement(sqlStats);
                            pstmtStats.setInt(1, usuarioId);
                            ResultSet rsStats = pstmtStats.executeQuery();
                            
                            int totalAsignados = 0;
                            int porEvaluar = 0;
                            int evaluados = 0;
                            
                            while (rsStats.next()) {
                                String estadoStat = rsStats.getString("estado");
                                int total = rsStats.getInt("total");
                                totalAsignados += total;
                                
                                if ("aprobado_director".equals(estadoStat)) {
                                    porEvaluar = total;
                                } else if ("aprobado_evaluador".equals(estadoStat)) {
                                    evaluados = total;
                                }
                            }
                            
                            // Contar proyectos sin evaluador asignado pero aprobados por director
                            String sqlSinAsignar = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'aprobado_director' AND evaluador_id IS NULL";
                            PreparedStatement pstmtSinAsignar = conn.prepareStatement(sqlSinAsignar);
                            ResultSet rsSinAsignar = pstmtSinAsignar.executeQuery();
                            int sinAsignar = 0;
                            if (rsSinAsignar.next()) {
                                sinAsignar = rsSinAsignar.getInt("total");
                            }
                            rsSinAsignar.close();
                            pstmtSinAsignar.close();
                    %>
                    <div class="col-md-3">
                        <div class="card text-white bg-primary">
                            <div class="card-body text-center">
                                <h4><%= totalAsignados + sinAsignar %></h4>
                                <p>Disponibles</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-warning">
                            <div class="card-body text-center">
                                <h4><%= porEvaluar + sinAsignar %></h4>
                                <p>Por Evaluar</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-info">
                            <div class="card-body text-center">
                                <h4><%= totalAsignados %></h4>
                                <p>Asignados a Mí</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-success">
                            <div class="card-body text-center">
                                <h4><%= evaluados %></h4>
                                <p>Evaluados</p>
                            </div>
                        </div>
                    </div>
                    <%
                        } catch (Exception e) {
                            out.println("<!-- Error en estadísticas: " + e.getMessage() + " -->");
                        }
                    %>
                </div>

                <!-- Filtros -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">🔍 Filtros de Búsqueda</h5>
                    </div>
                    <div class="card-body">
                        <form method="GET" class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">Tipo</label>
                                <select class="form-select" name="tipo">
                                    <option value="">Todos los proyectos</option>
                                    <option value="asignados">Asignados a mí</option>
                                    <option value="disponibles">Disponibles</option>
                                    <option value="evaluados">Ya evaluados</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Estudiante</label>
                                <input type="text" class="form-control" name="estudiante" placeholder="Nombre o código">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Director</label>
                                <input type="text" class="form-control" name="director" placeholder="Nombre del director">
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
                        <h5 class="mb-0">📚 Anteproyectos Aprobados por Director</h5>
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
                                        <th>Cal. Director</th>
                                        <th>Mi Calificación</th>
                                        <th>Estado</th>
                                        <th>Fecha Aprobación</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String filtroTipo = request.getParameter("tipo");
                                            String filtroEstudiante = request.getParameter("estudiante");
                                            String filtroDirector = request.getParameter("director");
                                            
                                            StringBuilder sql = new StringBuilder(
                                                "SELECT a.id, a.titulo, a.estado, a.calificacion_director, a.calificacion_evaluador, a.fecha_actualizacion, " +
                                                "e.codigo as est_codigo, e.nombre as estudiante, " +
                                                "d.nombre as director " +
                                                "FROM anteproyectos a " +
                                                "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                                                "LEFT JOIN usuarios d ON a.director_id = d.id " +
                                                "WHERE a.estado = 'aprobado_director'"
                                            );
                                            
                                            if (filtroTipo != null && !filtroTipo.isEmpty()) {
                                                if ("asignados".equals(filtroTipo)) {
                                                    sql.append(" AND a.evaluador_id = ?");
                                                } else if ("evaluados".equals(filtroTipo)) {
                                                    sql.append(" AND a.evaluador_id = ? AND a.estado = 'aprobado_evaluador'");
                                                } else if ("disponibles".equals(filtroTipo)) {
                                                    sql.append(" AND a.evaluador_id IS NULL");
                                                }
                                            } else {
                                                // Por defecto mostrar todos los disponibles y asignados
                                                sql.append(" AND (a.evaluador_id IS NULL OR a.evaluador_id = ?)");
                                            }
                                            
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                sql.append(" AND (e.codigo LIKE ? OR e.nombre LIKE ?)");
                                            }
                                            if (filtroDirector != null && !filtroDirector.isEmpty()) {
                                                sql.append(" AND d.nombre LIKE ?");
                                            }
                                            
                                            sql.append(" ORDER BY a.fecha_actualizacion DESC");
                                            
                                            pstmt = conn.prepareStatement(sql.toString());
                                            int paramIndex = 1;
                                            
                                            if (filtroTipo != null && !filtroTipo.isEmpty()) {
                                                if (!"disponibles".equals(filtroTipo)) {
                                                    pstmt.setInt(paramIndex++, usuarioId);
                                                }
                                            } else {
                                                pstmt.setInt(paramIndex++, usuarioId);
                                            }
                                            
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                String likeParam = "%" + filtroEstudiante + "%";
                                                pstmt.setString(paramIndex++, likeParam);
                                                pstmt.setString(paramIndex++, likeParam);
                                            }
                                            if (filtroDirector != null && !filtroDirector.isEmpty()) {
                                                pstmt.setString(paramIndex++, "%" + filtroDirector + "%");
                                            }
                                            
                                            rs = pstmt.executeQuery();
                                            
                                            if (!rs.isBeforeFirst()) {
                                    %>
                                        <tr>
                                            <td colspan="9" class="text-center text-muted py-4">
                                                <div class="py-4">
                                                    <h5>📝 No hay anteproyectos para evaluar</h5>
                                                    <p class="text-muted">Los anteproyectos aprobados por directores aparecerán aquí.</p>
                                                    <a href="anteproyectos_evaluar.jsp" class="btn btn-primary mt-2">Actualizar Lista</a>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                            
                                            while (rs.next()) {
                                                boolean estaAsignado = rs.getString("calificacion_evaluador") != null || 
                                                                      (filtroTipo == null || "asignados".equals(filtroTipo) || "evaluados".equals(filtroTipo));
                                    %>
                                        <tr>
                                            <td><strong>#<%= rs.getInt("id") %></strong></td>
                                            <td>
                                                <div><strong><%= rs.getString("titulo") %></strong></div>
                                                <small class="text-muted">
                                                    <%= rs.getString("titulo").length() > 60 ? 
                                                        rs.getString("titulo").substring(0, 60) + "..." : 
                                                        rs.getString("titulo") %>
                                                </small>
                                            </td>
                                            <td>
                                                <div><strong><%= rs.getString("estudiante") %></strong></div>
                                                <small class="text-muted"><%= rs.getString("est_codigo") %></small>
                                            </td>
                                            <td><%= rs.getString("director") %></td>
                                            <td>
                                                <%
                                                    Double calificacionDir = rs.getDouble("calificacion_director");
                                                    if (!rs.wasNull()) {
                                                        String colorCal = "text-success";
                                                        if (calificacionDir < 3.0) colorCal = "text-danger";
                                                        else if (calificacionDir < 3.5) colorCal = "text-warning";
                                                %>
                                                <strong class="<%= colorCal %>"><%= calificacionDir %>/5.0</strong>
                                                <%
                                                    } else {
                                                %>
                                                <span class="text-muted">N/A</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td>
                                                <%
                                                    Double calificacionEval = rs.getDouble("calificacion_evaluador");
                                                    if (!rs.wasNull()) {
                                                        String colorCal = "text-success";
                                                        if (calificacionEval < 3.0) colorCal = "text-danger";
                                                        else if (calificacionEval < 3.5) colorCal = "text-warning";
                                                %>
                                                <strong class="<%= colorCal %>"><%= calificacionEval %>/5.0</strong>
                                                <%
                                                    } else {
                                                %>
                                                <span class="text-muted">Pendiente</span>
                                                <%
                                                    }
                                                %>
                                            </td>
                                            <td>
                                                <%
                                                    String estado = rs.getString("estado");
                                                    String badgeClass = "bg-info";
                                                    String estadoText = "Aprobado Director";
                                                    
                                                    if (calificacionEval != null) {
                                                        badgeClass = "bg-success";
                                                        estadoText = "Evaluado";
                                                    } else if (estaAsignado) {
                                                        badgeClass = "bg-warning";
                                                        estadoText = "Asignado a mí";
                                                    } else {
                                                        badgeClass = "bg-secondary";
                                                        estadoText = "Disponible";
                                                    }
                                                %>
                                                <span class="badge <%= badgeClass %>"><%= estadoText %></span>
                                            </td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_actualizacion")) %></td>
                                            <td>
                                                <div class="btn-group-vertical btn-group-sm">
                                                    <a href="ver_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info btn-sm mb-1" title="Ver detalles">
                                                        👁️ Ver
                                                    </a>
                                                    <%
                                                        if (calificacionEval == null) {
                                                            if (estaAsignado) {
                                                    %>
                                                    <a href="evaluar_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning btn-sm mb-1" title="Evaluar">
                                                        ⭐ Evaluar
                                                    </a>
                                                    <%
                                                            } else {
                                                    %>
                                                    <form method="POST" action="asignar_proyecto.jsp" style="display: inline;">
                                                        <input type="hidden" name="proyecto_id" value="<%= rs.getInt("id") %>">
                                                        <button type="submit" class="btn btn-success btn-sm mb-1" title="Tomar proyecto">
                                                            📥 Tomar
                                                        </button>
                                                    </form>
                                                    <%
                                                            }
                                                        } else {
                                                    %>
                                                    <a href="evaluar_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-secondary btn-sm mb-1" title="Ver evaluación">
                                                        📋 Ver Eval.
                                                    </a>
                                                    <%
                                                        }
                                                    %>
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

                <!-- Información del Proceso -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">💡 Proceso de Evaluación</h6>
                            </div>
                            <div class="card-body">
                                <ol class="mb-0">
                                    <li><strong>Revisar</strong> el anteproyecto completo</li>
                                    <li><strong>Evaluar</strong> según criterios establecidos</li>
                                    <li><strong>Calificar</strong> en escala de 0.0 a 5.0</li>
                                    <li><strong>Documentar observaciones</strong> detalladas</li>
                                    <li><strong>Tomar decisión final</strong>: Aprobar o Rechazar</li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">📊 Criterios de Evaluación</h6>
                            </div>
                            <div class="card-body">
                                <ul class="mb-0 small">
                                    <li><strong>Calidad académica</strong> (30%)</li>
                                    <li><strong>Metodología y viabilidad</strong> (25%)</li>
                                    <li><strong>Innovación y aportes</strong> (20%)</li>
                                    <li><strong>Estructura y redacción</strong> (15%)</li>
                                    <li><strong>Aplicabilidad práctica</strong> (10%)</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Marcar opciones seleccionadas en filtros
            const urlParams = new URLSearchParams(window.location.search);
            const tipoFiltro = urlParams.get('tipo');
            const estudianteFiltro = urlParams.get('estudiante');
            const directorFiltro = urlParams.get('director');
            
            if (tipoFiltro) {
                document.querySelector('select[name="tipo"]').value = tipoFiltro;
            }
            if (estudianteFiltro) {
                document.querySelector('input[name="estudiante"]').value = estudianteFiltro;
            }
            if (directorFiltro) {
                document.querySelector('input[name="director"]').value = directorFiltro;
            }
            
            // Auto-ocultar alerts después de 5 segundos
            setTimeout(function() {
                const alerts = document.querySelectorAll('.alert');
                alerts.forEach(alert => {
                    const bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                });
            }, 5000);
        });
    </script>
</body>
</html>