<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="includes/conexion.jspf" %>
<%
    // Verificar sesión
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Obtener estadísticas según el rol
    int totalAnteproyectos = 0;
    int misAnteproyectos = 0;
    int anteproyectosPendientes = 0;
    int anteproyectosAprobados = 0;
    int totalUsuarios = 0;
    
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    
    try {
        if ("administrador".equals(usuarioRol)) {
            // Estadísticas para administrador
            String sql = "SELECT COUNT(*) as total FROM anteproyectos";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalAnteproyectos = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM usuarios";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalUsuarios = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'aprobado_evaluador'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosAprobados = rs.getInt("total");
            }
            
        } else if ("coordinacion".equals(usuarioRol)) {
            // Estadísticas para coordinación
            String sql = "SELECT COUNT(*) as total FROM anteproyectos";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalAnteproyectos = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'en_revision'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosPendientes = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estado = 'aprobado_evaluador'";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosAprobados = rs.getInt("total");
            }
            
        } else if ("estudiante".equals(usuarioRol)) {
            // Estadísticas para estudiante
            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estudiante_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                misAnteproyectos = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estudiante_id = ? AND estado = 'aprobado_evaluador'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosAprobados = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estudiante_id = ? AND estado = 'en_revision'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosPendientes = rs.getInt("total");
            }
            
        } else if ("director".equals(usuarioRol)) {
            // Estadísticas para director
            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE director_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                misAnteproyectos = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE director_id = ? AND estado = 'en_revision'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosPendientes = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE director_id = ? AND estado = 'aprobado_director'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosAprobados = rs.getInt("total");
            }
            
        } else if ("evaluador".equals(usuarioRol)) {
            // Estadísticas para evaluador
            String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE evaluador_id = ? OR (estado = 'aprobado_director' AND evaluador_id IS NULL)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                misAnteproyectos = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE evaluador_id = ? AND estado = 'aprobado_director'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosPendientes = rs.getInt("total");
            }
            
            sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE evaluador_id = ? AND estado = 'aprobado_evaluador'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                anteproyectosAprobados = rs.getInt("total");
            }
        }
    } catch (Exception e) {
        out.println("<!-- Error al cargar estadísticas: " + e.getMessage() + " -->");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Gestión Trabajos de Grado UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="dashboard.jsp">
                <strong>🎓 UTS - Trabajos de Grado</strong>
            </a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    Bienvenido, <strong><%= session.getAttribute("usuario_nombre") %></strong> 
                    (<span class="text-warning"><%= session.getAttribute("usuario_rol") %></span>)
                </span>
                <a class="nav-link btn btn-outline-light btn-sm" href="logout.jsp">🚪 Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 d-md-block bg-dark sidebar">
                <div class="position-sticky pt-3">
                    <ul class="nav flex-column">
                        <%
                            String rol = (String) session.getAttribute("usuario_rol");
                            
                            if ("administrador".equals(rol)) {
                        %>
                            <li class="nav-item">
                                <a class="nav-link active text-white" href="admin/usuarios.jsp">
                                    <strong>👨‍💼 Gestión de Usuarios</strong>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="admin/crear_usuario.jsp">
                                    ➕ Crear Usuario
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="calendario.jsp">
                                    📅 Calendario Académico
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="formatos.jsp">
                                    📋 Formatos de Grado
                                </a>
                            </li>
                            
                        <%
                            } else if ("coordinacion".equals(rol)) {
                        %>
                            <li class="nav-item">
                                <a class="nav-link active text-white" href="coordinacion/anteproyectos.jsp">
                                    <strong>📋 Gestión de Anteproyectos</strong>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="coordinacion/crear_anteproyecto.jsp">
                                    ➕ Nuevo Anteproyecto
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="coordinacion/informes.jsp">
                                    📊 Informes y Reportes
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="calendario.jsp">
                                    📅 Calendario Académico
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="formatos.jsp">
                                    📋 Formatos de Grado
                                </a>
                            </li>
                            
                        <%
                            } else if ("estudiante".equals(rol)) {
                        %>
                            <li class="nav-item">
                                <a class="nav-link active text-white" href="estudiante/mis_anteproyectos.jsp">
                                    <strong>📚 Mis Anteproyectos</strong>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="estudiante/subir_anteproyecto.jsp">
                                    📤 Subir Anteproyecto
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="estudiante/estado_proyecto.jsp">
                                    📊 Estado del Proyecto
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="calendario.jsp">
                                    📅 Calendario Académico
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="formatos.jsp">
                                    📋 Formatos de Grado
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="estudiante/seleccionar_idea.jsp">
                                    💡 Seleccionar Idea
                                </a>
                            </li>
                            
                        <%
                            } else if ("director".equals(rol)) {
                        %>
                            <li class="nav-item">
                                <a class="nav-link active text-white" href="director/anteproyectos_asignados.jsp">
                                    <strong>📝 Anteproyectos Asignados</strong>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="director/calificar_anteproyecto.jsp">
                                    ⭐ Calificar Anteproyectos
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="calendario.jsp">
                                    📅 Calendario Académico
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="formatos.jsp">
                                    📋 Formatos de Grado
                                </a>
                            </li>
                            
                        <%
                            } else if ("evaluador".equals(rol)) {
                        %>
                            <li class="nav-item">
                                <a class="nav-link active text-white" href="evaluador/anteproyectos_evaluar.jsp">
                                    <strong>⭐ Anteproyectos a Evaluar</strong>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="evaluador/evaluar_anteproyecto.jsp">
                                    📝 Evaluar Anteproyectos
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="calendario.jsp">
                                    📅 Calendario Académico
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link text-white" href="formatos.jsp">
                                    📋 Formatos de Grado
                                </a>
                            </li>
                        <%
                            }
                        %>
                        
                        <!-- Enlaces comunes para todos los roles -->
                        <li class="nav-item mt-3">
                            <a class="nav-link text-info" href="dashboard.jsp">
                                🏠 Dashboard Principal
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-warning" href="logout.jsp">
                                🚪 Cerrar Sesión
                            </a>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">📊 Dashboard Principal</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <span class="badge bg-primary fs-6">
                            📅 <%= new java.text.SimpleDateFormat("EEEE, d 'de' MMMM 'de' yyyy").format(new java.util.Date()) %>
                        </span>
                    </div>
                </div>

                <!-- Cards de estadísticas -->
                <div class="row mb-4">
                    <%
                        if ("administrador".equals(rol)) {
                    %>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Total Usuarios</h5>
                                        <h2 class="card-text"><%= totalUsuarios %></h2>
                                    </div>
                                    <div class="display-4">👥</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Total Proyectos</h5>
                                        <h2 class="card-text"><%= totalAnteproyectos %></h2>
                                    </div>
                                    <div class="display-4">📁</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-info">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Proyectos Aprobados</h5>
                                        <h2 class="card-text"><%= anteproyectosAprobados %></h2>
                                    </div>
                                    <div class="display-4">✅</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <%
                        } else if ("coordinacion".equals(rol)) {
                    %>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Total Proyectos</h5>
                                        <h2 class="card-text"><%= totalAnteproyectos %></h2>
                                    </div>
                                    <div class="display-4">📁</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">En Revisión</h5>
                                        <h2 class="card-text"><%= anteproyectosPendientes %></h2>
                                    </div>
                                    <div class="display-4">⏳</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Aprobados</h5>
                                        <h2 class="card-text"><%= anteproyectosAprobados %></h2>
                                    </div>
                                    <div class="display-4">🎓</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <%
                        } else if ("estudiante".equals(rol)) {
                    %>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Mis Proyectos</h5>
                                        <h2 class="card-text"><%= misAnteproyectos %></h2>
                                    </div>
                                    <div class="display-4">📚</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Aprobados</h5>
                                        <h2 class="card-text"><%= anteproyectosAprobados %></h2>
                                    </div>
                                    <div class="display-4">✅</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">En Revisión</h5>
                                        <h2 class="card-text"><%= anteproyectosPendientes %></h2>
                                    </div>
                                    <div class="display-4">⏳</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <%
                        } else if ("director".equals(rol)) {
                    %>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Asignados</h5>
                                        <h2 class="card-text"><%= misAnteproyectos %></h2>
                                    </div>
                                    <div class="display-4">📝</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Pendientes</h5>
                                        <h2 class="card-text"><%= anteproyectosPendientes %></h2>
                                    </div>
                                    <div class="display-4">⏳</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Aprobados</h5>
                                        <h2 class="card-text"><%= anteproyectosAprobados %></h2>
                                    </div>
                                    <div class="display-4">✅</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <%
                        } else if ("evaluador".equals(rol)) {
                    %>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-primary">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Por Evaluar</h5>
                                        <h2 class="card-text"><%= misAnteproyectos %></h2>
                                    </div>
                                    <div class="display-4">⭐</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-warning">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Asignados</h5>
                                        <h2 class="card-text"><%= anteproyectosPendientes %></h2>
                                    </div>
                                    <div class="display-4">📋</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-success">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Evaluados</h5>
                                        <h2 class="card-text"><%= anteproyectosAprobados %></h2>
                                    </div>
                                    <div class="display-4">🎓</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                    
                    <!-- Card común para todos -->
                    <div class="col-md-3 mb-4">
                        <div class="card text-white bg-info">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h5 class="card-title">Mi Rol</h5>
                                        <p class="card-text"><strong><%= rol %></strong></p>
                                    </div>
                                    <div class="display-4">
                                        <%
                                            if ("administrador".equals(rol)) out.print("👑");
                                            else if ("coordinacion".equals(rol)) out.print("🎯");
                                            else if ("estudiante".equals(rol)) out.print("🎓");
                                            else if ("director".equals(rol)) out.print("🧑‍🏫");
                                            else if ("evaluador".equals(rol)) out.print("⭐");
                                        %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Contenido específico por rol -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header bg-dark text-white">
                                <h5 class="mb-0">🚀 Acciones Disponibles</h5>
                            </div>
                            <div class="card-body">
                                <%
                                    if ("administrador".equals(rol)) {
                                %>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p class="lead">Como <strong class="text-primary">Administrador</strong>, tienes control total sobre los usuarios del sistema.</p>
                                        <p>Puedes crear, editar, eliminar y gestionar todos los usuarios registrados en la plataforma.</p>
                                        <div class="mt-3">
                                            <span class="badge bg-primary me-2">👥 Gestión de Usuarios</span>
                                            <span class="badge bg-success me-2">📊 Estadísticas</span>
                                            <span class="badge bg-info me-2">⚙️ Configuración</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <a href="admin/usuarios.jsp" class="btn btn-primary btn-lg me-2">👨‍💼 Gestionar Usuarios</a>
                                    </div>
                                </div>
                                
                                <%
                                    } else if ("coordinacion".equals(rol)) {
                                %>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p class="lead">Como <strong class="text-success">Coordinación</strong>, gestionas todos los anteproyectos del sistema.</p>
                                        <p>Puedes crear anteproyectos, asignar directores a estudiantes y hacer seguimiento del estado de todos los proyectos.</p>
                                        <div class="mt-3">
                                            <span class="badge bg-primary me-2">📋 Gestión Anteproyectos</span>
                                            <span class="badge bg-success me-2">👨‍🏫 Asignar Directores</span>
                                            <span class="badge bg-info me-2">📊 Informes</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <a href="coordinacion/anteproyectos.jsp" class="btn btn-success btn-lg me-2">📋 Ver Anteproyectos</a>
                                        <a href="coordinacion/crear_anteproyecto.jsp" class="btn btn-primary btn-lg">➕ Nuevo</a>
                                    </div>
                                </div>
                                
                                <%
                                    } else if ("estudiante".equals(rol)) {
                                %>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p class="lead">Como <strong class="text-info">Estudiante</strong>, puedes gestionar tus trabajos de grado.</p>
                                        <p>Sube tus anteproyectos, consulta su estado y revisa las calificaciones y observaciones de los evaluadores.</p>
                                        <div class="mt-3">
                                            <span class="badge bg-primary me-2">📤 Subir Anteproyectos</span>
                                            <span class="badge bg-success me-2">📊 Ver Estado</span>
                                            <span class="badge bg-info me-2">⭐ Calificaciones</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <a href="estudiante/subir_anteproyecto.jsp" class="btn btn-primary btn-lg me-2">📤 Subir Anteproyecto</a>
                                        <a href="estudiante/mis_anteproyectos.jsp" class="btn btn-secondary btn-lg">📚 Mis Proyectos</a>
                                    </div>
                                </div>
                                
                                <%
                                    } else if ("director".equals(rol)) {
                                %>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p class="lead">Como <strong class="text-warning">Director</strong>, revisas y calificas los anteproyectos asignados.</p>
                                        <p>Puedes aprobar, rechazar o solicitar modificaciones a los trabajos de grado de tus estudiantes.</p>
                                        <div class="mt-3">
                                            <span class="badge bg-primary me-2">📝 Revisar Proyectos</span>
                                            <span class="badge bg-success me-2">⭐ Calificar</span>
                                            <span class="badge bg-info me-2">✅ Aprobar</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <a href="director/anteproyectos_asignados.jsp" class="btn btn-primary btn-lg">📝 Ver Anteproyectos</a>
                                    </div>
                                </div>
                                
                                <%
                                    } else if ("evaluador".equals(rol)) {
                                %>
                                <div class="row">
                                    <div class="col-md-8">
                                        <p class="lead">Como <strong class="text-danger">Evaluador</strong>, realizas la evaluación final de los anteproyectos.</p>
                                        <p>Revisa los trabajos aprobados por el director y determina si cumplen con los requisitos para su aprobación final.</p>
                                        <div class="mt-3">
                                            <span class="badge bg-primary me-2">⭐ Evaluar Proyectos</span>
                                            <span class="badge bg-success me-2">✅ Aprobación Final</span>
                                            <span class="badge bg-info me-2">📋 Informes</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <a href="evaluador/anteproyectos_evaluar.jsp" class="btn btn-primary btn-lg">⭐ Evaluar Anteproyectos</a>
                                    </div>
                                </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información del sistema -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-light">
                                <h6 class="mb-0">📊 Información del Sistema</h6>
                            </div>
                            <div class="card-body">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Usuario:</th>
                                        <td><strong><%= session.getAttribute("usuario_nombre") %></strong></td>
                                    </tr>
                                    <tr>
                                        <th>Email:</th>
                                        <td><%= session.getAttribute("usuario_email") %></td>
                                    </tr>
                                    <tr>
                                        <th>Rol:</th>
                                        <td><span class="badge bg-primary"><%= session.getAttribute("usuario_rol") %></span></td>
                                    </tr>
                                    <tr>
                                        <th>Estado:</th>
                                        <td><span class="badge bg-success"><%= session.getAttribute("usuario_estado") %></span></td>
                                    </tr>
                                    <tr>
                                        <th>ID de Sesión:</th>
                                        <td><code><%= session.getId() %></code></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-light">
                                <h6 class="mb-0">🚀 Accesos Rápidos</h6>
                            </div>
                            <div class="card-body">
                                <%
                                    if ("administrador".equals(rol)) {
                                %>
                                <div class="d-grid gap-2">
                                    <a href="admin/crear_usuario.jsp" class="btn btn-outline-primary btn-sm mb-2">➕ Crear Usuario</a>
                                    <a href="admin/usuarios.jsp" class="btn btn-outline-secondary btn-sm mb-2">👥 Listar Usuarios</a>
                                    <a href="calendario.jsp" class="btn btn-outline-info btn-sm mb-2">📅 Calendario</a>
                                    <a href="formatos.jsp" class="btn btn-outline-success btn-sm mb-2">📋 Formatos</a>
                                </div>
                                
                                <%
                                    } else if ("coordinacion".equals(rol)) {
                                %>
                                <div class="d-grid gap-2">
                                    <a href="coordinacion/crear_anteproyecto.jsp" class="btn btn-outline-primary btn-sm mb-2">➕ Nuevo Anteproyecto</a>
                                    <a href="coordinacion/anteproyectos.jsp" class="btn btn-outline-secondary btn-sm mb-2">📋 Ver Todos</a>
                                    <a href="coordinacion/informes.jsp" class="btn btn-outline-info btn-sm mb-2">📊 Informes</a>
                                    <a href="calendario.jsp" class="btn btn-outline-warning btn-sm mb-2">📅 Calendario</a>
                                </div>
                                
                                <%
                                    } else if ("estudiante".equals(rol)) {
                                %>
                                <div class="d-grid gap-2">
                                    <a href="estudiante/subir_anteproyecto.jsp" class="btn btn-outline-primary btn-sm mb-2">📤 Subir Anteproyecto</a>
                                    <a href="estudiante/mis_anteproyectos.jsp" class="btn btn-outline-secondary btn-sm mb-2">📚 Mis Proyectos</a>
                                    <a href="estudiante/estado_proyecto.jsp" class="btn btn-outline-info btn-sm mb-2">📊 Estado Actual</a>
                                    <a href="calendario.jsp" class="btn btn-outline-warning btn-sm mb-2">📅 Calendario</a>
                                </div>
                                
                                <%
                                    } else if ("director".equals(rol)) {
                                %>
                                <div class="d-grid gap-2">
                                    <a href="director/anteproyectos_asignados.jsp" class="btn btn-outline-primary btn-sm mb-2">📝 Ver Asignados</a>
                                    <a href="director/calificar_anteproyecto.jsp" class="btn btn-outline-success btn-sm mb-2">⭐ Calificar</a>
                                    <a href="calendario.jsp" class="btn btn-outline-info btn-sm mb-2">📅 Calendario</a>
                                    <a href="formatos.jsp" class="btn btn-outline-warning btn-sm mb-2">📋 Formatos</a>
                                </div>
                                
                                <%
                                    } else if ("evaluador".equals(rol)) {
                                %>
                                <div class="d-grid gap-2">
                                    <a href="evaluador/anteproyectos_evaluar.jsp" class="btn btn-outline-primary btn-sm mb-2">⭐ Por Evaluar</a>
                                    <a href="evaluador/evaluar_anteproyecto.jsp" class="btn btn-outline-success btn-sm mb-2">📝 Evaluar</a>
                                    <a href="calendario.jsp" class="btn btn-outline-info btn-sm mb-2">📅 Calendario</a>
                                    <a href="formatos.jsp" class="btn btn-outline-warning btn-sm mb-2">📋 Formatos</a>
                                </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-dark text-white text-center py-3 mt-4">
        <div class="container">
            <p class="mb-0">Sistema de Gestión y Seguimiento de Trabajos de Grado UTS &copy; 2024</p>
            <small>Desarrollado para la Unidad Tecnológica de Santander</small>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>