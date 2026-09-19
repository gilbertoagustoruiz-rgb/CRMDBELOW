CREATE TABLE IF NOT EXISTS clients(
 id BIGSERIAL PRIMARY KEY, name TEXT NOT NULL, ruc VARCHAR(11), contact TEXT, email TEXT, phone TEXT,
 status TEXT NOT NULL DEFAULT 'ACTIVO', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS projects(
 id BIGSERIAL PRIMARY KEY, code TEXT UNIQUE NOT NULL, client_id BIGINT REFERENCES clients(id), client TEXT NOT NULL,
 name TEXT NOT NULL, service_type TEXT, stage TEXT DEFAULT 'BRIEF',
 status TEXT NOT NULL DEFAULT 'PENDIENTE' CHECK(status IN('PENDIENTE','EN_CURSO','COMPLETADO','OBSERVADO','CERRADO','PERDIDO')),
 amount NUMERIC(14,2) NOT NULL DEFAULT 0, owner TEXT, start_date DATE, end_date DATE, closed_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS master_phases(
 phase_no INTEGER PRIMARY KEY CHECK(phase_no BETWEEN 1 AND 72), block_no INTEGER NOT NULL, block_name TEXT NOT NULL,
 name TEXT NOT NULL, owner_area TEXT NOT NULL, crm_state TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS project_phases(
 id BIGSERIAL PRIMARY KEY, project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
 phase_no INTEGER NOT NULL REFERENCES master_phases(phase_no), status TEXT NOT NULL DEFAULT 'PENDIENTE'
 CHECK(status IN('PENDIENTE','EN_CURSO','COMPLETADO','OBSERVADO')), responsible TEXT, notes TEXT,
 started_at TIMESTAMPTZ, completed_at TIMESTAMPTZ, updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
 UNIQUE(project_id,phase_no)
);
CREATE TABLE IF NOT EXISTS operational_records(
 id BIGSERIAL PRIMARY KEY, module TEXT NOT NULL, project_id BIGINT REFERENCES projects(id) ON DELETE SET NULL,
 record_type TEXT NOT NULL, title TEXT NOT NULL, amount NUMERIC(14,2) DEFAULT 0, status TEXT NOT NULL DEFAULT 'PENDIENTE',
 responsible TEXT, due_date DATE, details TEXT, metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS project_documents(
 id BIGSERIAL PRIMARY KEY, project_id BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
 module TEXT NOT NULL, document_type TEXT NOT NULL DEFAULT 'DOCUMENTO',
 original_name TEXT NOT NULL, stored_name TEXT NOT NULL, mime_type TEXT, size_bytes BIGINT,
 storage_path TEXT NOT NULL, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_project_documents_project ON project_documents(project_id);
CREATE INDEX IF NOT EXISTS idx_project_documents_module ON project_documents(module);
CREATE TABLE IF NOT EXISTS app_users(
 id BIGSERIAL PRIMARY KEY, full_name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, role TEXT NOT NULL,
 area TEXT, status TEXT NOT NULL DEFAULT 'ACTIVO', created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS audit_log(
 id BIGSERIAL PRIMARY KEY, entity TEXT NOT NULL, entity_id TEXT, action TEXT NOT NULL, user_name TEXT DEFAULT 'Sistema',
 payload JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE clients ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ruc VARCHAR(11);
ALTER TABLE clients ADD COLUMN IF NOT EXISTS contact TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'ACTIVO';
ALTER TABLE clients ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE clients ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

ALTER TABLE projects ADD COLUMN IF NOT EXISTS code TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS client TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS stage TEXT DEFAULT 'BRIEF';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'PENDIENTE';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS amount NUMERIC(14,2) NOT NULL DEFAULT 0;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE projects ADD COLUMN IF NOT EXISTS client_id BIGINT REFERENCES clients(id);
ALTER TABLE projects ADD COLUMN IF NOT EXISTS service_type TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS owner TEXT;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
CREATE INDEX IF NOT EXISTS idx_projects_client ON projects(client_id);
CREATE INDEX IF NOT EXISTS idx_project_phases_project ON project_phases(project_id);
CREATE INDEX IF NOT EXISTS idx_records_module ON operational_records(module);
CREATE INDEX IF NOT EXISTS idx_records_project ON operational_records(project_id);

INSERT INTO master_phases(phase_no,block_no,block_name,name,owner_area,crm_state) VALUES
(1,1,'Comercial y CRM','Contacto con el cliente','Comercial','Solicitud recibida'),
(2,1,'Comercial y CRM','Registro del cliente y contacto','Comercial','Cliente identificado'),
(3,1,'Comercial y CRM','Reunión y presentación','Comercial','Levantamiento de información'),
(4,1,'Comercial y CRM','Levantamiento del requerimiento','Comercial','Requerimiento en preparación'),
(5,1,'Comercial y CRM','Brief del cliente','Comercial','Brief completo / Brief incompleto'),
(6,1,'Comercial y CRM','Validación del brief','Comercial','Brief validado / Pendiente de información'),
(7,1,'Comercial y CRM','Derivación a Operaciones y Producción','Comercial','Derivado a Producción'),
(8,2,'Producción y preproducción','Asignación de productor','Producción','Productor asignado'),
(9,2,'Producción y preproducción','Confirmación de recepción','Producción','Recibido por Producción'),
(10,2,'Producción y preproducción','Revisión técnica y operativa','Producción','En revisión operativa'),
(11,2,'Producción y preproducción','Solicitud de información adicional','Producción','Pendiente de información'),
(12,2,'Producción y preproducción','Clasificación del servicio','Comercial','Servicio clasificado'),
(13,2,'Producción y preproducción','Definición de áreas involucradas','Producción','Equipo definido'),
(14,2,'Producción y preproducción','Apertura del expediente del proyecto','Producción','Expediente abierto'),
(15,2,'Producción y preproducción','Solicitud de costos','Producción','En costeo'),
(16,2,'Producción y preproducción','Creatividad y diseño preliminar','Diseño','En creatividad'),
(17,2,'Producción y preproducción','Armado del interno','Producción','Interno elaborado'),
(18,2,'Producción y preproducción','Preparación de cotización al cliente','Producción','Cotización preparada'),
(19,2,'Producción y preproducción','Validación interna','Producción','Aprobación interna'),
(20,3,'Comercial y negociación','Envío de cotización','Comercial','Cotización enviada'),
(21,3,'Comercial y negociación','Esperando respuesta','Comercial','Esperando respuesta'),
(22,3,'Comercial y negociación','Solicitud de cambios','Comercial','Cambios solicitados'),
(23,3,'Comercial y negociación','Recotización y nueva versión','Producción','Recotización'),
(24,3,'Comercial y negociación','Negociación comercial','Comercial','En negociación'),
(25,3,'Comercial y negociación','Proyecto desaprobado','Comercial','Desaprobado / Perdido'),
(26,3,'Comercial y negociación','Proyecto aprobado','Comercial','Aprobado'),
(27,3,'Comercial y negociación','Formalización comercial','Comercial','Formalización pendiente / Formalizado'),
(28,4,'Ficha código y ejecución','Creación de ficha de proyecto','Administración','Ficha creada'),
(29,4,'Ficha código y ejecución','Codificación del proyecto','Administración','Código activo'),
(30,4,'Ficha código y ejecución','Planificación de ejecución','Producción','En planificación'),
(31,4,'Ficha código y ejecución','Contratación y confirmación de proveedores','Producción','Proveedores confirmados'),
(32,4,'Ficha código y ejecución','Solicitud de anticipos y pagos previos','Producción','Pago / Anticipo solicitado'),
(33,4,'Ficha código y ejecución','Diseño final y artes','Diseño','Diseño aprobado'),
(34,4,'Ficha código y ejecución','Logística y almacén','Logística / Almacén','Logística en proceso'),
(35,4,'Ficha código y ejecución','Ejecución del proyecto','Producción','En ejecución'),
(36,4,'Ficha código y ejecución','Incidencias y adicionales','Producción','Adicional pendiente / Adicional aprobado'),
(37,5,'Gastos Finanzas y Tesorería','Registro de gastos','Administración','Gasto registrado'),
(38,5,'Gastos Finanzas y Tesorería','Anticipo y fondo por rendir','Finanzas / Tesorería','Pendiente de rendición'),
(39,5,'Gastos Finanzas y Tesorería','Rendición','Responsable del anticipo','Rendición enviada'),
(40,5,'Gastos Finanzas y Tesorería','Devolución de saldo','Responsable del anticipo','Saldo devuelto'),
(41,5,'Gastos Finanzas y Tesorería','Reembolso','Producción','Reembolso pendiente'),
(42,5,'Gastos Finanzas y Tesorería','Cuenta por pagar a proveedor','Finanzas','Pendiente de pago'),
(43,5,'Gastos Finanzas y Tesorería','Programación de pago','Finanzas / Tesorería','Pago programado'),
(44,5,'Gastos Finanzas y Tesorería','Ejecución del pago','Finanzas / Tesorería','Pagado'),
(45,6,'Contabilidad y control documental','Validación del comprobante','Contabilidad','Validado / Observado'),
(46,6,'Contabilidad y control documental','Detracción y obligaciones tributarias','Contabilidad','Detracción pendiente / Detracción pagada'),
(47,6,'Contabilidad y control documental','Registro contable','Contabilidad','Registrado contablemente'),
(48,6,'Contabilidad y control documental','Corrección y nota de crédito','Contabilidad','En regularización / Regularizado'),
(49,7,'Post ejecución y liquidación','Cierre operativo','Producción','Ejecutado'),
(50,7,'Post ejecución y liquidación','Feedback post ejecución','Operaciones','Feedback pendiente / Realizado / Acciones en seguimiento'),
(51,7,'Post ejecución y liquidación','Encuesta de satisfacción del cliente','Comercial','Encuesta pendiente / Enviada / Respondida / Sin respuesta'),
(52,7,'Post ejecución y liquidación','Consolidación de sustentos','Producción','Sustentos en revisión'),
(53,7,'Post ejecución y liquidación','Liquidación del proyecto','Producción','En liquidación'),
(54,7,'Post ejecución y liquidación','Interno vs real','Producción / Operaciones','Análisis de desviación'),
(55,7,'Post ejecución y liquidación','Revisión de liquidación','Operaciones','Liquidación en revisión'),
(56,7,'Post ejecución y liquidación','Conciliación financiera','Finanzas','Conciliación financiera'),
(57,7,'Post ejecución y liquidación','Conciliación contable','Contabilidad','Conciliación contable'),
(58,8,'Facturación','Validación para facturar','Facturación','Listo para facturar'),
(59,8,'Facturación','Emisión de factura al cliente','Facturación','Facturado'),
(60,8,'Facturación','Presentación de factura','Facturación','Factura presentada'),
(61,8,'Facturación','Observación de factura','Facturación / Comercial','Factura observada'),
(62,8,'Facturación','Aceptación de factura','Facturación / Finanzas','Pendiente de cobro'),
(63,9,'Cobranza y cierre','Cuenta por cobrar','Finanzas / Cobranza','Pendiente de cobro'),
(64,9,'Cobranza y cierre','Seguimiento de cobranza','Finanzas / Cobranza','En cobranza'),
(65,9,'Cobranza y cierre','Cobro parcial','Finanzas','Pago parcial'),
(66,9,'Cobranza y cierre','Cobro total','Finanzas','Cobrado'),
(67,9,'Cobranza y cierre','Validación de cierre','Operaciones','Validación de cierre'),
(68,9,'Cobranza y cierre','Conciliado - listo para cerrar','Operaciones','Conciliado - Listo para cerrar'),
(69,9,'Cobranza y cierre','Cierre del código','Administración / Operaciones','Código cerrado'),
(70,9,'Cobranza y cierre','Archivo del proyecto','Producción / Administración','Archivado'),
(71,9,'Cobranza y cierre','Cierre del proyecto','Operaciones / Administración','Cerrado'),
(72,9,'Cobranza y cierre','Histórico y análisis','Gerencia / Comercial / Operaciones','Histórico')
ON CONFLICT (phase_no) DO UPDATE SET block_no=EXCLUDED.block_no,block_name=EXCLUDED.block_name,name=EXCLUDED.name,owner_area=EXCLUDED.owner_area,crm_state=EXCLUDED.crm_state;
