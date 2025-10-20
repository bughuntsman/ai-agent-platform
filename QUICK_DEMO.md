# Quick Demo Script

```bash
# 1. Iniciar servicios
cd ai-agent-platform
docker-compose up -d

# 2. Verificar que todo está corriendo
docker-compose ps
# Deberías ver: db, redis, web, sidekiq todos "Up"

# 3. Crear base de datos
docker-compose exec web rails db:create db:migrate

# 4. Verificar health
curl http://localhost:3000/health
# Debería devolver: OK
```

## Demo Flow (Durante la entrevista)

### Paso 1: Mostrar Arquitectura (30 segundos)

```bash
# Mostrar estructura del proyecto
tree -L 3 -I 'node_modules|tmp|log'

# O simplemente:
ls -la app/
ls -la app/models/
ls -la app/services/
ls -la app/jobs/
```

### Paso 2: Registrar un Tenant (1 minuto)

```bash
# Crear tenant
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "demo",
    "tenant_name": "Demo Company",
    "email": "admin@demo.com",
    "password": "SecurePass123"
  }' | jq
```

```bash
# Guardar token
export TOKEN="<paste_token_here>"

# O automático:
export TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "demo2",
    "tenant_name": "Demo Company 2",
    "email": "admin@demo2.com",
    "password": "SecurePass123"
  }' | jq -r '.token')

echo $TOKEN
```

### Paso 3: Crear un Agente (1 minuto)

```bash
# Crear agente de soporte
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Support Bot",
      "description": "Customer support assistant",
      "llm_provider": "openai",
      "llm_model": "gpt-3.5-turbo",
      "system_prompt": "You are a helpful customer support assistant. Be concise.",
      "temperature": 0.7,
      "max_tokens": 500
    }
  }' | jq

# Guardar agent_id
export AGENT_ID=1
```

### Paso 4: Crear Conversación (30 segundos)

```bash
# Crear conversación
curl -X POST http://localhost:3000/api/v1/agents/$AGENT_ID/conversations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversation": {
      "channel_type": "web",
      "channel_user_id": "demo_user_123",
      "metadata": {"source": "demo"}
    }
  }' | jq

# Guardar conversation_id
export CONV_ID=1
```

### Paso 5: Enviar Mensaje y Ver Respuesta (1 minuto)

```bash
# Enviar mensaje
curl -X POST http://localhost:3000/api/v1/conversations/$CONV_ID/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hello! What can you help me with?"
  }' | jq
```

### Paso 6: Ver Historial (30 segundos)

```bash
# Ver mensajes de la conversación
curl -X GET http://localhost:3000/api/v1/conversations/$CONV_ID/messages \
  -H "Authorization: Bearer $TOKEN" | jq
```

**Mostrar**: Historial completo con tracking de tokens

### Paso 7: Mostrar Código Clave (1 minuto)

```bash
# Mostrar servicio de LLM
cat app/services/llm_service.rb
```

```bash
# Mostrar modelo de agente
cat app/models/agent.rb
```

## Demo Alternativo: Tests (Si tienen interés)

```bash
# Ejecutar tests
docker-compose exec web rspec spec/services/llm_service_spec.rb

# Mostrar un test
cat spec/services/llm_service_spec.rb
```

## Demo Alternativo: Background Jobs (Si tienen interés)

```bash
# Terminal 1: Ver logs de Sidekiq
docker-compose logs -f sidekiq

# Terminal 2: Ejecutar job async
curl -X POST http://localhost:3000/api/v1/agents/$AGENT_ID/execute \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Process this asynchronously",
    "conversation_id": '$CONV_ID'
  }' | jq
```

## Preguntas que Pueden Hacer

### "¿Cómo funciona el multi-tenancy?"

```bash
# Conectar a PostgreSQL
docker-compose exec db psql -U postgres -d ai_agent_platform_development

# Dentro de psql:
\dn  # Mostrar schemas
# Verás: public, demo, demo2

SELECT * FROM tenants;  # En schema público
\q
```

### "¿Cómo manejas errores de API?"

```bash
# Mostrar custom exceptions
grep -A 5 "class LlmError" app/services/llm_service.rb

# Mostrar manejo en controller
grep -A 3 "rescue_from" app/controllers/application_controller.rb
```

### "¿Cómo testeas sin llamar APIs?"

```bash
# Mostrar WebMock stub
cat spec/services/llm_service_spec.rb | grep -A 10 "stub_request"
```

## Comandos de Limpieza (Después del demo)

```bash
# Detener todo
docker-compose down

# Limpiar volúmenes también
docker-compose down -v
```

## Script Completo Automatizado

Guarda esto como `demo.sh` para ejecutar todo de una vez:

```bash
#!/bin/bash

echo "🚀 Starting AI Agent Platform Demo"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Registrar tenant
echo -e "\n${BLUE}1. Registering tenant...${NC}"
RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "demo",
    "tenant_name": "Demo Company",
    "email": "admin@demo.com",
    "password": "SecurePass123"
  }')

TOKEN=$(echo $RESPONSE | jq -r '.token')
echo -e "${GREEN}✓ Token: ${TOKEN:0:20}...${NC}"

# Crear agente
echo -e "\n${BLUE}2. Creating AI Agent...${NC}"
AGENT_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Support Bot",
      "description": "Customer support assistant",
      "llm_provider": "openai",
      "llm_model": "gpt-3.5-turbo",
      "system_prompt": "You are a helpful customer support assistant.",
      "temperature": 0.7,
      "max_tokens": 500
    }
  }')

AGENT_ID=$(echo $AGENT_RESPONSE | jq -r '.agent.id')
echo -e "${GREEN}✓ Agent created with ID: $AGENT_ID${NC}"

# Crear conversación
echo -e "\n${BLUE}3. Creating conversation...${NC}"
CONV_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/agents/$AGENT_ID/conversations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversation": {
      "channel_type": "web",
      "channel_user_id": "demo_user_123"
    }
  }')

CONV_ID=$(echo $CONV_RESPONSE | jq -r '.conversation.id')
echo -e "${GREEN}✓ Conversation created with ID: $CONV_ID${NC}"

# Enviar mensaje
echo -e "\n${BLUE}4. Sending message to agent...${NC}"
MESSAGE_RESPONSE=$(curl -s -X POST http://localhost:3000/api/v1/conversations/$CONV_ID/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hello! What can you help me with?"
  }')

echo -e "${GREEN}✓ Response received:${NC}"
echo $MESSAGE_RESPONSE | jq '.content'

echo -e "\n${GREEN}✅ Demo completed successfully!${NC}"
```

```bash
# Hacer ejecutable
chmod +x demo.sh

# Correr
./demo.sh
```