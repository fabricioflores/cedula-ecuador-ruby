def validate_cedula_ruc_ec
 tipo_numero_de_identificacion = nil
 valido = false
 productos = []
 unless (10..13) === self.numero_de_identificacion.size
 errors.add(:numero_de_identificacion, "longitud incorrecta")
 end
 provincias = 22
 codigo_provincia = self.numero_de_identificacion[0,2].to_i
 if codigo_provincia < 1 or codigo_provincia > provincias
 errors.add(:numero_de_identificacion, "código de provincia incorrecto")
 end
 # tercer digito:
 # 9 -> sociedades privadas o extranjeras
 # 6 -> sociedades publicas
 # 0..6 -> personas naturales
 tercer_digito = self.numero_de_identificacion[2].to_i
 if (7..8) === tercer_digito
 errors.add(:numero_de_identificacion, "tercer dígito inválido")
 end
 if tercer_digito == 9
 tipo_numero_de_identificacion = "Sociedad privada o extranjera"
 else
 if tercer_digito == 6
 tipo_numero_de_identificacion = "Sociedad pública"
 else
 if tercer_digito < 6
 tipo_numero_de_identificacion = "Persona natural"
 end
 end
 end
 
# para personas naturales:
 if tercer_digito < 6
 modulo = 10
 p = 2
 verificador = self.numero_de_identificacion[9].to_i
 for i in self.numero_de_identificacion[0,9].split('')
 producto = i.to_i * p
 if producto >= 10 then producto -= 9 end
 productos.push producto
 if p == 2 then p = 1 else p = 2 end
 end
 end
 
 # para sociedades públicas:
 if tercer_digito == 6
 verificador = self.numero_de_identificacion[8].to_i
 modulo = 11
 multiplicadores = [ 3, 2, 7, 6, 5, 4, 3, 2 ]
 for i in (0..7).to_a
 productos[i] = self.numero_de_identificacion[i].to_i * multiplicadores[i]
 end
 productos[8] = 0
 end
 
# para entidades privadas:
 if tercer_digito == 9
 verificador = self.numero_de_identificacion[9].to_i
 modulo = 11
 multiplicadores = [ 4, 3, 2, 7, 6, 5, 4, 3, 2 ]
 for i in (0..8).to_a
 productos[i] = self.numero_de_identificacion[i].to_i * multiplicadores[i]
 end
 end
 
suma = 0
 for i in productos
 suma += i
 residuo = suma % modulo
 digito_verificador = if residuo == 0 then 0 else modulo - residuo end
 end
 
# sociedades públicas:
 if tercer_digito == 6
 unless self.numero_de_identificacion[9,4] == "0001"
 errors.add(:numero_de_identificacion, "RUC de empresa del sector público debe terminar en 0001")
 end
 valido = digito_verificador == verificador
 end
 
 # entidades privadas:
 if tercer_digito == 9
 unless self.numero_de_identificacion[10,3] == "001"
 errors.add(:numero_de_identificacion, "RUC de entidad privada debe terminar en 001")
 end
 valido = (digito_verificador == verificador)
 end
 
# personas naturales:
 if tercer_digito < 6
 if self.numero_de_identificacion.size > 10 and self.numero_de_identificacion[10,3] != "001"
 errors.add(:numero_de_identificacion, "RUC de persona natural debe terminar en 001")
 end
 valido = (digito_verificador == verificador)
 end
 
errors.add(:numero_de_identificacion, "cédula no válida") if valido == false
 end
