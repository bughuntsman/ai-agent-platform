# AI Agent Platform

A multi-tenant SaaS platform for orchestrating conversational AI agents across multiple communication channels (Slack, Telegram, SMS, Web). Built with Ruby on Rails, this platform enables organizations to create, configure, and deploy intelligent agents powered by OpenAI and Anthropic LLMs.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway (Rails)                       │
│                    JWT Authentication + CORS                     │
└──────────────────┬──────────────────────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
    ┌────▼────┐         ┌───▼────┐
    │ Agents  │         │ Users  │
    │  CRUD   │         │  Auth  │
    └────┬────┘         └────────┘
         │
    ┌────▼──────────────────────┐
    │   Conversation Service    │
    │   (Orchestration Layer)   │
    └────┬──────────────────────┘
         │
    ┌────▼────┐         ┌──────────┐
    │   LLM   │────────▶│  OpenAI  │
    │ Service │         │ Anthropic│
    └────┬────┘         └──────────┘
         │
    ┌────▼─────────┐
    │   Sidekiq    │
    │ (Async Jobs) │
    └──────────────┘
         │
    ┌────▼─────────────────────┐
    │    PostgreSQL (Schemas)  │
    │   Multi-tenant Database  │
    └──────────────────────────┘
```

## Key Features

### 🏢 Multi-Tenancy
- **Schema-based isolation** using Apartment gem
- Each tenant gets dedicated PostgreSQL schema
- Secure data segregation between organizations
- Subdomain-based tenant identification

### 🤖 AI Agent Management
- Support for **OpenAI** (GPT-4, GPT-3.5) and **Anthropic** (Claude) models
- Configurable system prompts, temperature, and max tokens
- Conversation history management with token tracking
- Asynchronous agent execution via Sidekiq

### 💬 Multi-Channel Support
- **Slack** - Bot integration with Web API
- **Telegram** - Bot API integration
- **SMS** - Twilio integration
- **Web** - WebSocket/Webhook support

### 🔐 Authentication & Security
- JWT-based authentication
- Role-based access control (admin/member)
- Secure password hashing with bcrypt
- CORS configuration for API access

### ⚡ Background Processing
- Sidekiq for async job execution
- Separate queues for different priorities
- Retry logic with exponential backoff
- Agent execution and channel message processing

### 📊 Conversation Management
- Message history with context
- Token usage tracking
- Conversation status (active/paused/archived)
- Channel-specific metadata

## Tech Stack

- **Framework**: Ruby on Rails 7.1 (API mode)
- **Database**: PostgreSQL 15 with schema-based multi-tenancy
- **Cache/Jobs**: Redis 7 + Sidekiq 7
- **LLM APIs**: OpenAI, Anthropic Claude
- **Testing**: RSpec, FactoryBot, WebMock, VCR
- **Containerization**: Docker + Docker Compose

## Prerequisites

- Docker & Docker Compose
- OpenAI API Key (optional, for testing)
- Anthropic API Key (optional, for testing)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ai-agent-platform

# Copy environment variables
cp .env.example .env

# Edit .env and add your API keys
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# JWT_SECRET_KEY=<generate with: rails secret>
```

### 2. Run with Docker Compose

```bash
# Build and start all services (PostgreSQL, Redis, Rails, Sidekiq)
docker-compose up --build

# In another terminal, create database and run migrations
docker-compose exec web rails db:create db:migrate

# Verify services are running
docker-compose ps
```

The API will be available at `http://localhost:3000`

### 3. Create Your First Tenant & Agent

```bash
# Register a new tenant
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "acme",
    "tenant_name": "ACME Corp",
    "email": "admin@acme.com",
    "password": "securepassword123"
  }'

# Save the JWT token from response
export TOKEN="<jwt_token_from_response>"

# Create an AI agent
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Customer Support Bot",
      "description": "Helpful customer support assistant",
      "llm_provider": "openai",
      "llm_model": "gpt-3.5-turbo",
      "system_prompt": "You are a helpful customer support assistant. Be concise and friendly.",
      "temperature": 0.7,
      "max_tokens": 500
    }
  }'
```

## API Documentation

### Authentication

#### Register New Tenant
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "subdomain": "acme",
  "tenant_name": "ACME Corp",
  "email": "admin@acme.com",
  "password": "securepassword"
}
```

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "subdomain": "acme",
  "email": "admin@acme.com",
  "password": "securepassword"
}
```

### Agents

#### List Agents
```http
GET /api/v1/agents
Authorization: Bearer <token>
```

#### Create Agent
```http
POST /api/v1/agents
Authorization: Bearer <token>
Content-Type: application/json

{
  "agent": {
    "name": "Support Bot",
    "llm_provider": "anthropic",
    "llm_model": "claude-3-sonnet-20240229",
    "system_prompt": "You are a helpful assistant",
    "temperature": 0.7,
    "max_tokens": 1000
  }
}
```

#### Execute Agent (Async)
```http
POST /api/v1/agents/:id/execute
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "Hello, I need help!",
  "conversation_id": 123  // optional
}
```

