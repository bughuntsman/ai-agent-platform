# Usage Examples

This document provides practical examples of using the AI Agent Platform.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Creating Agents](#creating-agents)
3. [Managing Conversations](#managing-conversations)
4. [Advanced Use Cases](#advanced-use-cases)

## Getting Started

### 1. Register Your Organization

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "acme",
    "tenant_name": "ACME Corporation",
    "email": "admin@acme.com",
    "password": "SecurePassword123!"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "admin@acme.com",
    "role": "admin"
  },
  "tenant": {
    "id": 1,
    "name": "ACME Corporation",
    "subdomain": "acme",
    "active": true
  }
}
```

### 2. Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "subdomain": "acme",
    "email": "admin@acme.com",
    "password": "SecurePassword123!"
  }'
```

## Creating Agents

### Example 1: Customer Support Agent (OpenAI)

```bash
export TOKEN="your_jwt_token"

curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Support Bot",
      "description": "Handles customer support inquiries 24/7",
      "llm_provider": "openai",
      "llm_model": "gpt-4-turbo",
      "system_prompt": "You are a friendly and helpful customer support agent for ACME Corp. Help customers with product questions, order status, and returns. Be concise and professional. If you dont know the answer, offer to escalate to a human agent.",
      "temperature": 0.7,
      "max_tokens": 500,
      "active": true
    }
  }'
```

### Example 2: Sales Assistant (Anthropic Claude)

```bash
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Sales Assistant",
      "description": "Helps with product recommendations and sales",
      "llm_provider": "anthropic",
      "llm_model": "claude-3-sonnet-20240229",
      "system_prompt": "You are a sales assistant for ACME Corp. Your goal is to understand customer needs and recommend appropriate products. Be consultative, not pushy. Ask clarifying questions to better understand requirements. Provide product details and pricing when relevant.",
      "temperature": 0.8,
      "max_tokens": 1000,
      "active": true
    }
  }'
```

### Example 3: Technical Documentation Bot

```bash
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Docs Bot",
      "description": "Answers technical questions about our products",
      "llm_provider": "openai",
      "llm_model": "gpt-3.5-turbo",
      "system_prompt": "You are a technical documentation expert for ACME Corp. Provide accurate, detailed technical answers with code examples when appropriate. Use markdown formatting. Include links to relevant documentation. Be precise and technical.",
      "temperature": 0.3,
      "max_tokens": 1500,
      "active": true
    }
  }'
```

## Managing Conversations

### Create a Conversation

```bash
# Assuming agent_id = 1
curl -X POST http://localhost:3000/api/v1/agents/1/conversations \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversation": {
      "channel_type": "web",
      "channel_user_id": "user_12345",
      "metadata": {
        "user_name": "John Doe",
        "session_id": "sess_abc123"
      }
    }
  }'
```

**Response:**
```json
{
  "conversation": {
    "id": 42,
    "agent_id": 1,
    "agent_name": "Support Bot",
    "channel_type": "web",
    "channel_user_id": "user_12345",
    "status": "active",
    "messages_count": 0,
    "total_tokens": 0,
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

### Send a Message

```bash
# Send user message and get AI response
curl -X POST http://localhost:3000/api/v1/conversations/42/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hi! I need help with my recent order #12345. It hasnt arrived yet."
  }'
```

**Response:**
```json
{
  "message": {
    "id": 156,
    "role": "assistant",
    "content": "Hello! I'd be happy to help you track order #12345. Let me look that up for you...",
    "tokens_used": 45,
    "created_at": "2025-01-15T10:31:00Z"
  },
  "content": "Hello! I'd be happy to help you track order #12345...",
  "tokens_used": 45
}
```

### Get Conversation History

```bash
curl -X GET http://localhost:3000/api/v1/conversations/42/messages \
  -H "Authorization: Bearer $TOKEN"
```

**Response:**
```json
{
  "messages": [
    {
      "id": 155,
      "role": "user",
      "content": "Hi! I need help with my recent order...",
      "tokens_used": 0,
      "created_at": "2025-01-15T10:30:45Z"
    },
    {
      "id": 156,
      "role": "assistant",
      "content": "Hello! I'd be happy to help...",
      "tokens_used": 45,
      "created_at": "2025-01-15T10:31:00Z"
    }
  ],
  "meta": {
    "total": 2,
    "total_tokens": 45
  }
}
```

## Advanced Use Cases

### Use Case 1: Multi-Turn Conversation

```bash
# First message
curl -X POST http://localhost:3000/api/v1/conversations/42/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "What are your business hours?"}'

# Second message (with context)
curl -X POST http://localhost:3000/api/v1/conversations/42/messages \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Are you open on weekends too?"}'

# Agent will remember previous context about business hours
```

### Use Case 2: Async Agent Execution

```bash
# Execute agent without blocking (returns immediately)
curl -X POST http://localhost:3000/api/v1/agents/1/execute \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Generate a detailed product comparison report",
    "conversation_id": 42
  }'
