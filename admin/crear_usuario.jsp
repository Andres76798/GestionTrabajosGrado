<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"administrador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    // Procesar formulario
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String codigo = request.getParameter("codigo");
        String nombre = request.getParameter("nombre");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rol = request.getParameter("rol");
        String estado = request.getParameter("estado");
        String telefono = request.getParameter("telefono");
        String programa = request.getParameter("programa_academico");
        
        try {
            String sql = "INSERT INTO usuarios (codigo, nombre, email, password, rol, estado, telefono, programa_academico) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, codigo);
            pstmt.setString(2, nombre);
            pstmt.setString(3, email);
            pstmt.setString(4, password);
            pstmt.setString(5, rol);
            pstmt.setString(6, estado);
            pstmt.setString(7, telefono);
            pstmt.setString(8, programa);
            
            int result = pstmt.executeUpdate();
            if (result > 0) {
                response.sendRedirect("usuarios.jsp?mensaje=1");
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
    <title>Registrar Usuario - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-10">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">👨‍💼 Registrar Nuevo Usuario</h4>
                    </div>
                    <div class="card-body">
                        <form method="POST">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Código *</label>
                                        <input type="text" class="form-control" name="codigo" required 
                                               placeholder="Ej: EST001, DOC001, COORD001">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Nombre Completo *</label>
                                        <input type="text" class="form-control" name="nombre" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Email *</label>
                                        <input type="email" class="form-control" name="email" required>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Contraseña *</label>
                                        <input type="password" class="form-control" name="password" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Rol *</label>
                                        <select class="form-select" name="rol" required>
                                            <option value="">Seleccionar rol</option>
                                            <option value="estudiante">🎓 Estudiante</option>
                                            <option value="director">🧑‍🏫 Director</option>
                                            <option value="evaluador">⭐ Evaluador</option>
                                            <option value="coordinacion">🎯 Coordinación</option>
                                            <option value="administrador">👑 Administrador</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Estado *</label>
                                        <select class="form-select" name="estado" required>
                                            <option value="activo">✅ Activo</option>
                                            <option value="inactivo">❌ Inactivo</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Teléfono</label>
                                        <input type="tel" class="form-control" name="telefono" 
                                               placeholder="Ej: 3001234567">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Programa Académico</label>
                                        <input type="text" class="form-control" name="programa_academico" 
                                               placeholder="Ej: Ingeniería de Sistemas">
                                    </div>
                                </div>
                            </div>
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="usuarios.jsp" class="btn btn-secondary me-md-2">❌ Cancelar</a>
                                <button type="submit" class="btn btn-primary">✅ Registrar Usuario</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>