### Conversations

#### Create Conversation
```http
POST /api/v1/agents/:agent_id/conversations
Authorization: Bearer <token>
Content-Type: application/json

{
  "conversation": {
    "channel_type": "web",
    "channel_user_id": "user123",
    "metadata": {}
  }
}
```

#### Send Message (Sync)
```http
POST /api/v1/conversations/:id/messages
Authorization: Bearer <token>
Content-Type: application/json

{
  "content": "What are your business hours?"
}
```

#### Get Conversation Messages
```http
GET /api/v1/conversations/:id/messages
Authorization: Bearer <token>
```

## Project Structure

```
ai-agent-platform/
├── app/
│   ├── controllers/
│   │   └── api/v1/          # Versioned API controllers
│   │       ├── agents_controller.rb
│   │       ├── conversations_controller.rb
│   │       └── auth_controller.rb
│   ├── models/              # ActiveRecord models
│   │   ├── tenant.rb        # Multi-tenant organization
│   │   ├── user.rb          # User authentication
│   │   ├── agent.rb         # AI agent configuration
│   │   ├── conversation.rb  # Conversation tracking
│   │   ├── message.rb       # Individual messages
│   │   └── agent_channel.rb # Channel integrations
│   ├── services/            # Business logic
│   │   ├── llm_service.rb           # LLM API integration
│   │   └── conversation_service.rb  # Orchestration
│   └── jobs/                # Background jobs
│       ├── agent_execution_job.rb
│       └── channel_message_processor_job.rb
├── config/
│   ├── initializers/
│   │   ├── apartment.rb     # Multi-tenancy config
│   │   ├── sidekiq.rb       # Background jobs
│   │   └── cors.rb          # CORS policy
│   ├── routes.rb            # API routes
│   └── database.yml         # Database config
├── db/
│   └── migrate/             # Database migrations
├── spec/                    # RSpec tests
│   ├── models/
│   ├── services/
│   ├── requests/
│   └── factories/
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Testing

```bash
# Run all tests
docker-compose exec web rspec

# Run specific test file
docker-compose exec web rspec spec/models/agent_spec.rb

# Run with coverage
docker-compose exec web rspec --format documentation
```

## Development

### Local Development without Docker

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Start Redis (in separate terminal)
redis-server

# Start Sidekiq (in separate terminal)
bundle exec sidekiq -C config/sidekiq.yml

# Start Rails server
rails server
```

### Adding a New LLM Provider

1. Update `Agent::LLM_PROVIDERS` constant
2. Add model validation in `agent.rb`
3. Implement provider method in `LlmService`:
   ```ruby
   def send_custom_provider_request(user_message, conversation_history)
     # Implementation
   end
   ```
4. Add tests in `spec/services/llm_service_spec.rb`

### Adding a New Channel

1. Add channel type to `Conversation::CHANNEL_TYPES`
2. Create configuration validator in `AgentChannel`
3. Implement sender in `ChannelMessageProcessorJob`
4. Add integration tests

## Deployment Considerations

### Production Setup

1. **Environment Variables**
   - Use secrets management (AWS Secrets Manager, HashiCorp Vault)
   - Rotate JWT secrets regularly
   - Use separate API keys per environment

2. **Database**
   - Enable connection pooling
   - Configure pg_bouncer for connection management
   - Regular backups with point-in-time recovery

3. **Redis**
   - Use Redis Sentinel for high availability
   - Configure persistence (AOF + RDB)
   - Monitor memory usage

4. **Sidekiq**
   - Scale workers based on job queue depth
   - Configure separate queues for priorities
   - Set up monitoring (Sidekiq Web UI)

5. **LLM APIs**
   - Implement rate limiting
   - Add circuit breakers (e.g., with `semian` gem)
   - Cache responses where appropriate
   - Monitor token usage and costs

6. **Monitoring**
   - Application: New Relic, Datadog, Scout
   - Logs: ELK Stack, Papertrail
   - Errors: Sentry, Honeybadger
   - Metrics: Prometheus + Grafana

### Scaling Strategy

- **Horizontal Scaling**: Multiple Rails instances behind load balancer
- **Database**: Read replicas for queries, primary for writes
- **Caching**: Redis cluster for session/cache storage
- **CDN**: CloudFront/CloudFlare for static assets
- **Background Jobs**: Auto-scaling Sidekiq workers based on queue depth

## Performance Optimizations

1. **Database**
   - Index frequently queried columns
   - Use `includes` to prevent N+1 queries
   - Implement pagination for large result sets
   - Consider materialized views for analytics

2. **API**
   - Implement response caching with ETags
   - Use Rack::Attack for rate limiting
   - Compress responses with gzip
   - Implement field selection (GraphQL-style)

3. **LLM Calls**
   - Stream responses for better UX
   - Implement request coalescing
   - Cache common prompts/responses
   - Use cheaper models where appropriate


## License

MIT License - see LICENSE file for details


**Built with ❤️ using Ruby on Rails**