```

**Response:**
```json
{
  "message": "Agent execution queued",
  "job_id": "abc123def456",
  "agent_id": 1
}
```

### Use Case 3: Temperature Experimentation

**Creative Agent (High Temperature)**
```bash
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Creative Writer",
      "llm_provider": "openai",
      "llm_model": "gpt-4-turbo",
      "system_prompt": "You are a creative marketing copywriter. Generate engaging, original content.",
      "temperature": 1.2,
      "max_tokens": 2000
    }
  }'
```

**Precise Agent (Low Temperature)**
```bash
curl -X POST http://localhost:3000/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "name": "Code Reviewer",
      "llm_provider": "anthropic",
      "llm_model": "claude-3-opus-20240229",
      "system_prompt": "You are a code reviewer. Provide precise, technical feedback on code quality.",
      "temperature": 0.2,
      "max_tokens": 1500
    }
  }'
```

### Use Case 4: Update Agent Configuration

```bash
# Update agent to use different model
curl -X PATCH http://localhost:3000/api/v1/agents/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "agent": {
      "llm_model": "gpt-4",
      "temperature": 0.5,
      "system_prompt": "Updated system prompt with new instructions..."
    }
  }'
```

### Use Case 5: Pause and Resume Conversations

```bash
# Pause conversation
curl -X PATCH http://localhost:3000/api/v1/conversations/42 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"conversation": {"status": "paused"}}'

# Resume conversation
curl -X PATCH http://localhost:3000/api/v1/conversations/42 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"conversation": {"status": "active"}}'

# Archive conversation
curl -X PATCH http://localhost:3000/api/v1/conversations/42 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"conversation": {"status": "archived"}}'
```

## Integration Examples

### Python Client

```python
import requests
import json

class AgentPlatformClient:
    def __init__(self, base_url, token):
        self.base_url = base_url
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }

    def create_conversation(self, agent_id, channel_type, channel_user_id):
        response = requests.post(
            f'{self.base_url}/api/v1/agents/{agent_id}/conversations',
            headers=self.headers,
            json={
                'conversation': {
                    'channel_type': channel_type,
                    'channel_user_id': channel_user_id
                }
            }
        )
        return response.json()

    def send_message(self, conversation_id, content):
        response = requests.post(
            f'{self.base_url}/api/v1/conversations/{conversation_id}/messages',
            headers=self.headers,
            json={'content': content}
        )
        return response.json()

# Usage
client = AgentPlatformClient('http://localhost:3000', 'your_token')
conv = client.create_conversation(agent_id=1, channel_type='web', channel_user_id='user123')
response = client.send_message(conv['conversation']['id'], 'Hello!')
print(response['content'])
```

### JavaScript/Node.js Client

```javascript
const axios = require('axios');

class AgentPlatformClient {
  constructor(baseUrl, token) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async createConversation(agentId, channelType, channelUserId) {
    const response = await this.client.post(
      `/api/v1/agents/${agentId}/conversations`,
      {
        conversation: {
          channel_type: channelType,
          channel_user_id: channelUserId
        }
      }
    );
    return response.data;
  }

  async sendMessage(conversationId, content) {
    const response = await this.client.post(
      `/api/v1/conversations/${conversationId}/messages`,
      { content }
    );
    return response.data;
  }
}

// Usage
const client = new AgentPlatformClient('http://localhost:3000', 'your_token');

(async () => {
  const conv = await client.createConversation(1, 'web', 'user123');
  const response = await client.sendMessage(conv.conversation.id, 'Hello!');
  console.log(response.content);
})();
```

## Monitoring & Debugging

### Check Agent Status

```bash
curl -X GET http://localhost:3000/api/v1/agents/1 \
  -H "Authorization: Bearer $TOKEN"
```

### List All Conversations for Agent

```bash
curl -X GET http://localhost:3000/api/v1/agents/1/conversations \
  -H "Authorization: Bearer $TOKEN"
```

### Health Check

```bash
curl http://localhost:3000/health
# Response: OK
```

## Tips & Best Practices

1. **Token Management**: Monitor `total_tokens` in conversations to track costs
2. **Temperature**: Use 0.2-0.4 for factual/precise tasks, 0.7-1.0 for creative tasks
3. **System Prompts**: Be specific and include examples of desired behavior
4. **Error Handling**: Always check HTTP status codes and handle rate limits
5. **Conversation Context**: Keep conversations active for context retention
6. **Testing**: Use lower max_tokens during development to save costs

## Troubleshooting

### "Unauthorized" Error
- Verify JWT token is valid and not expired
- Check Authorization header format: `Bearer <token>`

### "Tenant not found" Error
- Ensure subdomain in login matches registration
- Check tenant is active

### "LLM service error"
- Verify API keys are set in environment variables
- Check LLM provider status
- Review rate limits

### Slow Responses
- Use async execution for long-running tasks
- Consider using faster models (gpt-3.5-turbo vs gpt-4)
- Monitor Sidekiq queue depth
