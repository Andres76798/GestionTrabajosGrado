<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"coordinacion".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informes - Coordinación</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Coordinación)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <h2 class="mb-4">📊 Informes y Reportes</h2>

                <!-- Estadísticas generales -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card text-white bg-primary">
                            <div class="card-body text-center">
                                <h4>
                                    <%
                                        try {
                                            String sql = "SELECT COUNT(*) as total FROM anteproyectos";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) out.print(rs.getInt("total"));
                                        } catch (Exception e) { out.print("0"); }
                                    %>
                                </h4>
                                <p>Total Anteproyectos</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-success">
                            <div class="card-body text-center">
                                <h4>
                                    <%
                                        try {
                                            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'aprobado_evaluador'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) out.print(rs.getInt("total"));
                                        } catch (Exception e) { out.print("0"); }
                                    %>
                                </h4>
                                <p>Aprobados</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-warning">
                            <div class="card-body text-center">
                                <h4>
                                    <%
                                        try {
                                            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'en_revision'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) out.print(rs.getInt("total"));
                                        } catch (Exception e) { out.print("0"); }
                                    %>
                                </h4>
                                <p>En Revisión</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-white bg-danger">
                            <div class="card-body text-center">
                                <h4>
                                    <%
                                        try {
                                            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'rechazado'";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            if (rs.next()) out.print(rs.getInt("total"));
                                        } catch (Exception e) { out.print("0"); }
                                    %>
                                </h4>
                                <p>Rechazados</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Informes por rol -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">🎓 Informe por Estudiantes</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Estudiante</th>
                                                <th>Proyectos</th>
                                                <th>Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                try {
                                                    String sql = "SELECT e.codigo, e.nombre, COUNT(a.id) as total_proyectos, " +
                                                               "SUM(CASE WHEN a.estado = 'aprobado_evaluador' THEN 1 ELSE 0 END) as aprobados " +
                                                               "FROM usuarios e " +
                                                               "LEFT JOIN anteproyectos a ON e.id = a.estudiante_id " +
                                                               "WHERE e.rol = 'estudiante' AND e.estado = 'activo' " +
                                                               "GROUP BY e.id, e.codigo, e.nombre " +
                                                               "ORDER BY total_proyectos DESC";
                                                    pstmt = conn.prepareStatement(sql);
                                                    rs = pstmt.executeQuery();
                                                    while (rs.next()) {
                                            %>
                                            <tr>
                                                <td>
                                                    <div><strong><%= rs.getString("nombre") %></strong></div>
                                                    <small class="text-muted"><%= rs.getString("codigo") %></small>
                                                </td>
                                                <td><span class="badge bg-primary"><%= rs.getInt("total_proyectos") %></span></td>
                                                <td>
                                                    <span class="badge <%= rs.getInt("aprobados") > 0 ? "bg-success" : "bg-warning" %>">
                                                        <%= rs.getInt("aprobados") > 0 ? "Con aprobados" : "En proceso" %>
                                                    </span>
                                                </td>
                                            </tr>
                                            <%
                                                    }
                                                } catch (Exception e) {
                                                    out.println("<tr><td colspan='3' class='text-center'>Error al cargar datos</td></tr>");
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h5 class="mb-0">🧑‍🏫 Informe por Directores</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Director</th>
                                                <th>Proyectos</th>
                                                <th>En Revisión</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                try {
                                                    String sql = "SELECT d.nombre, COUNT(a.id) as total_proyectos, " +
                                                               "SUM(CASE WHEN a.estado = 'en_revision' THEN 1 ELSE 0 END) as en_revision " +
                                                               "FROM usuarios d " +
                                                               "LEFT JOIN anteproyectos a ON d.id = a.director_id " +
                                                               "WHERE d.rol = 'director' AND d.estado = 'activo' " +
                                                               "GROUP BY d.id, d.nombre " +
                                                               "ORDER BY total_proyectos DESC";
                                                    pstmt = conn.prepareStatement(sql);
                                                    rs = pstmt.executeQuery();
                                                    while (rs.next()) {
                                            %>
                                            <tr>
                                                <td><strong><%= rs.getString("nombre") %></strong></td>
                                                <td><span class="badge bg-primary"><%= rs.getInt("total_proyectos") %></span></td>
                                                <td><span class="badge bg-warning"><%= rs.getInt("en_revision") %></span></td>
                                            </tr>
                                            <%
                                                    }
                                                } catch (Exception e) {
                                                    out.println("<tr><td colspan='3' class='text-center'>Error al cargar datos</td></tr>");
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Informe de evaluadores -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">⭐ Informe por Evaluadores</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Evaluador</th>
                                                <th>Proyectos Asignados</th>
                                                <th>Por Evaluar</th>
                                                <th>Aprobados</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                try {
                                                    String sql = "SELECT ev.nombre, COUNT(a.id) as total_asignados, " +
                                                               "SUM(CASE WHEN a.estado = 'aprobado_director' THEN 1 ELSE 0 END) as por_evaluar, " +
                                                               "SUM(CASE WHEN a.estado = 'aprobado_evaluador' THEN 1 ELSE 0 END) as aprobados " +
                                                               "FROM usuarios ev " +
                                                               "LEFT JOIN anteproyectos a ON ev.id = a.evaluador_id " +
                                                               "WHERE ev.rol = 'evaluador' AND ev.estado = 'activo' " +
                                                               "GROUP BY ev.id, ev.nombre " +
                                                               "ORDER BY total_asignados DESC";
                                                    pstmt = conn.prepareStatement(sql);
                                                    rs = pstmt.executeQuery();
                                                    while (rs.next()) {
                                            %>
                                            <tr>
                                                <td><strong><%= rs.getString("nombre") %></strong></td>
                                                <td><span class="badge bg-primary"><%= rs.getInt("total_asignados") %></span></td>
                                                <td><span class="badge bg-warning"><%= rs.getInt("por_evaluar") %></span></td>
                                                <td><span class="badge bg-success"><%= rs.getInt("aprobados") %></span></td>
                                            </tr>
                                            <%
                                                    }
                                                } catch (Exception e) {
                                                    out.println("<tr><td colspan='4' class='text-center'>Error al cargar datos</td></tr>");
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
        </div>
    </div>
</body>
</html>