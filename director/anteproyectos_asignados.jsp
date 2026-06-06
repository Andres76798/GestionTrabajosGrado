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
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Anteproyectos Asignados - Director</title>
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
                    <h2>📝 Anteproyectos Asignados</h2>
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
                    
                    String error = request.getParameter("error");
                    if (error != null) {
                %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <%= "1".equals(error) ? "❌ No tienes permisos para acceder a ese proyecto" : 
                           "Error al procesar la solicitud" %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <%
                    }
                %>

                <!-- Estadísticas Rápidas -->
                <div class="row mb-4">
                    <%
                        try {
                            // Contar proyectos por estado
                            String sqlStats = "SELECT estado, COUNT(*) as total FROM anteproyectos WHERE director_id = ? GROUP BY estado";
                            PreparedStatement pstmtStats = conn.prepareStatement(sqlStats);
                            pstmtStats.setInt(1, usuarioId);
                            ResultSet rsStats = pstmtStats.executeQuery();
                            
                            int totalAsignados = 0;
                            int enRevision = 0;
                            int aprobados = 0;
                            int rechazados = 0;
                            
                            while (rsStats.next()) {
                                String estadoStat = rsStats.getString("estado");
                                int total = rsStats.getInt("total");
                                totalAsignados += total;
                                
                                if ("en_revision".equals(estadoStat)) {
                                    enRevision = total;
                                } else if ("aprobado_director".equals(estadoStat)) {
                                    aprobados = total;
                                } else if ("rechazado".equals(estadoStat)) {
                                    rechazados = total;
                                }
                            }
                            rsStats.close();
                            pstmtStats.close();
                    %>
                    <div class="col-md-3">
                        <div class="card text-white bg-primary">
                            <div class="card-body text-center">
                                <h4><%= totalAsignados %></h4>
                                <p>Total Asignados</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-warning">
                            <div class="card-body text-center">
                                <h4><%= enRevision %></h4>
                                <p>En Revisión</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-info">
                            <div class="card-body text-center">
                                <h4><%= aprobados %></h4>
                                <p>Aprobados</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-success">
                            <div class="card-body text-center">
                                <h4><%= totalAsignados - (enRevision + aprobados + rechazados) %></h4>
                                <p>Por Evaluar</p>
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
                                <input type="text" class="form-control" name="estudiante" placeholder="Nombre o código">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Ordenar por</label>
                                <select class="form-select" name="orden">
                                    <option value="fecha_desc">Fecha (Más reciente)</option>
                                    <option value="fecha_asc">Fecha (Más antigua)</option>
                                    <option value="estudiante">Estudiante (A-Z)</option>
                                    <option value="estado">Estado</option>
                                    <option value="calificacion">Calificación</option>
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
                        <h5 class="mb-0">📚 Lista de Anteproyectos Asignados</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>ID</th>
                                        <th>Título</th>
                                        <th>Estudiante</th>
                                        <th>Programa</th>
                                        <th>Estado</th>
                                        <th>Mi Calificación</th>
                                        <th>Cal. Evaluador</th>
                                        <th>Evaluador</th>
                                        <th>Fecha Asignación</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String filtroEstado = request.getParameter("estado");
                                            String filtroEstudiante = request.getParameter("estudiante");
                                            String orden = request.getParameter("orden");
                                            
                                            StringBuilder sql = new StringBuilder(
                                                "SELECT a.id, a.titulo, a.estado, a.calificacion_director, a.calificacion_evaluador, a.fecha_creacion, " +
                                                "e.codigo as est_codigo, e.nombre as estudiante, e.programa_academico as programa, " +
                                                "ev.nombre as evaluador " +
                                                "FROM anteproyectos a " +
                                                "LEFT JOIN usuarios e ON a.estudiante_id = e.id " +
                                                "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                                                "WHERE a.director_id = ?"
                                            );
                                            
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                sql.append(" AND a.estado = ?");
                                            }
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                sql.append(" AND (e.codigo LIKE ? OR e.nombre LIKE ?)");
                                            }
                                            
                                            // Ordenamiento
                                            if (orden != null && !orden.isEmpty()) {
                                                switch (orden) {
                                                    case "fecha_asc":
                                                        sql.append(" ORDER BY a.fecha_creacion ASC");
                                                        break;
                                                    case "estudiante":
                                                        sql.append(" ORDER BY e.nombre ASC");
                                                        break;
                                                    case "estado":
                                                        sql.append(" ORDER BY a.estado ASC");
                                                        break;
                                                    case "calificacion":
                                                        sql.append(" ORDER BY a.calificacion_director DESC");
                                                        break;
                                                    default:
                                                        sql.append(" ORDER BY a.fecha_creacion DESC");
                                                }
                                            } else {
                                                sql.append(" ORDER BY a.fecha_creacion DESC");
                                            }
                                            
                                            pstmt = conn.prepareStatement(sql.toString());
                                            int paramIndex = 1;
                                            pstmt.setInt(paramIndex++, usuarioId);
                                            
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                pstmt.setString(paramIndex++, filtroEstado);
                                            }
                                            if (filtroEstudiante != null && !filtroEstudiante.isEmpty()) {
                                                String likeParam = "%" + filtroEstudiante + "%";
                                                pstmt.setString(paramIndex++, likeParam);
                                                pstmt.setString(paramIndex++, likeParam);
                                            }
                                            
                                            rs = pstmt.executeQuery();
                                            
                                            if (!rs.isBeforeFirst()) {
                                    %>
                                        <tr>
                                            <td colspan="10" class="text-center text-muted py-4">
                                                <div class="py-4">
                                                    <h5>📝 No tienes anteproyectos asignados</h5>
                                                    <p class="text-muted">Los anteproyectos te serán asignados por coordinación.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                            
                                            while (rs.next()) {
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
                                            <td><%= rs.getString("programa") %></td>
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
                                                <%
                                                    Double calificacion = rs.getDouble("calificacion_director");
                                                    if (!rs.wasNull()) {
                                                        String colorCal = "text-success";
                                                        if (calificacion < 3.0) colorCal = "text-danger";
                                                        else if (calificacion < 3.5) colorCal = "text-warning";
                                                %>
                                                <strong class="<%= colorCal %>"><%= calificacion %>/5.0</strong>
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
                                                <%= rs.getString("evaluador") != null ? rs.getString("evaluador") : "<span class='text-warning'>No asignado</span>" %>
                                            </td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion")) %></td>
                                            <td>
                                                <div class="btn-group-vertical btn-group-sm">
                                                    <a href="ver_anteproyecto.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info btn-sm mb-1" title="Ver detalles">
                                                        👁️ Ver
                                                    </a>
                                                    <a href="calificar_anteproyecto.jsp?id=<%= rs.getInt("id") %>" 
                                                       class="btn btn-warning btn-sm mb-1" 
                                                       title="Calificar"
                                                       <%= "aprobado_evaluador".equals(estado) ? "disabled" : "" %>>
                                                        ⭐ Calificar
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='10' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
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

                <!-- Guía de Estados -->
                <div class="card mt-4">
                    <div class="card-header bg-light">
                        <h6 class="mb-0">📊 Guía de Estados</h6>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-md-2">
                                <span class="badge bg-secondary">Borrador</span>
                                <small class="d-block text-muted">Estudiante editando</small>
                            </div>
                            <div class="col-md-2">
                                <span class="badge bg-warning">En Revisión</span>
                                <small class="d-block text-muted">Esperando evaluación</small>
                            </div>
                            <div class="col-md-2">
                                <span class="badge bg-info">Aprobado Director</span>
                                <small class="d-block text-muted">Listo para evaluador</small>
                            </div>
                            <div class="col-md-2">
                                <span class="badge bg-success">Aprobado Evaluador</span>
                                <small class="d-block text-muted">Proceso finalizado</small>
                            </div>
                            <div class="col-md-2">
                                <span class="badge bg-danger">Rechazado</span>
                                <small class="d-block text-muted">Requiere correcciones</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información Importante -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">💡 Proceso de Evaluación</h6>
                            </div>
                            <div class="card-body">
                                <ol class="mb-0">
                                    <li><strong>Revisar</strong> el anteproyecto completo</li>
                                    <li><strong>Calificar</strong> en escala de 0.0 a 5.0</li>
                                    <li><strong>Agregar observaciones</strong> constructivas</li>
                                    <li><strong>Decidir</strong>: Seguir revisión, Aprobar o Rechazar</li>
                                    <li><strong>Asignar evaluador</strong> si se aprueba</li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">⏰ Plazos Importantes</h6>
                            </div>
                            <div class="card-body">
                                <ul class="mb-0">
                                    <li>Revisión inicial: <strong>15 días hábiles</strong></li>
                                    <li>Revisión de correcciones: <strong>7 días hábiles</strong></li>
                                    <li>Comunicación al estudiante: <strong>48 horas</strong> después de evaluación</li>
                                    <li>Consulta el <a href="../calendario.jsp" class="alert-link">calendario académico</a> para fechas específicas</li>
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
            const estadoFiltro = urlParams.get('estado');
            const estudianteFiltro = urlParams.get('estudiante');
            const ordenFiltro = urlParams.get('orden');
            
            if (estadoFiltro) {
                document.querySelector('select[name="estado"]').value = estadoFiltro;
            }
            if (estudianteFiltro) {
                document.querySelector('input[name="estudiante"]').value = estudianteFiltro;
            }
            if (ordenFiltro) {
                document.querySelector('select[name="orden"]').value = ordenFiltro;
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